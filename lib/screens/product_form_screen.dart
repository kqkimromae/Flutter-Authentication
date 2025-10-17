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

    _nameController =

        TextEditingController(text: widget.product?['product_name']);

    _typeController =

        TextEditingController(text: widget.product?['product_type']);

    _priceController =

        TextEditingController(text: widget.product?['price']?.toString());

    _unitController =

        TextEditingController(text: widget.product?['unit']?.toString());

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

              content:

                  Text(e.toString().replaceFirst('Exception: ', '')),

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

    final isEditMode = widget.product != null;



    return Scaffold(

      extendBodyBehindAppBar: true,

      appBar: AppBar(

        title: Text(

          isEditMode ? 'Edit Player 📝' : 'Add New Player ⚽️',

          style: const TextStyle(fontWeight: FontWeight.bold),

        ),

        centerTitle: true,

        backgroundColor: const Color.fromARGB(0, 199, 187, 187),

        elevation: 0,

      ),

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,

          ),

        ),

        child: SingleChildScrollView(

          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),

          child: Form(

            key: _formKey,

            child: Container(

              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(

                color: Colors.white.withOpacity(0.05),

                borderRadius: BorderRadius.circular(20),

                border: Border.all(color: Colors.white.withOpacity(0.15)),

                boxShadow: [

                  BoxShadow(

                    color: Colors.black.withOpacity(0.5),

                    blurRadius: 15,

                    offset: const Offset(0, 8),

                  ),

                ],

              ),

              child: Column(

                children: [

                  AnimatedSwitcher(

                    duration: const Duration(milliseconds: 400),

                    child: Icon(

                      isEditMode

                          ? Icons.edit_note_rounded

                          : Icons.add_box_rounded,

                      key: ValueKey(isEditMode),

                      color: const Color(0xFF9BB1FF),

                      size: 80,

                    ),

                  ),

                  const SizedBox(height: 10),

                  Text(

                    isEditMode

                        ? 'Update your product details'

                        : 'Create a new player',

                    style: const TextStyle(

                      color: Colors.white70,

                      fontSize: 15,

                      fontWeight: FontWeight.w500,

                    ),

                  ),

                  const SizedBox(height: 32),



                  // Product Name

                  _buildTextField(

                    controller: _nameController,

                    label: 'Player Name',

                    icon: Icons.shopping_bag_outlined,

                    validator: (value) =>

                        value!.trim().isEmpty ? 'Please enter a name' : null,

                  ),

                  const SizedBox(height: 18),



                  // Product Type

                  _buildTextField(

                    controller: _typeController,

                    label: 'Position',

                    icon: Icons.category_outlined,

                    validator: (value) =>

                        value!.trim().isEmpty ? 'Please enter a position' : null,

                  ),

                  const SizedBox(height: 18),



                  // Price

                  _buildTextField(

                    controller: _priceController,

                    label: 'Salary',

                    icon: Icons.attach_money_outlined,

                    keyboardType:

                        const TextInputType.numberWithOptions(decimal: true),

                    validator: (value) {

                      if (value == null || value.trim().isEmpty) {

                        return 'Please enter a value';

                      }

                      if (double.tryParse(value) == null) {

                        return 'Please enter a valid number';

                      }

                      return null;

                    },

                  ),

                  const SizedBox(height: 18),



                  // Unit

                  _buildTextField(

                    controller: _unitController,

                    label: 'Jersey number',

                    icon: Icons.format_list_numbered_outlined,

                    keyboardType: TextInputType.number,

                    validator: (value) {

                      if (value == null || value.trim().isEmpty) {

                        return 'Please enter a jersey number';

                      }

                      if (int.tryParse(value) == null) {

                        return 'Please enter a valid integer';

                      }

                      return null;

                    },

                  ),



                  const SizedBox(height: 40),



                  _isLoading

                      ? const CircularProgressIndicator(color: Colors.white)

                      : SizedBox(

                          width: double.infinity,

                          child: ElevatedButton.icon(

                            onPressed: _saveProduct,

                            icon: const Icon(Icons.save_alt_rounded),

                            label: Text(

                              isEditMode

                                  ? 'Update Player'

                                  : 'Save Player',

                            ),

                            style: ElevatedButton.styleFrom(

                              backgroundColor: const Color(0xFF5C7AEA),

                              foregroundColor: Colors.white,

                              padding:

                                  const EdgeInsets.symmetric(vertical: 14),

                              shape: RoundedRectangleBorder(

                                borderRadius: BorderRadius.circular(14),

                              ),

                              elevation: 8,

                              shadowColor:

                                  Colors.blueAccent.withOpacity(0.4),

                              textStyle: const TextStyle(

                                fontWeight: FontWeight.bold,

                                fontSize: 16,

                                letterSpacing: 1.1,

                              ),

                            ),

                          ),

                        ),

                ],

              ),

            ),

          ),

        ),

      ),

    );

  }



  // 🌙 Custom Dark Input Field

  Widget _buildTextField({

    required TextEditingController controller,

    required String label,

    required IconData icon,

    TextInputType? keyboardType,

    String? Function(String?)? validator,

  }) {

    return TextFormField(

      controller: controller,

      keyboardType: keyboardType,

      style: const TextStyle(color: Colors.white),

      validator: validator,

      decoration: InputDecoration(

        prefixIcon: Icon(icon, color: Colors.white70),

        labelText: label,

        labelStyle: const TextStyle(color: Colors.white70),

        filled: true,

        fillColor: Colors.white.withOpacity(0.1),

        border: OutlineInputBorder(

          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: Colors.white30),

        ),

        enabledBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: Colors.white24),

        ),

        focusedBorder: OutlineInputBorder(

          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),

        ),

      ),

    );

  }

}