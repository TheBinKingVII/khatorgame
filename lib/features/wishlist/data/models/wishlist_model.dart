import '../../domain/entities/wishlist_entity.dart';

class WishlistItemModel extends WishlistItemEntity {
  const WishlistItemModel({
    required super.dealId,
    required super.title,
    required super.price,
    required super.imageUrl,
    super.createdAt,
  });

  factory WishlistItemModel.fromSupabase(Map<String, dynamic> map) {
    return WishlistItemModel(
      dealId: map['deal_id'] as String,
      title: map['title'] as String,
      price: map['price'] as String,
      imageUrl: map['image_url'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  factory WishlistItemModel.fromSqlite(Map<String, dynamic> map) {
    return WishlistItemModel(
      dealId: map['deal_id'] as String,
      title: map['title'] as String,
      price: map['price'] as String,
      imageUrl: map['image_url'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int,
        isUtc: true,
      ),
    );
  }

  Map<String, dynamic> toSqliteRow(String userId) {
    final DateTime ts = createdAt ?? DateTime.now().toUtc();
    return <String, dynamic>{
      'user_id': userId,
      'deal_id': dealId,
      'title': title,
      'price': price,
      'image_url': imageUrl,
      'created_at': ts.millisecondsSinceEpoch,
    };
  }
}
