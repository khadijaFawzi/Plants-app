// lib/screens/manage_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product.dart';
import '../utils/database_helper.dart';
import 'edit_product_screen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({Key? key}) : super(key: key);

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final _dbHelper = DatabaseHelper();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final list = await _dbHelper.getAllProducts();
      if (mounted) setState(() => _products = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await _dbHelper.deleteProduct(product.id!);
      await _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} deleted'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToEdit([Product? product]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
    ).then((_) => _loadProducts());
  }

  Future<void> _confirmDelete(Product product) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Product'),
            content: Text('Delete "${product.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
    if (ok) _deleteProduct(product);
  }

  Widget _buildImage(String src) {
    if (src.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: src,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) => Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
      );
    }
    final file = File(src);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/images/placeholder.png', fit: BoxFit.cover));
    }
    return Image.asset(src.isNotEmpty ? src : 'assets/images/placeholder.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/images/placeholder.png', fit: BoxFit.cover));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No products available', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            onPressed: () => _navigateToEdit(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (ctx, i) {
          final p = _products[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                  child: SizedBox(width: 100, height: 100, child: _buildImage(p.image)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('\$${p.price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(p.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToEdit(p)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(p)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () => _navigateToEdit(), child: const Icon(Icons.add)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }
}
