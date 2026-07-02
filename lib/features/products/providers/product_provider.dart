import 'package:flutter/material.dart';

import '../../../models/product_model.dart';
import '../data/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository repository = ProductRepository();

  String searchText = '';

  void updateSearch(String value) {
    searchText = value;
    notifyListeners();
  }

  Stream<List<ProductModel>> productsStream() {
    return repository.watchProducts(search: searchText);
  }

  Stream<List<ProductModel>> lowStockStream() {
    return repository.watchLowStockProducts();
  }
}
