import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/product_model.dart';
import '../providers/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({
    super.key,
    this.product,
  });

  bool get isEdit => product != null;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _lowStockController;
  late final TextEditingController _imageUrlController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _nameController = TextEditingController(text: product?.name ?? '');
    _barcodeController = TextEditingController(text: product?.barcode ?? '');
    _categoryController = TextEditingController(text: product?.categoryName ?? '');
    _priceController = TextEditingController(text: product?.price.toString() ?? '');
    _costPriceController = TextEditingController(text: product?.costPrice.toString() ?? '');
    _stockController = TextEditingController(text: product?.stock.toString() ?? '');
    _lowStockController = TextEditingController(text: product?.lowStockLimit.toString() ?? '5');
    _imageUrlController = TextEditingController(text: product?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  double _toDouble(String value) => double.tryParse(value.trim()) ?? 0;
  int _toInt(String value) => int.tryParse(value.trim()) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      barcode: _barcodeController.text.trim(),
      categoryName: _categoryController.text.trim(),
      price: _toDouble(_priceController.text),
      costPrice: _toDouble(_costPriceController.text),
      stock: _toInt(_stockController.text),
      lowStockLimit: _toInt(_lowStockController.text),
      imageUrl: _imageUrlController.text.trim(),
      isActive: true,
      createdAt: widget.product?.createdAt,
    );

    try {
      final repository = context.read<ProductProvider>().repository;

      if (widget.isEdit) {
        await repository.updateProduct(product);
      } else {
        await repository.addProduct(product);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isEdit ? 'تم تعديل المنتج' : 'تم إضافة المنتج')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }

    if (mounted) setState(() => _isSaving = false);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    if (double.tryParse(value.trim()) == null) return 'اكتبي رقم صحيح';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'تعديل منتج' : 'إضافة منتج'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_nameController, 'اسم المنتج', Icons.shopping_bag, _requiredValidator),
                _field(_barcodeController, 'الباركود', Icons.qr_code, _requiredValidator),
                _field(_categoryController, 'التصنيف', Icons.category, _requiredValidator),
                Row(
                  children: [
                    Expanded(
                      child: _field(_priceController, 'سعر البيع', Icons.sell, _numberValidator),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_costPriceController, 'سعر التكلفة', Icons.payments, _numberValidator),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _field(_stockController, 'الكمية', Icons.inventory, _numberValidator),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(_lowStockController, 'حد التنبيه', Icons.warning, _numberValidator),
                    ),
                  ],
                ),
                _field(_imageUrlController, 'رابط صورة المنتج - اختياري', Icons.image, null),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('حفظ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?)? validator,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: label.contains('سعر') || label.contains('كمية') || label.contains('حد')
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
