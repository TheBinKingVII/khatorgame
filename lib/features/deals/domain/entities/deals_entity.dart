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
    required this.title,
    required this.thumb,
    required this.salePrice,
    required this.retailPrice,
    required this.steamRatingText,
    required this.metacriticScore,
    required this.cheapestHistoricalPrice,
  });

  final String title;
  final String thumb;
  final String salePrice;
  final String retailPrice;
  final String steamRatingText;
  final String metacriticScore;
  final String cheapestHistoricalPrice;
}
