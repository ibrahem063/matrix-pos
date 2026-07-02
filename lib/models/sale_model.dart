import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  final String id;
  final String cashierId;
  final double totalAmount;
  final double discount;
  final double tax;
  final double totalProfit;
  final String paymentMethod;
  final DateTime? createdAt;

  const SaleModel({
    required this.id,
    required this.cashierId,
    required this.totalAmount,
    required this.discount,
    required this.tax,
    required this.totalProfit,
    required this.paymentMethod,
    this.createdAt,
  });

  factory SaleModel.fromMap(String id, Map<String, dynamic> data) {
    return SaleModel(
      id: id,
      cashierId: data['cashierId'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      totalProfit: (data['totalProfit'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
