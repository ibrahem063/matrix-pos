import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_theme.dart';
import '../../../models/product_model.dart';
import '../providers/product_provider.dart';
import 'add_edit_product_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  void _openForm(BuildContext context, {ProductModel? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(product: product),
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل تريدين حذف ${product.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    await context.read<ProductProvider>().repository.deleteProduct(product.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف المنتج')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('المنتجات')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: provider.updateSearch,
              decoration: const InputDecoration(
                hintText: 'بحث باسم المنتج',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: provider.productsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('خطأ: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!;

                if (products.isEmpty) {
                  return const Center(child: Text('لا يوجد منتجات'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: product.isLowStock
                              ? AppTheme.warning.withOpacity(0.18)
                              : AppTheme.primary.withOpacity(0.10),
                          child: product.imageUrl.isEmpty
                              ? const Icon(Icons.inventory_2)
                              : ClipOval(
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 42,
                                    height: 42,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.inventory_2),
                                  ),
                                ),
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          'السعر: ${product.price.toStringAsFixed(2)} | المخزون: ${product.stock}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _openForm(context, product: product);
                            } else if (value == 'delete') {
                              _deleteProduct(context, product);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('تعديل')),
                            PopupMenuItem(value: 'delete', child: Text('حذف')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
