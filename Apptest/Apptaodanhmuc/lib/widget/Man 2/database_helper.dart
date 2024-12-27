import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('devices.db');
    return _database!;
  }
  //Lấy đối tượng Database
  /*
  Phần này kiểm tra xem _database đã được khởi tạo chưa. 
  Nếu chưa, nó sẽ gọi _initDB() để khởi tạo cơ sở dữ liệu và trả về một đối tượng Database.
  */
  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();  // Lấy đường dẫn đến cơ sở dữ liệu
    final path = join(dbPath, dbName);         // Kết hợp đường dẫn với tên cơ sở dữ liệu
    return openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE devices(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )
      ''');
    });
  }
  
  //Thêm thiết bị
  Future<void> insertDevice(String name) async {
    final db = await instance.database;
    await db.insert('devices', {'name': name});
  }
  //Lấy danh sách thiết bị
  Future<List<Map<String, dynamic>>> getDevices() async {
    final db = await instance.database;
    return await db.query('devices');
  }
  //Hàm này xóa một thiết bị dựa trên id. Câu lệnh SQL DELETE sẽ xóa bản ghi có id tương ứng với giá trị được truyền vào.
  Future<void> deleteDevice(int id) async {
    final db = await instance.database;
    await db.delete('devices', where: 'id = ?', whereArgs: [id]);
  }
}
