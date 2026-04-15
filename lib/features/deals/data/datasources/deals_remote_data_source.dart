import 'package:dio/dio.dart';

import '../models/deals_model.dart';

class DealsRemoteDataSource {
  DealsRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  static const String _baseUrl = 'https://www.cheapshark.com/api/1.0';
  final Dio _dio;

  Future<List<DealsModel>> fetchDeals({
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
        .map((dynamic item) => DealsModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<DealsDetailModel> fetchDealDetail(String dealId) async {
    final String normalizedDealId = _normalizeDealId(dealId);
    final Response<dynamic> response = await _dio.get<dynamic>(
      '/deals',
      queryParameters: <String, dynamic>{'id': normalizedDealId},
    );
    return DealsDetailModel.fromMap(response.data as Map<String, dynamic>);
  }

  String _normalizeDealId(String dealId) {
    try {
      return Uri.decodeComponent(dealId);
    } catch (_) {
      return dealId;
    }
  }
}
