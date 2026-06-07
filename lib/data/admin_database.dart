import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/admin_booth_map.dart';
import '../models/admin_booth_type.dart';
import '../models/admin_event.dart';
import '../models/admin_floor_plan.dart';
import '../models/admin_reservation.dart';
import '../models/admin_user.dart';
import '../models/exhibitor_application.dart';
import '../utils/event_dates.dart';

class AdminDatabase {
  AdminDatabase._();

  static const databaseFileName = 'exhibition_booth_management.db';
  static final AdminDatabase instance = AdminDatabase._();
  static const _seedUserRows = [
    _SeedUser(name: 'admin', email: 'admin@admin.com', role: 'Admin'),
    _SeedUser(name: 'jamal', email: 'jamal@organizer.com', role: 'Organizer'),
    _SeedUser(name: 'salman', email: 'salman@exhibitor.com', role: 'Exhibitor'),
  ];
  static const _seededTables = [
    'users',
    'events',
    'booth_types',
    'reservations',
    'floor_plans',
    'booth_maps',
    'applications',
    'application_booths',
    'application_addons',
  ];
  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = await _databasePath();
    return openDatabase(
      path,
      version: 3,
      onOpen: (db) async {
        await db.update(
          'users',
          {'role': 'Exhibitor'},
          where: 'role = ?',
          whereArgs: ['User'],
        );
      },
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
            venue TEXT NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT NOT NULL,
            is_published INTEGER NOT NULL,
            organizer_id INTEGER NOT NULL,
            block_adjacent INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE booth_types(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER NOT NULL,
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
            event_id INTEGER NOT NULL,
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
            width REAL NOT NULL,
            height REAL NOT NULL,
            status TEXT NOT NULL,
            attributes TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE applications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER NOT NULL,
            exhibitor_id INTEGER NOT NULL,
            company_name TEXT NOT NULL,
            company_desc TEXT NOT NULL,
            exhibit_desc TEXT NOT NULL,
            event_start_date TEXT NOT NULL,
            event_end_date TEXT NOT NULL,
            status TEXT NOT NULL,
            submitted_at TEXT NOT NULL,
            decision_reason TEXT,
            total_price REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE application_booths(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            application_id INTEGER NOT NULL,
            booth_map_id INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE application_addons(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            application_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            price REAL NOT NULL
          )
        ''');

        await _seed(db);
      },
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN password_hash TEXT');
          await db.update('users', {
            'password_hash': _hashPassword('password123'),
          }, where: 'password_hash IS NULL');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE events ADD COLUMN venue TEXT');
          await db.execute('ALTER TABLE events ADD COLUMN start_date TEXT');
          await db.execute('ALTER TABLE events ADD COLUMN end_date TEXT');
          await db.execute(
            'ALTER TABLE events ADD COLUMN organizer_id INTEGER',
          );
          await db.execute(
            'ALTER TABLE events ADD COLUMN block_adjacent INTEGER',
          );
          await db.execute(
            'ALTER TABLE booth_types ADD COLUMN event_id INTEGER',
          );
          await db.execute(
            'ALTER TABLE floor_plans ADD COLUMN event_id INTEGER',
          );
          await db.execute('ALTER TABLE booth_maps ADD COLUMN width REAL');
          await db.execute('ALTER TABLE booth_maps ADD COLUMN height REAL');
          await db.execute('ALTER TABLE booth_maps ADD COLUMN status TEXT');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS reservations(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              email TEXT NOT NULL,
              status TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS applications(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              event_id INTEGER NOT NULL,
              exhibitor_id INTEGER NOT NULL,
              company_name TEXT NOT NULL,
              company_desc TEXT NOT NULL,
              exhibit_desc TEXT NOT NULL,
              event_start_date TEXT NOT NULL,
              event_end_date TEXT NOT NULL,
              status TEXT NOT NULL,
              submitted_at TEXT NOT NULL,
              decision_reason TEXT,
              total_price REAL NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS application_booths(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              application_id INTEGER NOT NULL,
              booth_map_id INTEGER NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS application_addons(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              application_id INTEGER NOT NULL,
              name TEXT NOT NULL,
              price REAL NOT NULL
            )
          ''');
          await db.update('events', {
            'venue': 'THE HALL, Ampang',
            'start_date': '2026-04-18',
            'end_date': '2026-04-20',
            'organizer_id': 2,
            'block_adjacent': 1,
          }, where: 'venue IS NULL OR venue = ""');
          await db.execute(
            'UPDATE events SET start_date = date WHERE start_date IS NULL AND date IS NOT NULL',
          );
          await db.execute(
            'UPDATE events SET end_date = date WHERE end_date IS NULL AND date IS NOT NULL',
          );
          await db.update('booth_types', {
            'event_id': 1,
          }, where: 'event_id IS NULL');
          await db.update('floor_plans', {
            'event_id': 1,
          }, where: 'event_id IS NULL');
          await db.update('booth_maps', {
            'width': 0.12,
            'height': 0.12,
            'status': 'available',
          }, where: 'status IS NULL');
          await db.update(
            'users',
            {'role': 'Exhibitor'},
            where: 'role = ?',
            whereArgs: ['User'],
          );
        }
      },
    );
  }

  Future<String> _databasePath() async {
    final isFlutterTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (!isFlutterTest &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final databaseDirectory = Directory(
        p.join(Directory.current.path, 'data'),
      );
      await databaseDirectory.create(recursive: true);
      return p.join(databaseDirectory.path, databaseFileName);
    }
    final dbPath = await getDatabasesPath();
    return p.join(dbPath, databaseFileName);
  }

  Future<void> _seed(Database db) async {
    await _seedUsers(db);
    await _seedDemoData(db);
  }

  Future<void> _seedUsers(DatabaseExecutor db) async {
    for (final user in _seedUserRows) {
      await db.insert('users', {
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'password_hash': _hashPassword('password123'),
      });
    }
  }

  Future<void> _seedDemoData(DatabaseExecutor db) async {
    final organizerId =
        await _fetchUserIdByEmail(db, 'jamal@organizer.com') ?? 2;
    final exhibitorId =
        await _fetchUserIdByEmail(db, 'salman@exhibitor.com') ?? 3;

    final eventOneId = await db.insert('events', {
      'name': 'Event 1',
      'venue': 'KLCC Event Hall',
      'start_date': '2026-04-18',
      'end_date': '2026-04-25',
      'is_published': 1,
      'organizer_id': organizerId,
      'block_adjacent': 1,
    });
    final eventTwoId = await db.insert('events', {
      'name': 'Event 2',
      'venue': 'THE HALL, Ampang',
      'start_date': '2026-05-19',
      'end_date': '2026-05-21',
      'is_published': 0,
      'organizer_id': organizerId,
      'block_adjacent': 0,
    });

    final standardBoothTypeId = await db.insert('booth_types', {
      'event_id': eventOneId,
      'name': 'Standard',
      'price': 120,
      'available': 1,
      'count': 18,
    });
    await db.insert('booth_types', {
      'event_id': eventOneId,
      'name': 'Corner',
      'price': 150,
      'available': 0,
      'count': 0,
    });
    final premiumBoothTypeId = await db.insert('booth_types', {
      'event_id': eventOneId,
      'name': 'Premium',
      'price': 200,
      'available': 1,
      'count': 4,
    });

    final floorPlanId = await db.insert('floor_plans', {
      'event_id': eventOneId,
      'title': 'Floor Plan',
      'image_path': 'lib/image/Easy_book_logo.png',
    });

    final firstBoothMapId = await db.insert('booth_maps', {
      'booth_id': 'A1',
      'booth_type_id': standardBoothTypeId,
      'floor_plan_id': floorPlanId,
      'x': 0.18,
      'y': 0.35,
      'width': 0.18,
      'height': 0.18,
      'status': 'available',
      'attributes': 'standard',
    });
    await db.insert('booth_maps', {
      'booth_id': 'A5',
      'booth_type_id': standardBoothTypeId,
      'floor_plan_id': floorPlanId,
      'x': 0.42,
      'y': 0.35,
      'width': 0.18,
      'height': 0.18,
      'status': 'available',
      'attributes': 'standard',
    });
    await db.insert('booth_maps', {
      'booth_id': 'A19',
      'booth_type_id': premiumBoothTypeId,
      'floor_plan_id': floorPlanId,
      'x': 0.66,
      'y': 0.35,
      'width': 0.18,
      'height': 0.18,
      'status': 'available',
      'attributes': 'premium',
    });
    await db.insert('booth_maps', {
      'booth_id': 'C-1',
      'booth_type_id': premiumBoothTypeId,
      'floor_plan_id': floorPlanId,
      'x': 0.4,
      'y': 0.6,
      'width': 0.16,
      'height': 0.16,
      'status': 'available',
      'attributes': 'premium',
    });

    final eventTwoStandardBoothTypeId = await db.insert('booth_types', {
      'event_id': eventTwoId,
      'name': 'Standard',
      'price': 100,
      'available': 1,
      'count': 12,
    });
    final eventTwoPremiumBoothTypeId = await db.insert('booth_types', {
      'event_id': eventTwoId,
      'name': 'Premium',
      'price': 180,
      'available': 1,
      'count': 6,
    });

    final eventTwoFloorPlanId = await db.insert('floor_plans', {
      'event_id': eventTwoId,
      'title': 'Event 2 Floor Plan',
      'image_path': 'lib/image/Easy_book_logo.png',
    });

    await db.insert('booth_maps', {
      'booth_id': 'B1',
      'booth_type_id': eventTwoStandardBoothTypeId,
      'floor_plan_id': eventTwoFloorPlanId,
      'x': 0.2,
      'y': 0.28,
      'width': 0.16,
      'height': 0.16,
      'status': 'available',
      'attributes': 'standard',
    });
    await db.insert('booth_maps', {
      'booth_id': 'B2',
      'booth_type_id': eventTwoStandardBoothTypeId,
      'floor_plan_id': eventTwoFloorPlanId,
      'x': 0.44,
      'y': 0.28,
      'width': 0.16,
      'height': 0.16,
      'status': 'available',
      'attributes': 'standard',
    });
    await db.insert('booth_maps', {
      'booth_id': 'P1',
      'booth_type_id': eventTwoPremiumBoothTypeId,
      'floor_plan_id': eventTwoFloorPlanId,
      'x': 0.62,
      'y': 0.56,
      'width': 0.2,
      'height': 0.2,
      'status': 'available',
      'attributes': 'premium',
    });

    final applicationId = await db.insert('applications', {
      'event_id': eventOneId,
      'exhibitor_id': exhibitorId,
      'company_name': 'Salman Corp',
      'company_desc': 'Consumer electronics',
      'exhibit_desc': 'Smart home showcase',
      'event_start_date': '2026-04-18',
      'event_end_date': '2026-04-25',
      'status': 'Pending',
      'submitted_at': '2026-04-10',
      'decision_reason': null,
      'total_price': 2500,
    });
    await db.insert('application_booths', {
      'application_id': applicationId,
      'booth_map_id': firstBoothMapId,
    });
    await db.insert('application_addons', {
      'application_id': applicationId,
      'name': 'Extra Chair',
      'price': 100,
    });
    await db.insert('application_addons', {
      'application_id': applicationId,
      'name': 'Premium WiFi',
      'price': 100,
    });
  }

  Future<void> resetAllExceptUsers() async {
    await clearEventsAndUsersExceptAdmin();
  }

  Future<void> resetToSeedData() async {
    await clearEventsAndUsersExceptAdmin();
  }

  Future<void> clearEventsAndUsersExceptAdmin() async {
    final db = await database;
    await db.transaction((txn) async {
      final adminRows = await txn.query(
        'users',
        where: 'email = ? AND role = ?',
        whereArgs: ['admin@admin.com', 'Admin'],
        limit: 1,
      );
      await txn.delete('application_addons');
      await txn.delete('application_booths');
      await txn.delete('applications');
      await txn.delete('booth_maps');
      await txn.delete('floor_plans');
      await txn.delete('booth_types');
      await txn.delete('reservations');
      await txn.delete('events');
      await txn.delete('users');
      await _resetAutoIncrement(txn, includeUsers: true);
      if (adminRows.isNotEmpty) {
        final admin = Map<String, Object?>.from(adminRows.first);
        admin.remove('id');
        await txn.insert('users', admin);
      } else {
        await _seedAdminUser(txn);
      }
    });
  }

  Future<void> _seedAdminUser(DatabaseExecutor db) async {
    await db.insert('users', {
      'name': 'admin',
      'email': 'admin@admin.com',
      'role': 'Admin',
      'password_hash': _hashPassword('password123'),
    });
  }

  Future<int?> _fetchUserIdByEmail(DatabaseExecutor db, String email) async {
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['id'] as int?;
  }

  Future<void> _resetAutoIncrement(
    DatabaseExecutor db, {
    bool includeUsers = false,
  }) async {
    final tables = includeUsers
        ? _seededTables
        : _seededTables.where((table) => table != 'users').toList();
    final placeholders = List.filled(tables.length, '?').join(', ');
    await db.delete(
      'sqlite_sequence',
      where: 'name IN ($placeholders)',
      whereArgs: tables,
    );
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
      data['password_hash'] = passwordHash ?? _hashPassword('password123');
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
    final roles = role == 'Exhibitor' ? ['Exhibitor', 'User'] : [role];
    final rows = await db.query(
      'users',
      where:
          '(email = ? OR name = ?) AND role IN (${List.filled(roles.length, '?').join(', ')}) AND password_hash = ?',
      whereArgs: [identifier, identifier, ...roles, hash],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return AdminUser.fromMap(rows.first);
  }

  Future<bool> userExists({required String email, required String name}) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? OR name = ?',
      whereArgs: [email, name],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  String hashPassword(String password) {
    return _hashPassword(password);
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<List<AdminEvent>> fetchEvents() async {
    final db = await database;
    await _unpublishFinishedEvents(db);
    final rows = await db.query('events', orderBy: 'id');
    return rows.map(AdminEvent.fromMap).toList();
  }

  Future<AdminEvent?> fetchEventById(int id) async {
    final db = await database;
    await _unpublishFinishedEvents(db);
    final rows = await db.query('events', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) {
      return null;
    }
    return AdminEvent.fromMap(rows.first);
  }

  Future<List<AdminEvent>> fetchPublishedEvents() async {
    final db = await database;
    await _unpublishFinishedEvents(db);
    final rows = await db.query(
      'events',
      where: 'is_published = 1',
      orderBy: 'start_date',
    );
    return rows.map(AdminEvent.fromMap).toList();
  }

  Future<List<AdminEvent>> fetchOrganizerEvents(int organizerId) async {
    final db = await database;
    await _unpublishFinishedEvents(db);
    final rows = await db.query(
      'events',
      where: 'organizer_id = ?',
      whereArgs: [organizerId],
      orderBy: 'start_date DESC',
    );
    return rows.map(AdminEvent.fromMap).toList();
  }

  Future<void> upsertEvent(AdminEvent event) async {
    final db = await database;
    final data = event.toMap();
    if (eventStatusFromDates(event.startDate, event.endDate) == 'Finished') {
      data['is_published'] = 0;
    }
    if (event.id == null) {
      await db.insert('events', data);
      return;
    }
    await db.update('events', data, where: 'id = ?', whereArgs: [event.id]);
  }

  Future<void> _unpublishFinishedEvents(DatabaseExecutor db) async {
    final rows = await db.query(
      'events',
      columns: ['id', 'start_date', 'end_date', 'is_published'],
      where: 'is_published = 1',
    );

    for (final row in rows) {
      final status = eventStatusFromDates(
        row['start_date'] as String? ?? '',
        row['end_date'] as String? ?? '',
      );
      if (status == 'Finished') {
        await db.update(
          'events',
          {'is_published': 0},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }
  }

  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      final applicationRows = await txn.query(
        'applications',
        columns: ['id'],
        where: 'event_id = ?',
        whereArgs: [id],
      );
      final applicationIds = applicationRows
          .map((row) => row['id'] as int)
          .toList();

      if (applicationIds.isNotEmpty) {
        final placeholders = List.filled(applicationIds.length, '?').join(', ');
        await txn.delete(
          'application_addons',
          where: 'application_id IN ($placeholders)',
          whereArgs: applicationIds,
        );
        await txn.delete(
          'application_booths',
          where: 'application_id IN ($placeholders)',
          whereArgs: applicationIds,
        );
        await txn.delete(
          'applications',
          where: 'id IN ($placeholders)',
          whereArgs: applicationIds,
        );
      }

      final floorPlanRows = await txn.query(
        'floor_plans',
        columns: ['id'],
        where: 'event_id = ?',
        whereArgs: [id],
      );
      final floorPlanIds = floorPlanRows
          .map((row) => row['id'] as int)
          .toList();

      if (floorPlanIds.isNotEmpty) {
        final placeholders = List.filled(floorPlanIds.length, '?').join(', ');
        await txn.delete(
          'booth_maps',
          where: 'floor_plan_id IN ($placeholders)',
          whereArgs: floorPlanIds,
        );
        await txn.delete(
          'floor_plans',
          where: 'id IN ($placeholders)',
          whereArgs: floorPlanIds,
        );
      }

      await txn.delete('booth_types', where: 'event_id = ?', whereArgs: [id]);
      await txn.delete('events', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<AdminBoothType>> fetchBoothTypes() async {
    final db = await database;
    final rows = await db.query('booth_types', orderBy: 'id');
    return rows.map(AdminBoothType.fromMap).toList();
  }

  Future<List<AdminBoothType>> fetchBoothTypesForEvent(int eventId) async {
    final db = await database;
    final rows = await db.query(
      'booth_types',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'id',
    );
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
    await db.transaction((txn) async {
      final boothRows = await txn.query(
        'booth_maps',
        columns: ['id'],
        where: 'booth_type_id = ?',
        whereArgs: [id],
      );
      final boothMapIds = boothRows.map((row) => row['id'] as int).toList();

      if (boothMapIds.isNotEmpty) {
        final placeholders = List.filled(boothMapIds.length, '?').join(', ');
        await txn.delete(
          'application_booths',
          where: 'booth_map_id IN ($placeholders)',
          whereArgs: boothMapIds,
        );
        await txn.delete(
          'booth_maps',
          where: 'id IN ($placeholders)',
          whereArgs: boothMapIds,
        );
      }

      await txn.delete('booth_types', where: 'id = ?', whereArgs: [id]);
    });
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

  Future<AdminFloorPlan?> fetchFloorPlanForEvent(int eventId) async {
    final db = await database;
    final rows = await db.query(
      'floor_plans',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'id DESC',
      limit: 1,
    );
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

  Future<List<AdminBoothMap>> fetchBoothsForEvent(int eventId) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
        SELECT booth_maps.*
        FROM booth_maps
        JOIN floor_plans ON floor_plans.id = booth_maps.floor_plan_id
        WHERE floor_plans.id = (
          SELECT id
          FROM floor_plans
          WHERE event_id = ?
          ORDER BY id DESC
          LIMIT 1
        )
        ORDER BY booth_maps.booth_id
      ''',
      [eventId],
    );
    return rows.map(AdminBoothMap.fromMap).toList();
  }

  Future<void> updateBoothStatus(int boothMapId, String status) async {
    final db = await database;
    await db.update(
      'booth_maps',
      {'status': status},
      where: 'id = ?',
      whereArgs: [boothMapId],
    );
  }

  Future<void> insertBoothMap(AdminBoothMap boothMap) async {
    final db = await database;
    await db.insert('booth_maps', boothMap.toMap());
  }

  Future<int> insertApplication(ExhibitorApplication application) async {
    final db = await database;
    return db.insert('applications', application.toMap());
  }

  Future<void> insertApplicationBooth(int applicationId, int boothMapId) async {
    final db = await database;
    await db.insert('application_booths', {
      'application_id': applicationId,
      'booth_map_id': boothMapId,
    });
  }

  Future<void> insertApplicationAddon(
    int applicationId,
    String name,
    double price,
  ) async {
    final db = await database;
    await db.insert('application_addons', {
      'application_id': applicationId,
      'name': name,
      'price': price,
    });
  }

  Future<List<ExhibitorApplication>> fetchApplicationsForExhibitor(
    int exhibitorId,
  ) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
        SELECT applications.*, events.name AS event_name,
          GROUP_CONCAT(booth_maps.booth_id, ', ') AS booth_label
        FROM applications
        LEFT JOIN events ON events.id = applications.event_id
        LEFT JOIN application_booths
          ON application_booths.application_id = applications.id
        LEFT JOIN booth_maps
          ON booth_maps.id = application_booths.booth_map_id
        WHERE applications.exhibitor_id = ?
        GROUP BY applications.id
        ORDER BY applications.id DESC
      ''',
      [exhibitorId],
    );
    return rows.map(ExhibitorApplication.fromMap).toList();
  }

  Future<List<ExhibitorApplication>> fetchApplicationsForEvent(
    int eventId,
    String status,
  ) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
        SELECT applications.*, events.name AS event_name,
          GROUP_CONCAT(booth_maps.booth_id, ', ') AS booth_label
        FROM applications
        LEFT JOIN events ON events.id = applications.event_id
        LEFT JOIN application_booths
          ON application_booths.application_id = applications.id
        LEFT JOIN booth_maps
          ON booth_maps.id = application_booths.booth_map_id
        WHERE applications.event_id = ? AND applications.status = ?
        GROUP BY applications.id
        ORDER BY applications.id DESC
      ''',
      [eventId, status],
    );
    return rows.map(ExhibitorApplication.fromMap).toList();
  }

  Future<List<ExhibitorApplication>> fetchOrganizerApplications(
    int organizerId,
    String status, {
    int? eventId,
  }) async {
    final db = await database;
    final eventFilter = eventId == null ? '' : 'AND applications.event_id = ?';
    final rows = await db.rawQuery(
      '''
        SELECT applications.*, events.name AS event_name,
          GROUP_CONCAT(booth_maps.booth_id, ', ') AS booth_label
        FROM applications
        JOIN events ON events.id = applications.event_id
        LEFT JOIN application_booths
          ON application_booths.application_id = applications.id
        LEFT JOIN booth_maps
          ON booth_maps.id = application_booths.booth_map_id
        WHERE events.organizer_id = ?
          AND applications.status = ?
          $eventFilter
        GROUP BY applications.id
        ORDER BY applications.id DESC
      ''',
      eventId == null ? [organizerId, status] : [organizerId, status, eventId],
    );
    return rows.map(ExhibitorApplication.fromMap).toList();
  }

  Future<List<ExhibitorApplication>> fetchAllApplications(
    String status, {
    int? eventId,
  }) async {
    final db = await database;
    final eventFilter = eventId == null ? '' : 'AND applications.event_id = ?';
    final rows = await db.rawQuery('''
        SELECT applications.*, events.name AS event_name,
          GROUP_CONCAT(booth_maps.booth_id, ', ') AS booth_label
        FROM applications
        LEFT JOIN events ON events.id = applications.event_id
        LEFT JOIN application_booths
          ON application_booths.application_id = applications.id
        LEFT JOIN booth_maps
          ON booth_maps.id = application_booths.booth_map_id
        WHERE applications.status = ?
          $eventFilter
        GROUP BY applications.id
        ORDER BY applications.id DESC
      ''', eventId == null ? [status] : [status, eventId]);
    return rows.map(ExhibitorApplication.fromMap).toList();
  }

  Future<List<int>> fetchApplicationBoothIds(int applicationId) async {
    final db = await database;
    final rows = await db.query(
      'application_booths',
      columns: ['booth_map_id'],
      where: 'application_id = ?',
      whereArgs: [applicationId],
    );
    return rows.map((row) => row['booth_map_id'] as int).toList();
  }

  Future<void> updateApplication(ExhibitorApplication application) async {
    final db = await database;
    await db.update(
      'applications',
      application.toMap(),
      where: 'id = ?',
      whereArgs: [application.id],
    );
  }

  Future<void> updateApplicationStatus(
    int applicationId,
    String status,
    String? reason,
  ) async {
    final db = await database;
    await db.update(
      'applications',
      {'status': status, 'decision_reason': reason},
      where: 'id = ?',
      whereArgs: [applicationId],
    );
  }

  Future<void> deleteApplication(int applicationId) async {
    final db = await database;
    await db.delete(
      'application_addons',
      where: 'application_id = ?',
      whereArgs: [applicationId],
    );
    await db.delete(
      'application_booths',
      where: 'application_id = ?',
      whereArgs: [applicationId],
    );
    await db.delete(
      'applications',
      where: 'id = ?',
      whereArgs: [applicationId],
    );
  }
}

class _SeedUser {
  const _SeedUser({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;
}
