// lib/screens/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../utils/database_helper.dart';
import '../widgets/product_card.dart';
import '../providers/auth_provider.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Product> _allProducts = [];
  List<Product> _products = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _products = _allProducts
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final local = await _dbHelper.getAllProducts();
      setState(() {
        _allProducts = local;
        _products = local;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: \$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _viewProductDetails(Product product) {
    // Navigate to detail page without requiring login
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    ).then((_) => _loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = 16.0 * 2;
                    const spacing = 16.0;
                    final cardWidth =
                        (constraints.maxWidth - horizontalPadding - spacing) / 2;

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Text(
                          'Discover',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find your perfect plant companion',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search plants...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Flexible(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Special Offer',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '20% OFF',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'On selected indoor plants',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text('Shop Now'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.local_florist,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'All Plants',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        if (_products.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Text(
                                'No plants available',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: _products.map((product) {
                              return SizedBox(
                                width: cardWidth,
                                child: ProductCard(
                                  product: product,
                                  onTap: () => _viewProductDetails(product),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}
