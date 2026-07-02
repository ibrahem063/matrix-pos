import 'product_model.dart';

class CartItemModel {
  final String productId;
  final String productName;
  final String barcode;
  final double price;
  final double costPrice;
  final int quantity;

  const CartItemModel({
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.price,
    required this.costPrice,
    required this.quantity,
  });

  double get subtotal => price * quantity;
  double get profit => (price - costPrice) * quantity;

  CartItemModel copyWith({
    String? productId,
    String? productName,
    String? barcode,
    double? price,
    double? costPrice,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItemModel.fromProduct(ProductModel product) {
    return CartItemModel(
      productId: product.id,
      productName: product.name,
      barcode: product.barcode,
      price: product.price,
      costPrice: product.costPrice,
      quantity: 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'barcode': barcode,
      'price': price,
      'costPrice': costPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'profit': profit,
    };
  }
}
