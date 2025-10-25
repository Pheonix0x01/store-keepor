import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  factory DatabaseHelper() {
    return _instance;
  }
  
  DatabaseHelper._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }
  
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        imagePath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertProduct(Product product) async {
    try {
      final db = await database;
      return await db.insert('products', product.toMap());
    } catch (e) {
      print('Error inserting product: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        orderBy: 'createdAt DESC',
      );
      return List.generate(maps.length, (i) {
        return Product.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<Product?> getProduct(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Product.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  Future<int> updateProduct(Product product) async {
    try {
      final db = await database;
      return await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<int> deleteProduct(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<bool> productNameExists(String name, {int? excludeId}) async {
    try {
      final db = await database;
      final result = await db.query(
        'products',
        where: excludeId != null ? 'LOWER(name) = ? AND id != ?' : 'LOWER(name) = ?',
        whereArgs: excludeId != null ? [name.toLowerCase(), excludeId] : [name.toLowerCase()],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking product name: $e');
      return false;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'createdAt DESC',
      );
      return List.generate(maps.length, (i) {
        return Product.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  Future<List<Product>> getLowStockProducts(int threshold) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'quantity < ?',
        whereArgs: [threshold],
        orderBy: 'quantity ASC',
      );
      return List.generate(maps.length, (i) {
        return Product.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error fetching low stock products: $e');
      return [];
    }
  }

}