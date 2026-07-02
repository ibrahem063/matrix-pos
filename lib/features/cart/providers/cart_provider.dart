import 'package:flutter/material.dart';

import '../../../models/cart_item_model.dart';
import '../../../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};

  List<CartItemModel> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double discount = 0;
  double tax = 0;

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get total => subtotal - discount + tax;

  double get totalProfit =>
      items.fold(0.0, (sum, item) => sum + item.profit) - discount;

  void addProduct(ProductModel product) {
    final current = _items[product.id];

    if (current == null) {
      _items[product.id] = CartItemModel.fromProduct(product);
    } else if (current.quantity < product.stock) {
      _items[product.id] = current.copyWith(quantity: current.quantity + 1);
    }

    notifyListeners();
  }

  void increaseQuantity(String productId, int maxStock) {
    final item = _items[productId];
    if (item == null) return;

    if (item.quantity < maxStock) {
      _items[productId] = item.copyWith(quantity: item.quantity + 1);
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    final item = _items[productId];
    if (item == null) return;

    if (item.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = item.copyWith(quantity: item.quantity - 1);
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateDiscount(double value) {
    discount = value < 0 ? 0 : value;
    notifyListeners();
  }

  void updateTax(double value) {
    tax = value < 0 ? 0 : value;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    discount = 0;
    tax = 0;
    notifyListeners();
  }
}
