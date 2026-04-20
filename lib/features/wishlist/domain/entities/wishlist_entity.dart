class WishlistItemEntity {
  const WishlistItemEntity({
    required this.dealId,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.createdAt,
  });

  final String dealId;
  final String title;
  final String price;
  final String imageUrl;
  final DateTime? createdAt;
}
