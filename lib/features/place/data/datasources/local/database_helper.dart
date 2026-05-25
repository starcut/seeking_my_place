import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Future<DatabaseHelper>? _initFuture;

  static const _databaseName = 'seeking_my_place.db';
  static const _databaseVersion = 1;

  final Database _db;

  DatabaseHelper._(this._db);

  static Future<DatabaseHelper> initialize() async {
    final existing = _instance;
    if (existing != null) return existing;

    final running = _initFuture;
    if (running != null) return running;

    final future = _create();
    _initFuture = future;
    return future;
  }

  static Future<DatabaseHelper> _create() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );

    final instance = DatabaseHelper._(db);
    _instance = instance;
    return instance;
  }

  Database get database => _db;

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE place_list (
        place_id    TEXT    NOT NULL PRIMARY KEY,
        place_name  TEXT    NOT NULL,
        address     TEXT    NOT NULL,
        latitude    REAL    NOT NULL CHECK (latitude BETWEEN -90 AND 90),
        longitude   REAL    NOT NULL CHECK (longitude BETWEEN -180 AND 180),
        url         TEXT    NOT NULL,
        category    TEXT    NOT NULL,
        is_visited  INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT    NOT NULL,
        updated_at  TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE master_table_purpose (
        purpose_id   TEXT NOT NULL PRIMARY KEY,
        purpose_name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE relation_place_purpose (
        place_id   TEXT NOT NULL,
        purpose_id TEXT NOT NULL,
        PRIMARY KEY (place_id, purpose_id),
        FOREIGN KEY (place_id)
          REFERENCES place_list (place_id)
          ON DELETE CASCADE,
        FOREIGN KEY (purpose_id)
          REFERENCES master_table_purpose (purpose_id)
          ON DELETE CASCADE
      )
    ''');
  }
}
