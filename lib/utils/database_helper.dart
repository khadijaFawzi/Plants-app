import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/cart_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'plant_store.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // products table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT NOT NULL,
        image TEXT NOT NULL
      )
    ''');

    // cart table
    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (productId) REFERENCES products(id)
      )
    ''');

    // insert sample products
    await _insertSampleProducts(db);
  }

  Future<void> _insertSampleProducts(Database db) async {
    final sample = <Map<String, dynamic>>[
      {
        'id': 1,
        'name': 'Monstera Deliciosa',
        'price': 29.99,
        'description': 'The Swiss Cheese Plant is famous for its quirky natural leaf holes. A vibrant addition to any room.',
        'image': 'assets/images/Swiss Cheese Plant.jpg',
      },
      {
        'id': 2,
        'name': 'Snake Plant',
        'price': 19.99,
        'description': 'One of the most tolerant houseplants that helps purify indoor air. Perfect for beginners.',
        'image': 'assets/images/Snake Plant.jpg',
      },
      {
        'id': 3,
        'name': 'Peace Lily',
        'price': 24.99,
        'description': 'Elegant white flowers and glossy leaves. Excellent air purifier and relatively easy to care for.',
        'image': 'assets/images/Cylindrical Snake Plant.jpg',
      },
      {
        'id': 4,
        'name': 'Fiddle Leaf Fig',
        'price': 49.99,
        'description': 'Popular indoor tree with large, violin-shaped leaves that can grow up to 10 feet tall.',
        'image': 'assets/images/Agave attenuata.jpg',
      },
      {
        'id': 5,
        'name': 'Pothos',
        'price': 15.99,
        'description': 'Fast-growing vine with heart-shaped leaves. Nearly indestructible and perfect for hanging baskets.',
        'image': 'assets/images/Ficus lyrata.jpg',
      },
      {
        'id': 6,
        'name': 'Aloe Vera',
        'price': 12.99,
        'description': 'Medicinal plant with thick, fleshy leaves filled with gel. Great for soothing skin irritations.',
        'image': 'assets/images/rosette succulent.jpg',
      },
    ];
    for (final p in sample) {
      await db.insert(
        'products',
        p,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // User methods

  /// Inserts or replaces a user entry
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<bool> checkUserExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Product methods

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Product.fromMap(maps.first) : null;
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// مسح جميع المنتجات من الجدول (clear cache)
  Future<int> clearProducts() async {
    final db = await database;
    return await db.delete('products');
  }

  // Cart methods

  Future<List<CartItem>> getCartItems(int userId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT c.id, c.userId, c.productId, c.quantity,
             p.name, p.price, p.image
      FROM cart c
      JOIN products p ON c.productId = p.id
      WHERE c.userId = ?
    ''', [userId]);
    return result.map((m) => CartItem.fromMap(m)).toList();
  }

  Future<int> addToCart(CartItem item) async {
    final db = await database;
    final exist = await db.query(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [item.userId, item.productId],
    );
    if (exist.isNotEmpty) {
      final current = exist.first['quantity'] as int;
      return await db.update(
        'cart',
        {'quantity': current + item.quantity},
        where: 'id = ?',
        whereArgs: [exist.first['id']],
      );
    } else {
      return await db.insert(
        'cart',
        item.toMap(),
      );
    }
  }

  Future<int> updateCartItemQuantity(int id, int quantity) async {
    final db = await database;
    return await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> removeFromCart(int id) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearCart(int userId) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
