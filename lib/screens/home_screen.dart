// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firstproject/services/api_service.dart';
import 'package:firstproject/screens/login_screen.dart';
import 'package:firstproject/screens/product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    // ... โค้ดส่วนนี้เหมือนเดิม ...
    setState(() => _isLoading = true);
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    // ... โค้ดส่วนนี้เหมือนเดิม ...
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _navigateToForm({Map<String, dynamic>? product}) async {
    // ... โค้ดส่วนนี้เหมือนเดิม ...
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );
    if (result == true) {
      _fetchProducts();
    }
  }

  // **** ส่วนของการลบที่ปรับปรุงใหม่ ****
  Future<void> _deleteProduct(int productId) async {
    try {
      // 1. เรียก API เพื่อลบข้อมูล
      await _apiService.deleteProduct(productId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // 2. สั่งให้โหลดข้อมูลใหม่หลังจากลบสำเร็จ
        _fetchProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // **** เพิ่มฟังก์ชันแสดงกล่องยืนยัน ****
  void _showDeleteConfirmationDialog(int productId, String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "$productName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องข้อความ
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องข้อความ
                _deleteProduct(productId);   // เรียกฟังก์ชันลบ
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget สำหรับสร้าง Body (ใช้โค้ดเดิมได้)
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_products.isEmpty) {
      return Center(
        child: Text(
          'No products found.\nTap + to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(product['product_name'] ?? 'No Name'),
              subtitle: Text(
                  'Type: ${product['product_type']} - Price: \$${product['price']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _navigateToForm(product: product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    // **** แก้ไขจุดนี้: ให้เรียกกล่องยืนยันก่อน ****
                    onPressed: () => _showDeleteConfirmationDialog(
                        product['id'], product['product_name']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}