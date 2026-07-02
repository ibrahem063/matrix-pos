import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/product_model.dart';
import '../../products/providers/product_provider.dart';
import '../../products/presentation/add_edit_product_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('تنبيهات المخزون')),
      body: StreamBuilder<List<ProductModel>>(
        stream: productProvider.lowStockStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;

          if (products.isEmpty) {
            return const Center(child: Text('لا يوجد منتجات قليلة المخزون'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.warning_amber),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    'الكمية الحالية: ${product.stock} | حد التنبيه: ${product.lowStockLimit}',
                  ),
                  trailing: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditProductScreen(product: product),
                      ),
                    ),
                    child: const Text('تعديل'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
