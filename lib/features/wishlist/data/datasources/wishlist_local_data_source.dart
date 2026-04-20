import 'package:khatorgame/core/services/local_storage.dart';
import 'package:sqflite/sqflite.dart';

import '../models/wishlist_model.dart';

class WishlistLocalDataSource {
  WishlistLocalDataSource({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService.instance;

  final LocalStorageService _storage;

  Future<List<WishlistItemModel>> getItemsForUser(String userId) async {
    final Database db = await _storage.database;
    final List<Map<String, dynamic>> rows = await db.query(
      'wishlist_items',
      where: 'user_id = ?',
      whereArgs: <Object>[userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(WishlistItemModel.fromSqlite).toList();
  }

  Future<bool> contains(String userId, String dealId) async {
    final Database db = await _storage.database;
    final List<Map<String, dynamic>> rows = await db.query(
      'wishlist_items',
      columns: <String>['deal_id'],
      where: 'user_id = ? AND deal_id = ?',
      whereArgs: <Object>[userId, dealId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> upsertItem(String userId, WishlistItemModel item) async {
    final Database db = await _storage.database;
    await db.insert(
      'wishlist_items',
      item.toSqliteRow(userId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteItem(String userId, String dealId) async {
    final Database db = await _storage.database;
    await db.delete(
      'wishlist_items',
      where: 'user_id = ? AND deal_id = ?',
      whereArgs: <Object>[userId, dealId],
    );
  }

  Future<void> replaceAllForUser(
    String userId,
    List<WishlistItemModel> items,
  ) async {
    final Database db = await _storage.database;
    await db.transaction((Transaction txn) async {
      await txn.delete(
        'wishlist_items',
        where: 'user_id = ?',
        whereArgs: <Object>[userId],
      );
      for (final WishlistItemModel item in items) {
        await txn.insert(
          'wishlist_items',
          item.toSqliteRow(userId),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> clearForUser(String userId) async {
    final Database db = await _storage.database;
    await db.delete(
      'wishlist_items',
      where: 'user_id = ?',
      whereArgs: <Object>[userId],
    );
  }
}
