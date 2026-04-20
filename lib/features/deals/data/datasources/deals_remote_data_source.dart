import 'package:dio/dio.dart';

import '../models/deals_model.dart';

class DealsRemoteDataSource {
  DealsRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
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
    int? storeId,
  }) async {
    final Map<String, dynamic> queryParameters = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      if (storeId != null) ...<String, dynamic>{'storeID': storeId},
    };

    final Response<dynamic> response = await _dio.get<dynamic>(
      '/deals',
      queryParameters: queryParameters,
    );

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((dynamic item) => DealsModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<StoreModel>> fetchActiveStores() async {
    final Response<dynamic> response = await _dio.get<dynamic>('/stores');
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((dynamic item) => StoreModel.fromMap(item as Map<String, dynamic>))
        .where((StoreModel store) => store.isActive)
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
