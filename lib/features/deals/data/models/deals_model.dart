import '../../domain/entities/deals_entity.dart';

class DealsModel extends DealsEntity {
  const DealsModel({
    required super.dealId,
    required super.title,
    required super.thumb,
    required super.salePrice,
    required super.normalPrice,
    required super.savings,
  });

  factory DealsModel.fromMap(Map<String, dynamic> map) {
    return DealsModel(
      dealId: (map['dealID'] ?? '') as String,
      title: (map['title'] ?? '-') as String,
      thumb: (map['thumb'] ?? '') as String,
      salePrice: (map['salePrice'] ?? '0') as String,
      normalPrice: (map['normalPrice'] ?? '0') as String,
      savings: (map['savings'] ?? '0') as String,
    );
  }
}

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.storeId,
    required super.storeName,
    required this.isActive,
  });

  final bool isActive;

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      storeId: int.tryParse((map['storeID'] ?? '').toString()) ?? 0,
      storeName: (map['storeName'] ?? '-') as String,
      isActive: (int.tryParse((map['isActive'] ?? '').toString()) ?? 0) == 1,
    );
  }
}

class DealsDetailModel extends DealsDetailEntity {
  const DealsDetailModel({
    required super.title,
    required super.thumb,
    required super.salePrice,
    required super.retailPrice,
    required super.steamRatingText,
    required super.metacriticScore,
    required super.cheapestHistoricalPrice,
  });

  factory DealsDetailModel.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> gameInfo =
        map['gameInfo'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> cheapestPrice =
        map['cheapestPrice'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return DealsDetailModel(
      title: (gameInfo['name'] ?? '-') as String,
      thumb: (gameInfo['thumb'] ?? '') as String,
      salePrice: (gameInfo['salePrice'] ?? '0') as String,
      retailPrice: (gameInfo['retailPrice'] ?? '0') as String,
      steamRatingText: (gameInfo['steamRatingText'] ?? '-') as String,
      metacriticScore: (gameInfo['metacriticScore'] ?? '-') as String,
      cheapestHistoricalPrice: (cheapestPrice['price'] ?? '0') as String,
    );
  }
}
