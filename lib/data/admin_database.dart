import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/admin_booth_map.dart';
import '../models/admin_booth_type.dart';
import '../models/admin_event.dart';
import '../models/admin_floor_plan.dart';
import '../models/admin_reservation.dart';
import '../models/admin_user.dart';

class AdminDatabase {
  AdminDatabase._();

  static final AdminDatabase instance = AdminDatabase._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'exhibition_booth_management.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            role TEXT NOT NULL,
            password_hash TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            is_published INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE booth_types(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            available INTEGER NOT NULL,
            count INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE reservations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            email TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE floor_plans(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            image_path TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE booth_maps(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            booth_id TEXT NOT NULL,
            booth_type_id INTEGER NOT NULL,
            floor_plan_id INTEGER NOT NULL,
            x REAL NOT NULL,
            y REAL NOT NULL,
            attributes TEXT NOT NULL
          )
        ''');

        await _seed(db);
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN password_hash TEXT',
          );
          await db.update(
            'users',
            {'password_hash': _hashPassword('password123')},
            where: 'password_hash IS NULL',
          );
        }
      },
    );
  }

  Future<void> _seed(Database db) async {
    await db.insert('users', {
      'name': 'Jamil',
      'email': 'jamil@maybank.com',
      'role': 'User',
      'password_hash': _hashPassword('password123'),
    });
    await db.insert('users', {
      'name': 'Jamal',
      'email': 'jamal@google.com',
      'role': 'User',
      'password_hash': _hashPassword('password123'),
    });
    await db.insert('users', {
      'name': 'Sumbul',
      'email': 'admin@admin.com',
      'role': 'Admin',
      'password_hash': _hashPassword('admin123'),
    });

    await db.insert('events', {
      'name': 'Event 1',
      'date': '18/4/2026',
      'is_published': 1,
    });
    await db.insert('events', {
      'name': 'Event 2',
      'date': '19/5/2026',
      'is_published': 0,
    });

    await db.insert('booth_types', {
      'name': 'Standard',
      'price': 120,
      'available': 1,
      'count': 18,
    });
    await db.insert('booth_types', {
      'name': 'Corner',
      'price': 150,
      'available': 0,
      'count': 0,
    });
    await db.insert('booth_types', {
      'name': 'Premium',
      'price': 200,
      'available': 1,
      'count': 4,
    });

    await db.insert('reservations', {
      'date': '18/4/2026',
      'email': 'test@gmail.com',
      'status': 'Active',
    });
    await db.insert('reservations', {
      'date': '19/5/2026',
      'email': 'test2@gmail.com',
      'status': 'Active',
    });

    await db.insert('floor_plans', {
      'title': 'Floor Plan',
      'image_path': 'lib/image/Easy_book_logo.png',
    });

    await db.insert('booth_maps', {
      'booth_id': 'C-1',
      'booth_type_id': 1,
      'floor_plan_id': 1,
      'x': 0,
      'y': 0,
      'attributes': 'standard',
    });
  }

  Future<List<AdminUser>> fetchUsers() async {
    final db = await database;
    final rows = await db.query('users', orderBy: 'id');
    return rows.map(AdminUser.fromMap).toList();
  }

  Future<void> upsertUser(AdminUser user, {String? passwordHash}) async {
    final db = await database;
    if (user.id == null) {
      final data = user.toMap();
      data['password_hash'] =
          passwordHash ?? _hashPassword('password123');
      await db.insert('users', data);
      return;
    }
    final data = user.toMap();
    data.remove('password_hash');
    await db.update('users', data, where: 'id = ?', whereArgs: [user.id]);
    if (passwordHash != null) {
      await db.update(
        'users',
        {'password_hash': passwordHash},
        where: 'id = ?',
        whereArgs: [user.id],
      );
    }
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<AdminUser?> authenticateUser({
    required String identifier,
    required String password,
    required String role,
  }) async {
    final db = await database;
    final hash = _hashPassword(password);
    final rows = await db.query(
      'users',
      where:
          '(email = ? OR name = ?) AND role = ? AND password_hash = ?',
      whereArgs: [identifier, identifier, role, hash],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return AdminUser.fromMap(rows.first);
  }

  String hashPassword(String password) {
    return _hashPassword(password);
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<List<AdminEvent>> fetchEvents() async {
    final db = await database;
    final rows = await db.query('events', orderBy: 'id');
    return rows.map(AdminEvent.fromMap).toList();
  }

  Future<void> upsertEvent(AdminEvent event) async {
    final db = await database;
    if (event.id == null) {
      await db.insert('events', event.toMap());
      return;
    }
    await db.update('events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
  }

  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AdminBoothType>> fetchBoothTypes() async {
    final db = await database;
    final rows = await db.query('booth_types', orderBy: 'id');
    return rows.map(AdminBoothType.fromMap).toList();
  }

  Future<void> upsertBoothType(AdminBoothType type) async {
    final db = await database;
    if (type.id == null) {
      await db.insert('booth_types', type.toMap());
      return;
    }
    await db.update(
      'booth_types',
      type.toMap(),
      where: 'id = ?',
      whereArgs: [type.id],
    );
  }

  Future<void> deleteBoothType(int id) async {
    final db = await database;
    await db.delete('booth_types', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AdminReservation>> fetchReservations() async {
    final db = await database;
    final rows = await db.query('reservations', orderBy: 'id');
    return rows.map(AdminReservation.fromMap).toList();
  }

  Future<void> upsertReservation(AdminReservation reservation) async {
    final db = await database;
    if (reservation.id == null) {
      await db.insert('reservations', reservation.toMap());
      return;
    }
    await db.update(
      'reservations',
      reservation.toMap(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<void> deleteReservation(int id) async {
    final db = await database;
    await db.delete('reservations', where: 'id = ?', whereArgs: [id]);
  }

  Future<AdminFloorPlan?> fetchLatestFloorPlan() async {
    final db = await database;
    final rows = await db.query('floor_plans', orderBy: 'id DESC', limit: 1);
    if (rows.isEmpty) {
      return null;
    }
    return AdminFloorPlan.fromMap(rows.first);
  }

  Future<void> insertFloorPlan(AdminFloorPlan plan) async {
    final db = await database;
    await db.insert('floor_plans', plan.toMap());
  }

  Future<List<AdminBoothMap>> fetchBoothMaps(int floorPlanId) async {
    final db = await database;
    final rows = await db.query(
      'booth_maps',
      where: 'floor_plan_id = ?',
      whereArgs: [floorPlanId],
      orderBy: 'id DESC',
    );
    return rows.map(AdminBoothMap.fromMap).toList();
  }

  Future<void> insertBoothMap(AdminBoothMap boothMap) async {
    final db = await database;
    await db.insert('booth_maps', boothMap.toMap());
  }
}
