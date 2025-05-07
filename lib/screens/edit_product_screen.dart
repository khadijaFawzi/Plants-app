
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:img_picker/img_picker.dart';
// import '../models/product.dart';
// import '../utils/database_helper.dart';

// class EditProductScreen extends StatefulWidget {
//   final Product? product;

//   const EditProductScreen({Key? key, this.product}) : super(key: key);

//   @override
//   State<EditProductScreen> createState() => _EditProductScreenState();
// }

// class _EditProductScreenState extends State<EditProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtl = TextEditingController();
//   final _priceCtl = TextEditingController();
//   final _descCtl = TextEditingController();

//   String? _imagePath;
//   bool _isSaving = false;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.product != null) {
//       _nameCtl.text = widget.product!.name;
//       _priceCtl.text = widget.product!.price.toString();
//       _descCtl.text = widget.product!.description;
//       _imagePath = widget.product!.image;
//     }
//   }

//   @override
//   void dispose() {
//     _nameCtl.dispose();
//     _priceCtl.dispose();
//     _descCtl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final XFile? img =
//         await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
//     if (img != null) {
//       setState(() => _imagePath = img.path);
//     }
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_imagePath == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please select an image'),
//             backgroundColor: Colors.red),
//       );
//       return;
//     }

//     setState(() => _isSaving = true);

//     final product = Product(
//       id: widget.product?.id,
//       name: _nameCtl.text.trim(),
//       price: double.parse(_priceCtl.text.trim()),
//       description: _descCtl.text.trim(),
//       image: _imagePath!,
//     );

//     try {
//       final db = DatabaseHelper();            // ← use the factory constructor
//       if (widget.product == null) {
//         await db.insertProduct(product);
//       } else {
//         await db.updateProduct(product);
//       }
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('Error saving product: $e'),
//             backgroundColor: Colors.red),
//       );
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:
//             Text(widget.product == null ? 'Add Product' : 'Edit Product'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: Container(
//                   height: 200,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.grey.shade200,
//                     image: _imagePath != null
//                         ? DecorationImage(
//                             image: FileImage(File(_imagePath!)),
//                             fit: BoxFit.cover,
//                           )
//                         : null,
//                   ),
//                   child: _imagePath == null
//                       ? const Center(
//                           child: Icon(Icons.add_a_photo,
//                               size: 50, color: Colors.grey),
//                         )
//                       : null,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               TextFormField(
//                 controller: _nameCtl,
//                 decoration: const InputDecoration(
//                   labelText: 'Product Name',
//                   prefixIcon: Icon(Icons.shopping_bag_outlined),
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                     (v == null || v.isEmpty) ? 'Enter product name' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _priceCtl,
//                 decoration: const InputDecoration(
//                   labelText: 'Price',
//                   prefixIcon: Icon(Icons.attach_money),
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (v) {
//                   if (v == null || v.isEmpty) return 'Enter price';
//                   return double.tryParse(v) == null
//                       ? 'Enter a valid number'
//                       : null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descCtl,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   prefixIcon: Icon(Icons.description_outlined),
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 4,
//                 validator: (v) =>
//                     (v == null || v.isEmpty) ? 'Enter description' : null,
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _isSaving ? null : _save,
//                   icon: _isSaving
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2, color: Colors.white),
//                         )
//                       : const Icon(Icons.save),
//                   label: Text(widget.product == null
//                       ? 'Add Product'
//                       : 'Save Changes'),
//                   style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/widgets/custom_text_field.dart';
import 'package:img_picker/img_picker.dart';

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

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
      // Load existing image path if valid
      if (widget.product!.image.isNotEmpty) {
        final file = File(widget.product!.image);
        if (file.existsSync()) {
          _pickedImage = file;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dbHelper = DatabaseHelper();
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        image: _pickedImage!.path,
      );

      if (widget.product == null) {
        await dbHelper.insertProduct(product);
      } else {
        await dbHelper.updateProduct(product);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: \$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _pickedImage == null
                      ? const Center(
                          child: Icon(
                            Icons.image,
                            size: 80,
                            color: Colors.grey,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _pickedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                hintText: 'Product Name',
                prefixIcon: Icons.shopping_bag_outlined,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter product name'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _priceController,
                hintText: 'Price',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter price';
                  return double.tryParse(value) == null
                      ? 'Please enter a valid number'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Description',
                prefixIcon: Icons.description_outlined,
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter description'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
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
    );
  }
}
