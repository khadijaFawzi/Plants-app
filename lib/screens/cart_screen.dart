// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _didFetch = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetch) {
      _didFetch = true;
      // تأجيل الطلب حتى انتهاء البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final user = context.read<AuthProvider>().user;
        if (user != null) {
          context.read<CartProvider>().loadCart(user.id!);
        }
      });
    }
  }

  Future<void> _checkout() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to checkout'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cartProv = context.read<CartProvider>();
    if (cartProv.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Checkout'),
        content: Text('Total: \$${cartProv.total.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await cartProv.clearCart(user.id!);
      Navigator.of(context).pop(); // close loading
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Order placed successfully!'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Cart')),
        body: const Center(child: Text('Please log in to view your cart')),
      );
    }

    final cartProv = context.watch<CartProvider>();
    final items = cartProv.items;
    final isLoading = cartProv.isLoading;
    final total = cartProv.total;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (ctx, i) {
                          final ci = items[i];
                          return CartItemCard(
                            cartItem: ci,
                            onUpdateQuantity: (q) => context.read<CartProvider>().updateQuantity(ci.id!, q, user.id!),
                            onRemove: () => context.read<CartProvider>().removeItem(ci.id!, user.id!),
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
                                '\$${total.toStringAsFixed(0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
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
                                  onPressed: _checkout,
                                  child: const Text('Clear Cart'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _checkout,
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
