import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_helper.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/sale_model.dart';

class SaleRepository {
  final FirebaseFirestore _firestore;

  SaleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createSale({
    required String cashierId,
    required List<CartItemModel> items,
    required double totalAmount,
    required double discount,
    required double tax,
    required String paymentMethod,
  }) async {
    if (items.isEmpty) {
      throw Exception('Cart is empty');
    }

    final saleRef = _firestore.collection('sales').doc();
    final todayId = DateHelper.dayId(DateTime.now());
    final dailyReportRef = _firestore.collection('daily_reports').doc(todayId);

    await _firestore.runTransaction((transaction) async {
      final productRefs = items
          .map((item) => _firestore.collection('products').doc(item.productId))
          .toList();

      final productSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];

      // Firestore transactions should read documents before writing.
      for (final ref in productRefs) {
        final snapshot = await transaction.get(ref);
        productSnapshots.add(snapshot);
      }

      double totalProfit = 0;
      int totalItemsSold = 0;

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final productSnapshot = productSnapshots[i];

        if (!productSnapshot.exists) {
          throw Exception('Product ${item.productName} not found');
        }

        final productData = productSnapshot.data()!;
        final currentStock = productData['stock'] ?? 0;
        final costPrice = (productData['costPrice'] ?? item.costPrice).toDouble();

        if (currentStock < item.quantity) {
          throw Exception('Not enough stock for ${item.productName}');
        }

        totalProfit += (item.price - costPrice) * item.quantity;
        totalItemsSold += item.quantity;
      }

      totalProfit -= discount;

      transaction.set(saleRef, {
        'cashierId': cashierId,
        'totalAmount': totalAmount,
        'discount': discount,
        'tax': tax,
        'totalProfit': totalProfit,
        'paymentMethod': paymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final productRef = productRefs[i];
        final itemRef = saleRef.collection('items').doc();

        transaction.update(productRef, {
          'stock': FieldValue.increment(-item.quantity),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.set(itemRef, item.toMap());

        final topProductRef = dailyReportRef.collection('top_products').doc(item.productId);
        transaction.set(
          topProductRef,
          {
            'productId': item.productId,
            'productName': item.productName,
            'quantitySold': FieldValue.increment(item.quantity),
            'salesAmount': FieldValue.increment(item.subtotal),
          },
          SetOptions(merge: true),
        );
      }

      transaction.set(
        dailyReportRef,
        {
          'date': todayId,
          'totalSales': FieldValue.increment(totalAmount),
          'totalProfit': FieldValue.increment(totalProfit),
          'totalInvoices': FieldValue.increment(1),
          'totalItemsSold': FieldValue.increment(totalItemsSold),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    return saleRef.id;
  }

  Stream<List<SaleModel>> watchRecentSales({int limit = 50}) {
    return _firestore
        .collection('sales')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SaleModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
