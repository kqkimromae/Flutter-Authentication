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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  List<dynamic> _products = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);

    try {
      final products = await _apiService.getProducts();

      setState(() => _products = products);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),

            backgroundColor: Colors.redAccent.shade200,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
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
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );

    if (result == true) _fetchProducts();
  }

  Future<void> _deleteProduct(int productId) async {
    try {
      await _apiService.deleteProduct(productId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🗑️ Product deleted'),

            backgroundColor: Colors.greenAccent.shade400,
          ),
        );

        _fetchProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${e.toString().replaceFirst("Exception: ", "")}',
            ),

            backgroundColor: Colors.redAccent.shade200,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(int productId, String productName) {
    showDialog(
      context: context,

      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2D3E),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        title: const Text(
          'Delete Product',

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),

        content: Text(
          'Are you sure you want to delete “$productName”?',

          style: TextStyle(color: Colors.grey.shade300),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade200,

              foregroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            icon: const Icon(Icons.delete_outline),

            label: const Text('Delete'),

            onPressed: () {
              Navigator.pop(context);

              _deleteProduct(productId);
            },
          ),
        ],
      ),
    );
  }

  // 🧩 BODY

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 90,
              color: Colors.grey.shade700,
            ),

            const SizedBox(height: 16),

            Text(
              'No products yet.\nTap the + button to add one.',

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.blueAccent,

      backgroundColor: const Color(0xFF1E2230),

      onRefresh: _fetchProducts,

      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),

        itemCount: _products.length,

        itemBuilder: (context, index) {
          final product = _products[index];

          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),

            duration: Duration(milliseconds: 400 + index * 80),

            builder: (context, value, child) => Opacity(
              opacity: value,

              child: Transform.translate(
                offset: Offset(0, (1 - value) * 20),

                child: child,
              ),
            ),

            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3E),

                borderRadius: BorderRadius.circular(16),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),

                    blurRadius: 8,

                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: ListTile(
                contentPadding: const EdgeInsets.all(16),

                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.blueAccent),
                ),

                title: Text(
                  product['product_name'] ?? 'Unnamed',

                  style: const TextStyle(
                    color: Colors.white,

                    fontWeight: FontWeight.w600,

                    fontSize: 16,
                  ),
                ),

                subtitle: Text(
                  'Position: ${product['product_type']}  •  \$${product['price']}', 

                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),

                trailing: Wrap(
                  spacing: 6,

                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Colors.blueAccent,
                      ),

                      onPressed: () => _navigateToForm(product: product),
                    ),

                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),

                      onPressed: () => _showDeleteConfirmationDialog(
                        product['id'],

                        product['product_name'],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🌙 MAIN BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2230),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2D3E),

        elevation: 2,

        centerTitle: true,

        title: const Text(
          'Player Football Team',

          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.grey),

            tooltip: 'Logout',

            onPressed: _logout,
          ),
        ],
      ),

      body: _buildBody(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),

        backgroundColor: Colors.blueAccent.shade400,

        label: const Text('Add Player'),

        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}
