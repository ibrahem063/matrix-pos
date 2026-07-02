import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/product_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../products/data/product_repository.dart';
import '../../sales/data/sale_repository.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _searchController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');

  final ProductRepository _productRepository = ProductRepository();
  final SaleRepository _saleRepository = SaleRepository();

  String _search = '';
  String _paymentMethod = 'cash';
  bool _isPaying = false;

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final cart = context.read<CartProvider>();
    final cashierId = FirebaseAuth.instance.currentUser?.uid;

    if (cashierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول')),
      );
      return;
    }

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة')),
      );
      return;
    }

    setState(() => _isPaying = true);

    try {
      final saleId = await _saleRepository.createSale(
        cashierId: cashierId,
        items: cart.items,
        totalAmount: cart.total,
        discount: cart.discount,
        tax: cart.tax,
        paymentMethod: _paymentMethod,
      );

      cart.clear();
      _discountController.text = '0';
      _taxController.text = '0';

      if (!mounted) return;

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تمت عملية البيع'),
          content: Text('رقم الفاتورة: $saleId'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }

    if (mounted) setState(() => _isPaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الكاشير POS')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;

          final productsPanel = _ProductsPanel(
            searchController: _searchController,
            search: _search,
            onSearchChanged: (value) => setState(() => _search = value),
            productRepository: _productRepository,
          );

          final cartPanel = _CartPanel(
            discountController: _discountController,
            taxController: _taxController,
            paymentMethod: _paymentMethod,
            onPaymentChanged: (value) => setState(() => _paymentMethod = value),
            isPaying: _isPaying,
            onCheckout: _checkout,
          );

          if (wide) {
            return Row(
              children: [
                Expanded(flex: 3, child: productsPanel),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: cartPanel),
              ],
            );
          }

          return Column(
            children: [
              Expanded(child: productsPanel),
              SizedBox(
                height: cart.isEmpty ? 150 : 320,
                child: cartPanel,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductsPanel extends StatelessWidget {
  final TextEditingController searchController;
  final String search;
  final ValueChanged<String> onSearchChanged;
  final ProductRepository productRepository;

  const _ProductsPanel({
    required this.searchController,
    required this.search,
    required this.onSearchChanged,
    required this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'بحث باسم المنتج',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ProductModel>>(
            stream: productRepository.watchProducts(search: search),
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

              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: product.stock <= 0
                        ? null
                        : () => context.read<CartProvider>().addProduct(product),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: product.imageUrl.isEmpty
                                  ? const Icon(Icons.shopping_bag, size: 52)
                                  : Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.shopping_bag, size: 52),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text('${product.price.toStringAsFixed(2)} JOD'),
                            Text(
                              product.stock > 0 ? 'Stock: ${product.stock}' : 'Out of stock',
                              style: TextStyle(
                                color: product.stock > 0 ? null : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CartPanel extends StatelessWidget {
  final TextEditingController discountController;
  final TextEditingController taxController;
  final String paymentMethod;
  final ValueChanged<String> onPaymentChanged;
  final bool isPaying;
  final VoidCallback onCheckout;

  const _CartPanel({
    required this.discountController,
    required this.taxController,
    required this.paymentMethod,
    required this.onPaymentChanged,
    required this.isPaying,
    required this.onCheckout,
  });

  double _toDouble(String value) => double.tryParse(value.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ListTile(
            title: Text(
              'السلة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.shopping_cart),
          ),
          const Divider(height: 1),
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text('السلة فارغة'))
                : ListView.separated(
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return ListTile(
                        title: Text(item.productName),
                        subtitle: Text('${item.price.toStringAsFixed(2)} × ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => context
                                  .read<CartProvider>()
                                  .decreaseQuantity(item.productId),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              onPressed: () => context
                                  .read<CartProvider>()
                                  .increaseQuantity(item.productId, 999999),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: discountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الخصم'),
                        onChanged: (value) => context
                            .read<CartProvider>()
                            .updateDiscount(_toDouble(value)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: taxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'الضريبة'),
                        onChanged: (value) =>
                            context.read<CartProvider>().updateTax(_toDouble(value)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: const InputDecoration(labelText: 'طريقة الدفع'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                    DropdownMenuItem(value: 'wallet', child: Text('Wallet')),
                  ],
                  onChanged: (value) {
                    if (value != null) onPaymentChanged(value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('الإجمالي:', style: TextStyle(fontSize: 18)),
                    const Spacer(),
                    Text(
                      '${cart.total.toStringAsFixed(2)} JOD',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: isPaying ? null : onCheckout,
                  icon: isPaying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payment),
                  label: const Text('دفع وحفظ الفاتورة'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
