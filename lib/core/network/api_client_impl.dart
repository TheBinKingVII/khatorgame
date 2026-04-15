import 'package:dio/dio.dart';
import 'api_client.dart';

class ApiClientImpl implements ApiClient {
  final Dio dio;

  ApiClientImpl(this.dio);

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    final response = await dio.get(path, queryParameters: queryParameters, options: Options(headers: headers));
    return response.data; // Langsung return data JSON-nya
  }

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final response = await dio.post(path, data: body, options: Options(headers: headers));
    return response.data;
  }

  @override
  Future<dynamic> put(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final response = await dio.put(path, data: body, options: Options(headers: headers));
    return response.data;
  }

  @override
  Future<dynamic> delete(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    final response = await dio.delete(path, data: body, options: Options(headers: headers));
    return response.data;
  }
}