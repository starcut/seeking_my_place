import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'purpose_master_entry.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Future<DatabaseHelper>? _initFuture;

  static const _databaseName = 'seeking_my_place.db';
  static const _databaseVersion = 5;

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

  /// runApp 前に [initialize] が完了している前提で同期的にインスタンスを返す。
  static DatabaseHelper get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'DatabaseHelper は未初期化です。'
        'runApp() の前に DatabaseHelper.initialize() を await してください。',
      );
    }
    return i;
  }

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
      onUpgrade: _onUpgrade,
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

    for (final entry in masterPurposeSeedData) {
      await db.insert(tablePurpose, {
        colPurposeId: entry.id,
        colPurposeName: entry.name,
      });
    }

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

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      for (final entry in masterPurposeSeedData) {
        await db.insert(
          tablePurpose,
          {colPurposeId: entry.id, colPurposeName: entry.name},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }

    if (oldVersion < 5) {
      // masterPurposeSeedData の内容（ID形式・項目）が変わった場合に備え、
      // 既存のマスタデータを一旦全削除してから最新の内容を入れ直す。
      // ON DELETE CASCADE により、削除されたIDに紐づく relation_place_purpose も削除される。
      await db.delete(tablePurpose);
      for (final entry in masterPurposeSeedData) {
        await db.insert(tablePurpose, {
          colPurposeId: entry.id,
          colPurposeName: entry.name,
        });
      }
    }
  }
}
