import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../roles/role.dart';

class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bichitras.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');

        // Create employees table
        await db.execute('''
          CREATE TABLE employees (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT,
            position TEXT,
            department TEXT,
            employment_type TEXT,
            work_type TEXT,
            reporting_to TEXT,
            joining_date TEXT
          )
        ''');

        // Create attendance table
        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id TEXT NOT NULL,
            check_in TEXT,
            check_out TEXT,
            date TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');

        // Insert default admin user
        await db.insert('users', {
          'id': '1',
          'name': 'Admin',
          'email': 'admin@bichitras.com',
          'password': 'admin123', // In production, use proper password hashing
          'role': 'admin'
        });
      },
    );
  }

  // User operations
  Future<User?> getUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isEmpty) return null;

    return User(
      id: maps[0]['id'],
      name: maps[0]['name'],
      email: maps[0]['email'],
      role: maps[0]['role'] == 'admin' ? Role.admin : Role.employee,
      phone: maps[0]['user']['phone'],
    );
  }

  Future<void> createUser(User user, String password) async {
    final db = await database;
    await db.insert('users', {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': password, // In production, use proper password hashing
      'role': user.role.toString().split('.').last,
    });
  }

  // Attendance operations
  Future<void> recordAttendance(String employeeId, DateTime checkIn) async {
    final db = await database;
    await db.insert('attendance', {
      'employee_id': employeeId,
      'check_in': checkIn.toIso8601String(),
      'date': DateTime.now().toIso8601String().split('T')[0],
      'status': 'present'
    });
  }

  Future<void> updateCheckOut(String employeeId, DateTime checkOut) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await db.update(
      'attendance',
      {'check_out': checkOut.toIso8601String()},
      where: 'employee_id = ? AND date = ?',
      whereArgs: [employeeId, today],
    );
  }
}
