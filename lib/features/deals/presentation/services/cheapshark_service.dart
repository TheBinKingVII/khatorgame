import 'package:dio/dio.dart';

class CheapSharkService {
  CheapSharkService._();

  static final CheapSharkService instance = CheapSharkService._();
  static const String _baseUrl = 'https://www.cheapshark.com/api/1.0';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<CheapSharkDeal>> fetchDeals({
    required int pageNumber,
    int pageSize = 20,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/deals',
      queryParameters: <String, dynamic>{
        'storeID': 1,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((dynamic item) =>
            CheapSharkDeal.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<CheapSharkDealDetail> fetchDealDetail(String dealId) async {
    final String normalizedDealId = _normalizeDealId(dealId);
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/deals',
      queryParameters: <String, dynamic>{'id': normalizedDealId},
    );
    return CheapSharkDealDetail.fromMap(response.data as Map<String, dynamic>);
  }

  String _normalizeDealId(String dealId) {
    try {
      return Uri.decodeComponent(dealId);
    } catch (_) {
      return dealId;
    }
  }
}

class CheapSharkDeal {
  const CheapSharkDeal({
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

  factory CheapSharkDeal.fromMap(Map<String, dynamic> map) {
    return CheapSharkDeal(
      dealId: (map['dealID'] ?? '') as String,
      title: (map['title'] ?? '-') as String,
      thumb: (map['thumb'] ?? '') as String,
      salePrice: (map['salePrice'] ?? '0') as String,
      normalPrice: (map['normalPrice'] ?? '0') as String,
      savings: (map['savings'] ?? '0') as String,
    );
  }
}

class CheapSharkDealDetail {
  const CheapSharkDealDetail({
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

  factory CheapSharkDealDetail.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> gameInfo =
        map['gameInfo'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> cheapestPrice =
        map['cheapestPrice'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return CheapSharkDealDetail(
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
