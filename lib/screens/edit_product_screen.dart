import 'package:flutter/material.dart';
import 'package:flutter_application_1/widets/custom_text_field.dart';

import '../models/product.dart';
import '../utils/database_helper.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      _imageController.text = widget.product!.image;
    } else {
      _imageController.text = 'assets/images/placeholder.png';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dbHelper = DatabaseHelper();
        
        final product = Product(
          id: widget.product?.id,
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          description: _descriptionController.text.trim(),
          image: _imageController.text.trim(),
        );
        
        if (widget.product == null) {
          // Add new product
          await dbHelper.insertProduct(product);
        } else {
          // Update existing product
          await dbHelper.updateProduct(product);
        }
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving product: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 80,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Product Name',
                  prefixIcon: Icons.shopping_bag_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _priceController,
                  hintText: 'Price',
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  hintText: 'Description',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _imageController,
                  hintText: 'Image Path',
                  prefixIcon: Icons.image_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter image path';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(widget.product == null ? 'Add Product' : 'Update Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

