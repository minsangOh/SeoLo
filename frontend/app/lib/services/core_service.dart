import 'package:app/models/core/issue_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

class CoreService {
  final _dio = Dio.Dio();
  final _storage = const FlutterSecureStorage();
  final baseUrl = dotenv.env['API_URL'] ?? '';

  CoreService() {
    _dio.interceptors.add(Dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'token');
        String? companyCode = await _storage.read(key: 'companyCode');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          options.headers['Company-Code'] = companyCode;
        }
        return handler.next(options);
      },
    ));
    _dio.interceptors.add(LoggingInterceptor());
  }

  ///////////////////////// issue //////////////////////////////////
  Future<Map<String, dynamic>> coreIssue(CoreIssueModel coreIssueModel) async {
    try {
      Dio.Response response = await _dio.post(
        '$baseUrl/core/ISSUE', data: coreIssueModel.toJson(),
      );
      if (response.statusCode == 200) {
        debugPrint(response.data);
        return {'success': true, };
      } else {
        return {'success': false};
      }
    } on Dio.DioException catch (e) {
      debugPrint(e.message);
      return {'success': false, 'statusCode': e.response?.statusCode};
    }
  }
}

class LoggingInterceptor extends Dio.Interceptor {
  @override
  void onRequest(
      Dio.RequestOptions options, Dio.RequestInterceptorHandler handler) {
    debugPrint("REQUEST[${options.method}] => PATH: ${options.path}");
    debugPrint("Request Header: ${options.headers}");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Dio.Response response, Dio.ResponseInterceptorHandler handler) {
    debugPrint(
        "RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}");
    super.onResponse(response, handler);
  }

  @override
  void onError(Dio.DioError err, Dio.ErrorInterceptorHandler handler) {
    debugPrint(
        "ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}");
    super.onError(err, handler);
  }
}