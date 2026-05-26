import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Future<DatabaseHelper>? _initFuture;

  static const _databaseName = 'seeking_my_place.db';
  static const _databaseVersion = 1;

  // place_list
  static const tablePlace = 'place_list';
  static const colPlaceId = 'place_id';
  static const colPlaceName = 'place_name';
  static const colAddress = 'address';
  static const colLatitude = 'latitude';
  static const colLongitude = 'longitude';
  static const colUrl = 'url';
  static const colCategory = 'category';
  static const colIsVisited = 'is_visited';
  static const colCreatedAt = 'created_at';
  static const colUpdatedAt = 'updated_at';

  // master_table_purpose
  static const tablePurpose = 'master_table_purpose';
  static const colPurposeId = 'purpose_id';
  static const colPurposeName = 'purpose_name';

  // relation_place_purpose
  static const tableRelationPlacePurpose = 'relation_place_purpose';

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
      CREATE TABLE $tablePlace (
        $colPlaceId    TEXT    NOT NULL PRIMARY KEY,
        $colPlaceName  TEXT    NOT NULL,
        $colAddress    TEXT    NOT NULL,
        $colLatitude   REAL    NOT NULL CHECK ($colLatitude BETWEEN -90 AND 90),
        $colLongitude  REAL    NOT NULL CHECK ($colLongitude BETWEEN -180 AND 180),
        $colUrl        TEXT    NOT NULL,
        $colCategory   TEXT    NOT NULL,
        $colIsVisited  INTEGER NOT NULL DEFAULT 0,
        $colCreatedAt  TEXT    NOT NULL,
        $colUpdatedAt  TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePurpose (
        $colPurposeId   TEXT NOT NULL PRIMARY KEY,
        $colPurposeName TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableRelationPlacePurpose (
        $colPlaceId   TEXT NOT NULL,
        $colPurposeId TEXT NOT NULL,
        PRIMARY KEY ($colPlaceId, $colPurposeId),
        FOREIGN KEY ($colPlaceId)
          REFERENCES $tablePlace ($colPlaceId)
          ON DELETE CASCADE,
        FOREIGN KEY ($colPurposeId)
          REFERENCES $tablePurpose ($colPurposeId)
          ON DELETE CASCADE
      )
    ''');
  }
}
