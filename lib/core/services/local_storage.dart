import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens the app SQLite file and creates the wishlist cache table.
class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  static const int _dbVersion = 1;
  static const String _dbName = 'khatorgame.db';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<void> init() async {
    await database;
  }

  Future<Database> _open() async {
    final String dbPath = await getDatabasesPath();
    final String path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE wishlist_items (
            user_id TEXT NOT NULL,
            deal_id TEXT NOT NULL,
            title TEXT NOT NULL,
            price TEXT NOT NULL,
            image_url TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            PRIMARY KEY (user_id, deal_id)
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_wishlist_user_created ON wishlist_items(user_id, created_at DESC)',
        );
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
