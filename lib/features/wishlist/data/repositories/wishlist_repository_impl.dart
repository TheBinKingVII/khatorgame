import 'package:khatorgame/core/services/session_service.dart';

import '../../domain/entities/wishlist_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_data_source.dart';
import '../datasources/wishlist_remote_data_source.dart';
import '../models/wishlist_model.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({
    required WishlistRemoteDataSource remoteDataSource,
    required WishlistLocalDataSource localDataSource,
    SessionService? sessionService,
  }) : _remote = remoteDataSource,
       _local = localDataSource,
       _session = sessionService ?? SessionService.instance;

  final WishlistRemoteDataSource _remote;
  final WishlistLocalDataSource _local;
  final SessionService _session;

  String? get _userId => _session.userId;

  @override
  Future<void> syncFromRemote() async {
    final String? userId = _userId;
    if (userId == null) {
      throw StateError('Belum login');
    }
    final List<WishlistItemModel> remote = await _remote.fetchAll(userId);
    await _local.replaceAllForUser(userId, remote);
  }

  @override
  Future<List<WishlistItemEntity>> getLocalItems() async {
    final String? userId = _userId;
    if (userId == null) {
      return <WishlistItemEntity>[];
    }
    return _local.getItemsForUser(userId);
  }

  @override
  Future<bool> isInWishlist(String dealId) async {
    final String? userId = _userId;
    if (userId == null) {
      return false;
    }
    return _local.contains(userId, dealId);
  }

  @override
  Future<void> addItem({
    required String dealId,
    required String title,
    required String price,
    required String imageUrl,
  }) async {
    final String? userId = _userId;
    if (userId == null) {
      throw StateError('Belum login');
    }
    await _remote.insertItem(
      userId: userId,
      dealId: dealId,
      title: title,
      price: price,
      imageUrl: imageUrl,
    );
    final WishlistItemModel model = WishlistItemModel(
      dealId: dealId,
      title: title,
      price: price,
      imageUrl: imageUrl,
      createdAt: DateTime.now().toUtc(),
    );
    await _local.upsertItem(userId, model);
  }

  @override
  Future<void> removeItem(String dealId) async {
    final String? userId = _userId;
    if (userId == null) {
      throw StateError('Belum login');
    }
    await _remote.deleteItem(userId, dealId);
    await _local.deleteItem(userId, dealId);
  }

  @override
  Future<void> clearLocalForUser(String userId) async {
    await _local.clearForUser(userId);
  }
}
