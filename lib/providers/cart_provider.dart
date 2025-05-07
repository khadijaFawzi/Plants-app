// // lib/providers/cart_provider.dart
// import 'package:flutter/material.dart';
// import '../models/cart_item.dart';
// import '../services/api_service.dart';
// import '../utils/database_helper.dart';

// class CartProvider extends ChangeNotifier {
//   final ApiService _api = ApiService.instance;
//   final DatabaseHelper _db = DatabaseHelper();

//   List<CartItem> _items = [];
//   bool _isLoading = false;
//   String? _lastError;

//   List<CartItem> get items     => _items;
//   bool        get isLoading => _isLoading;
//   double      get total     => _items.fold(0.0, (sum, i) => sum + i.total);
//   String?     get lastError => _lastError;

//   /// Load cart: GET from API then sync SQLite
//   Future<void> loadCart(int userId) async {
//     _isLoading = true;
//     _lastError = null;
//     notifyListeners();

//     final res = await _api.get('carts/user/$userId');
//     if (res.success && res.body != null) {
//       try {
//         final data = res.body!;
//         final serverItems = (data['products'] as List).map((p) {
//           return CartItem.fromMap({
//             'id': p['id'],
//             'userId': data['userId'],
//             'productId': p['id'],
//             'quantity': p['quantity'],
//             'name': p['title'],
//             'price': p['price'],
//             'image': p['thumbnail'] ?? 'assets/images/placeholder.png',
//           });
//         }).toList();

//         await _db.clearCart(userId);
//         for (var ci in serverItems) {
//           await _db.addToCart(ci);
//         }
//         _items = serverItems;
//       } catch (e) {
//         _lastError = 'Parsing error: $e';
//       }
//     } else {
//       _lastError = res.message;
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   /// Add item: POST to API then sync SQLite
//   Future<void> addToCart(CartItem ci) async {
//     _isLoading = true;
//     _lastError = null;
//     notifyListeners();

//     final body = {
//       'userId': ci.userId,
//       'products': [
//         {'id': ci.productId, 'quantity': ci.quantity}
//       ],
//     };

//     final res = await _api.post('carts/add', body: body);
//     if (res.success && res.body != null) {
//       try {
//         final serverCart = res.body!;
//         final serverItems = (serverCart['products'] as List).map((p) {
//           return CartItem.fromMap({
//             'id': p['id'],
//             'userId': serverCart['userId'],
//             'productId': p['id'],
//             'quantity': p['quantity'],
//             'name': p['title'],
//             'price': p['price'],
//             'image': p['thumbnail'] ?? 'assets/images/placeholder.png',
//           });
//         }).toList();

//         await _db.clearCart(ci.userId);
//         for (var item in serverItems) {
//           await _db.addToCart(item);
//         }
//         _items = serverItems;
//       } catch (e) {
//         _lastError = 'Sync error: $e';
//       }
//     } else {
//       _lastError = res.message;
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   /// Update quantity: PUT then sync SQLite
//   Future<void> updateQuantity(int id, int qty, int userId) async {
//     _isLoading = true;
//     _lastError = null;
//     notifyListeners();

//     final res = await _api.put('carts/$id', body: {'quantity': qty});
//     if (res.success) {
//       try {
//         await _db.updateCartItemQuantity(id, qty);
//         _items = await _db.getCartItems(userId);
//       } catch (e) {
//         _lastError = 'Local update failed: $e';
//       }
//     } else {
//       _lastError = res.message;
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   /// Remove item: DELETE then sync SQLite
//   Future<void> removeItem(int id, int userId) async {
//     _isLoading = true;
//     _lastError = null;
//     notifyListeners();

//     final res = await _api.delete('carts/$id');
//     if (res.success) {
//       try {
//         await _db.removeFromCart(id);
//         _items = await _db.getCartItems(userId);
//       } catch (e) {
//         _lastError = 'Local remove failed: $e';
//       }
//     } else {
//       _lastError = res.message;
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   /// Clear cart: DELETE all then sync SQLite
//   Future<void> clearCart(int userId) async {
//     _isLoading = true;
//     _lastError = null;
//     notifyListeners();

//     final res = await _api.delete('carts/user/$userId');
//     if (res.success) {
//       try {
//         await _db.clearCart(userId);
//         _items.clear();
//       } catch (e) {
//         _lastError = 'Local clear failed: $e';
//       }
//     } else {
//       _lastError = res.message;
//     }

//     _isLoading = false;
//     notifyListeners();
//   }
// }
// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../utils/database_helper.dart';

class CartProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _lastError;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  double get total => _items.fold(0.0, (sum, i) => sum + i.total);
  String? get lastError => _lastError;

  /// Load cart items locally from SQLite
  Future<void> loadCart(int userId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _items = await _db.getCartItems(userId);
    } catch (e) {
      _lastError = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add item to cart locally in SQLite
  Future<void> addToCart(CartItem ci) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _db.addToCart(ci);
      _items = await _db.getCartItems(ci.userId);
    } catch (e) {
      _lastError = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update quantity of a cart item
  Future<void> updateQuantity(int id, int quantity, int userId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _db.updateCartItemQuantity(id, quantity);
      _items = await _db.getCartItems(userId);
    } catch (e) {
      _lastError = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Remove a single item from cart
  Future<void> removeItem(int id, int userId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _db.removeFromCart(id);
      _items = await _db.getCartItems(userId);
    } catch (e) {
      _lastError = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear entire cart for a user
  Future<void> clearCart(int userId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _db.clearCart(userId);
      _items.clear();
    } catch (e) {
      _lastError = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
