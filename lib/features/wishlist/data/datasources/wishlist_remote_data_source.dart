import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wishlist_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistItemModel>> fetchAll(String userId);
  Future<void> insertItem({
    required String userId,
    required String dealId,
    required String title,
    required String price,
    required String imageUrl,
  });
  Future<void> deleteItem(String userId, String dealId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  WishlistRemoteDataSourceImpl({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'wishlists';

  @override
  Future<List<WishlistItemModel>> fetchAll(String userId) async {
    final Object response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    if (response is! List) {
      return <WishlistItemModel>[];
    }
    return response
        .map(
          (dynamic row) => WishlistItemModel.fromSupabase(
            Map<String, dynamic>.from(row as Map<dynamic, dynamic>),
          ),
        )
        .toList();
  }

  @override
  Future<void> insertItem({
    required String userId,
    required String dealId,
    required String title,
    required String price,
    required String imageUrl,
  }) async {
    await _client.from(_table).insert(<String, dynamic>{
      'user_id': userId,
      'deal_id': dealId,
      'title': title,
      'price': price,
      'image_url': imageUrl,
    });
  }

  @override
  Future<void> deleteItem(String userId, String dealId) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .eq('deal_id', dealId);
  }
}
