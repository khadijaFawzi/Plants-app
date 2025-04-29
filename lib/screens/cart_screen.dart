import 'package:flutter/material.dart';
import 'package:flutter_application_1/widets/cart_item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../utils/database_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  int _userId = 0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    
    setState(() {
      _userId = userId;
    });
    
    await _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    if (_userId == 0) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final cartItems = await _dbHelper.getCartItems(_userId);
      double total = 0.0;
      
      for (var item in cartItems) {
        total += item.total;
      }
      
      setState(() {
        _cartItems = cartItems;
        _total = total;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading cart: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(CartItem item, int quantity) async {
    if (quantity <= 0) {
      await _removeItem(item);
      return;
    }

    try {
      await _dbHelper.updateCartItemQuantity(item.id!, quantity);
      await _loadCartItems();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating quantity: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      await _dbHelper.removeFromCart(item.id!);
      await _loadCartItems();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.productName} removed from cart'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing item: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearCart() async {
    try {
      await _dbHelper.clearCart(_userId);
      await _loadCartItems();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cart cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing cart: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Show checkout confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: \$${_total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Would you like to proceed with the purchase?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Process order
              _processOrder();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _processOrder() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Clear cart after successful order
    await _dbHelper.clearCart(_userId);
    
    if (mounted) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Placed'),
          content: const Text('Your order has been successfully placed!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _loadCartItems();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to home tab
                          final mainScreenState = context.findAncestorStateOfType<State>();
                          if (mainScreenState != null) {
                            // This is a bit of a hack to change the tab
                            // In a real app, you might use a state management solution
                            final bottomNavBar = mainScreenState.context.findAncestorWidgetOfExactType<BottomNavigationBar>();
                            if (bottomNavBar != null) {
                              bottomNavBar.onTap!(0);
                            }
                          }
                        },
                        child: const Text('Browse Plants'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return CartItemCard(
                            cartItem: item,
                            onUpdateQuantity: (quantity) => _updateQuantity(item, quantity),
                            onRemove: () => _removeItem(item),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '\$${_total.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _clearCart,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('Clear Cart'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _checkout,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('Checkout'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

