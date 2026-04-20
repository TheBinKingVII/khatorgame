class DealsEntity {
  const DealsEntity({
    required this.dealId,
    required this.title,
    required this.thumb,
    required this.salePrice,
    required this.normalPrice,
    required this.savings,
  });

  final String dealId;
  final String title;
  final String thumb;
  final String salePrice;
  final String normalPrice;
  final String savings;

  String get savingsAsPercent =>
      double.tryParse(savings)?.toStringAsFixed(0) ?? '0';
}

class DealsDetailEntity {
  const DealsDetailEntity({
    required this.storeId,
    required this.title,
    required this.thumb,
    required this.salePrice,
    required this.retailPrice,
    required this.steamRatingText,
    required this.metacriticScore,
    required this.metacriticLink,
    required this.cheapestHistoricalPrice,
  });

  final String storeId;
  final String title;
  final String thumb;
  final String salePrice;
  final String retailPrice;
  final String steamRatingText;
  final String metacriticScore;
  final String metacriticLink;
  final String cheapestHistoricalPrice;
}

class StoreEntity {
  const StoreEntity({
    required this.storeId,
    required this.storeName,
  });

  final int storeId;
  final String storeName;
}

class GameSearchEntity {
  const GameSearchEntity({
    required this.gameId,
    required this.external,
    required this.thumb,
    required this.cheapest,
    required this.cheapestDealId,
    required this.steamAppId,
  });

  final String gameId;
  final String external;
  final String thumb;
  final String cheapest;
  final String cheapestDealId;
  final String? steamAppId;
}
