import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('carcare.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 9, // ✅ bumped version so tyrePressure column gets created
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        contact TEXT NOT NULL,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
        profileImage TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        vehicleType TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        mileage INTEGER NOT NULL,
        chassisNumber TEXT NOT NULL,
        plateNumber TEXT NOT NULL,
        fuelType TEXT NOT NULL
      )
    ''');

    // ✅ FIXED: commas + tyrePressure column
    await db.execute('''
      CREATE TABLE services(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicleId INTEGER NOT NULL,
        serviceType TEXT NOT NULL,
        date TEXT NOT NULL,
        mileage INTEGER NOT NULL,
        oilAmount REAL,
        tyrePressure REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ✅ Dev-friendly: recreate tables when schema changes
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS vehicles');
    await db.execute('DROP TABLE IF EXISTS services');
    await _createDB(db, newVersion);
  }

  // ==========================
  // USER METHODS
  // ==========================

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) return result.first;
    return null;
  }

  // ==========================
  // VEHICLE METHODS
  // ==========================

  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await instance.database;
    return await db.insert('vehicles', vehicle.toMap());
  }

  Future<List<Vehicle>> getVehicles(int userId) async {
    final db = await instance.database;

    final result = await db.query(
      'vehicles',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    return result.map((e) => Vehicle.fromMap(e)).toList();
  }

  Future<int> deleteVehicle(int id) async {
    final db = await instance.database;
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================
  // SERVICE METHODS
  // ==========================

  Future<int> insertService(Map<String, dynamic> service) async {
    final db = await instance.database;
    return await db.insert('services', service);
  }

  Future<List<Map<String, dynamic>>> getServices(int vehicleId) async {
    final db = await instance.database;

    return await db.query(
      'services',
      where: 'vehicleId = ?',
      whereArgs: [vehicleId],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteService(int id) async {
    final db = await instance.database;
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }
  Future<int> updateVehicle(Vehicle vehicle) async {
  final db = await instance.database;
  return await db.update(
    'vehicles',
    vehicle.toMap(),
    where: 'id = ?',
    whereArgs: [vehicle.id],
  );
}
}