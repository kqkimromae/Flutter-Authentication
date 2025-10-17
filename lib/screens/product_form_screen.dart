// lib/screens/product_form_screen.dart

import 'package:flutter/material.dart';
import 'package:firstproject/services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _priceController;
  late TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['product_name']);
    _typeController = TextEditingController(text: widget.product?['product_type']);
    _priceController = TextEditingController(text: widget.product?['price']?.toString());
    _unitController = TextEditingController(text: widget.product?['unit']?.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final productData = {
        'product_name': _nameController.text.trim(),
        'product_type': _typeController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'unit': int.tryParse(_unitController.text) ?? 0,
      };

      try {
        if (widget.product == null) {
          await _apiService.addProduct(productData);
        } else {
          await _apiService.updateProduct(widget.product!['id'], productData);
        }

        if (mounted) Navigator.of(context).pop(true);

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Product Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Please enter a type' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_list_numbered_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a unit';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid integer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.save_alt_outlined),
                        label: const Text('Save Product'),
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}