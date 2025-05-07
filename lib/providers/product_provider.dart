// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import '../services/api_service.dart';
// import '../models/response_model.dart';
// import '../utils/database_helper.dart';

// class ProductProvider extends ChangeNotifier {
//   final ApiService _api = ApiService.instance;
//   final DatabaseHelper _db = DatabaseHelper();
//   List<Product> _products = [];
//   bool _isLoading = false;

//   List<Product> get products => _products;
//   bool get isLoading => _isLoading;

//   Future<void> loadProducts() async {
//     _isLoading = true; notifyListeners();

//     // 1) Load from local SQLite cache
//     final local = await _db.getAllProducts();
//     if (local.isNotEmpty) {
//       _products = local;
//       _isLoading = false;
//       notifyListeners();
//     }

//     // 2) Fetch from API and overwrite cache
//     final res = await _api.get('products');
//     if (res.success) {
//       final list = (res.body['products'] as List)
//           .map((e) => Product.fromMap(e))
//           .toList();
//       // refresh local DB
//       await _db.clearProducts();
//       for (final p in list) {
//         await _db.insertProduct(p);
//       }
//       _products = list;
//     }
//     _isLoading = false; notifyListeners();
//   }

//   Future<void> addProduct(Product p) async {
//     _isLoading = true; notifyListeners();
//     final res = await _api.post('products', body: p.toMap());
//     if (res.success) {
//       final newP = Product.fromMap(res.body);
//       _products.add(newP);
//       await _db.insertProduct(newP);
//     } else {
//       throw Exception(res.message);
//     }
//     _isLoading = false; notifyListeners();
//   }

//   Future<void> updateProduct(Product p) async {
//     _isLoading = true; notifyListeners();
//     final res = await _api.put('products/${p.id}', body: p.toMap());
//     if (res.success) {
//       final updated = Product.fromMap(res.body);
//       final idx = _products.indexWhere((e) => e.id == updated.id);
//       if (idx != -1) _products[idx] = updated;
//       await _db.updateProduct(updated);
//     } else {
//       throw Exception(res.message);
//     }
//     _isLoading = false; notifyListeners();
//   }

//   Future<void> deleteProduct(int id) async {
//     _isLoading = true; notifyListeners();
//     final res = await _api.delete('products/$id');
//     if (res.success) {
//       _products.removeWhere((e) => e.id == id);
//       await _db.deleteProduct(id);
//     } else {
//       throw Exception(res.message);
//     }
//     _isLoading = false; notifyListeners();
//   }
// }


// lib/providers/product_provider.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../models/response_model.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final ResponseModel res = await _api.get('products');
    if (res.success && res.body != null) {
      try {
        final List list = res.body['products'] as List;
        _products = list.map((e) => Product.fromMap(e)).toList();
      } catch (e) {
        _error = 'Parsing error: \$e';
      }
    } else {
      _error = res.message;
    }

    _isLoading = false;
    notifyListeners();
  }
}
