import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  Stream<List<ProductModel>> watchProducts({String search = ''}) {
    final normalizedSearch = search.toLowerCase().trim();

    Query<Map<String, dynamic>> query = _products.orderBy('searchName');

    if (normalizedSearch.isNotEmpty) {
      query = query
          .where('searchName', isGreaterThanOrEqualTo: normalizedSearch)
          .where('searchName', isLessThan: '$normalizedSearch\uf8ff');
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .where((product) => product.isActive)
              .toList(),
        );
  }

  Stream<List<ProductModel>> watchLowStockProducts() {
    return _products.orderBy('searchName').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .where((product) => product.isActive && product.isLowStock)
              .toList(),
        );
  }

  Future<ProductModel?> findProductByBarcode(String barcode) async {
    final snapshot = await _products
        .where('barcode', isEqualTo: barcode.trim())
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return ProductModel.fromMap(doc.id, doc.data());
  }

  Future<void> addProduct(ProductModel product) async {
    await _products.add(product.toMap(includeCreatedAt: true));
  }

  Future<void> updateProduct(ProductModel product) async {
    await _products.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    // Soft delete to keep old sales history safe.
    await _products.doc(productId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
