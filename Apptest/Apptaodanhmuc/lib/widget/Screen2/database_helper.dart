import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  // Hàm mở cơ sở dữ liệu
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Hàm khởi tạo cơ sở dữ liệu
  _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'devices.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Hàm tạo bảng
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT
      )
    ''');
  }

  // Thêm thiết bị vào bảng
  Future<void> insertDevice(String category, String name) async {
    final db = await database;
    await db.insert(
      'devices',
      {'category': category, 'name': name},
      conflictAlgorithm: ConflictAlgorithm.replace, // Nếu thiết bị trùng tên sẽ thay thế
    );
  }

  // Lấy thiết bị theo danh mục
  Future<List<String>> getDevicesForCategory(String category) async {
    final db = await database;
    final results = await db.query(
      'devices',
      where: 'category = ?',
      whereArgs: [category],
    );
    return results.map((e) => e['name'] as String).toList();
  }

  // Xóa thiết bị theo tên
  Future<void> deleteDevice(String name) async {
    final db = await database;
    await db.delete(
      'devices',
      where: 'name = ?',
      whereArgs: [name],
    );
  }
}
