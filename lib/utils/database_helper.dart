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
    String path = join(await getDatabasesPath(), 'plant_store.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT NOT NULL,
        image TEXT NOT NULL
      )
    ''');

    // Create cart table
    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Insert sample products
    await _insertSampleProducts(db);
  }

  Future<void> _insertSampleProducts(Database db) async {
    List<Map<String, dynamic>> sampleProducts = [
      {
        'name': 'Monstera Deliciosa',
        'price': 29.99,
        'description': 'The Swiss Cheese Plant is famous for its quirky natural leaf holes. A vibrant addition to any room.',
        'image': 'assets/images/monstera.png',
      },
      {
        'name': 'Snake Plant',
        'price': 19.99,
        'description': 'One of the most tolerant houseplants that helps purify indoor air. Perfect for beginners.',
        'image': 'assets/images/snake_plant.png',
      },
      {
        'name': 'Peace Lily',
        'price': 24.99,
        'description': 'Elegant white flowers and glossy leaves. Excellent air purifier and relatively easy to care for.',
        'image': 'assets/images/peace_lily.png',
      },
      {
        'name': 'Fiddle Leaf Fig',
        'price': 49.99,
        'description': 'Popular indoor tree with large, violin-shaped leaves that can grow up to 10 feet tall.',
        'image': 'assets/images/fiddle_leaf.png',
      },
      {
        'name': 'Pothos',
        'price': 15.99,
        'description': 'Fast-growing vine with heart-shaped leaves. Nearly indestructible and perfect for hanging baskets.',
        'image': 'assets/images/pothos.png',
      },
      {
        'name': 'Aloe Vera',
        'price': 12.99,
        'description': 'Medicinal plant with thick, fleshy leaves filled with gel. Great for soothing skin irritations.',
        'image': 'assets/images/aloe_vera.png',
      },
    ];

    for (var product in sampleProducts) {
      await db.insert('products', product);
    }
  }

  // User methods
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String email, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<bool> checkUserExists(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Product methods
  Future<List<Product>> getAllProducts() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('products');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProduct(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertProduct(Product product) async {
    Database db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    Database db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cart methods
  Future<List<CartItem>> getCartItems(int userId) async {
    Database db = await database;
    
    // Join cart and products tables to get product details
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.id, c.userId, c.productId, c.quantity, p.name, p.price, p.image
      FROM cart c
      INNER JOIN products p ON c.productId = p.id
      WHERE c.userId = ?
    ''', [userId]);
    
    return result.map((map) => CartItem.fromMap(map)).toList();
  }

  Future<int> addToCart(CartItem cartItem) async {
    Database db = await database;
    
    // Check if the product is already in the cart
    List<Map<String, dynamic>> existingItem = await db.query(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [cartItem.userId, cartItem.productId],
    );
    
    if (existingItem.isNotEmpty) {
      // Update quantity if product already in cart
      int currentQuantity = existingItem.first['quantity'];
      return await db.update(
        'cart',
        {'quantity': currentQuantity + cartItem.quantity},
        where: 'id = ?',
        whereArgs: [existingItem.first['id']],
      );
    } else {
      // Add new item to cart
      return await db.insert('cart', cartItem.toMap());
    }
  }

  Future<int> updateCartItemQuantity(int id, int quantity) async {
    Database db = await database;
    return await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> removeFromCart(int id) async {
    Database db = await database;
    return await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearCart(int userId) async {
    Database db = await database;
    return await db.delete(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}

