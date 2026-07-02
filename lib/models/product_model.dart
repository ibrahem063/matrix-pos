import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String barcode;
  final String categoryName;
  final double price;
  final double costPrice;
  final int stock;
  final int lowStockLimit;
  final String imageUrl;
  final bool isActive;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.categoryName,
    required this.price,
    required this.costPrice,
    required this.stock,
    required this.lowStockLimit,
    required this.imageUrl,
    required this.isActive,
    this.createdAt,
  });

  bool get isLowStock => stock <= lowStockLimit;
  double get profitPerUnit => price - costPrice;

  ProductModel copyWith({
    String? id,
    String? name,
    String? barcode,
    String? categoryName,
    double? price,
    double? costPrice,
    int? stock,
    int? lowStockLimit,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      lowStockLimit: lowStockLimit ?? this.lowStockLimit,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      barcode: data['barcode'] ?? '',
      categoryName: data['categoryName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      lowStockLimit: data['lowStockLimit'] ?? 5,
      imageUrl: data['imageUrl'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap({bool includeCreatedAt = false}) {
    final map = <String, dynamic>{
      'name': name,
      'searchName': name.toLowerCase().trim(),
      'barcode': barcode,
      'categoryName': categoryName,
      'price': price,
      'costPrice': costPrice,
      'stock': stock,
      'lowStockLimit': lowStockLimit,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (includeCreatedAt) {
      map['createdAt'] = FieldValue.serverTimestamp();
    }

    return map;
  }
}
