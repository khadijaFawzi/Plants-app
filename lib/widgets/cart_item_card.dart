// lib/widgets/cart_item_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_item.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final ValueChanged<int> onUpdateQuantity;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    required this.onUpdateQuantity,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: SizedBox(
              width: 100,
              height: 100,
              child: _buildImage(cartItem.productImage),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cartItem.productName ?? 'Product',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(cartItem.productPrice ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: cartItem.quantity > 1
                                  ? () =>
                                      onUpdateQuantity(cartItem.quantity - 1)
                                  : null,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              cartItem.quantity.toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () =>
                                  onUpdateQuantity(cartItem.quantity + 1),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${cartItem.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? src) {
    final imageSrc = src ?? '';

    // 1) رابط إنترنت
    if (imageSrc.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageSrc,
        fit: BoxFit.cover,
        placeholder: (ctx, url) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (ctx, url, error) =>
            Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
      );
    }

    // 2) ملف محلي في الكاش أو جهاز
    final file = File(imageSrc);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
      );
    }

    // 3) أخيرًا، أصل التطبيق (Asset)
    return Image.asset(
      imageSrc.isNotEmpty ? imageSrc : 'assets/images/placeholder.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
    );
  }
}
