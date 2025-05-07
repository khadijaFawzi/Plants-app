// lib/models/product.dart
import 'package:flutter/foundation.dart';

class Product {
  final int? id;
  final String name;
  final double price;
  final String description;
  final String image;

  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  /// Constructs a Product from either local SQLite map or remote API map
  factory Product.fromMap(Map<String, dynamic> map) {
    // Name may come as 'name' (local) or 'title' (API)
    final rawName = map['name'] as String? ?? map['title'] as String?;
    // Price could be int or double
    final rawPrice = map['price'];
    // Description always under 'description'
    final rawDesc = map['description'] as String?;
    // Image path may be local 'image', or remote 'thumbnail', or first of 'images' list
    String? rawImage;
    if (map.containsKey('image') && map['image'] is String) {
      rawImage = map['image'] as String;
    } else if (map.containsKey('thumbnail') && map['thumbnail'] is String) {
      rawImage = map['thumbnail'] as String;
    } else if (map['images'] is List && (map['images'] as List).isNotEmpty) {
      rawImage = (map['images'] as List).first as String?;
    }

    return Product(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? ''),
      name: rawName ?? '',
      price: rawPrice is num ? rawPrice.toDouble() : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0,
      description: rawDesc ?? '',
      image: rawImage ?? 'assets/images/placeholder.png',
    );
  }

  /// Converts a Product to a map for SQLite
  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'name': name,
      'price': price,
      'description': description,
      'image': image,
    };
    if (id != null) m['id'] = id;
    return m;
  }

  @override
  String toString() => 'Product(id: \$id, name: \$name, price: \$price)';
}
