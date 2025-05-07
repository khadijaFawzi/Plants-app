// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert' show jsonEncode;
import 'package:flutter/rendering.dart' show debugPrint;
import 'package:http/http.dart' as http;
import '../models/response_model.dart';

class ApiService {
  ApiService._();
  static ApiService instance = ApiService._();

  static const String _baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 20);

  Future<ResponseModel> get(String endPoint) async {
    debugPrint('HTTPS GET');
    final uri = _getUri(endPoint);
    debugPrint('url => $uri');
    try {
      final response = await http.get(uri).timeout(_timeout);
      return _response(response);
    } on TimeoutException catch (_) {
      debugPrint('❌ GET timeout for $uri');
      return ResponseModel(
        success: false,
        statusCode: 408,
        message: 'Request timed out (GET $endPoint)',
        body: null,
      );
    } catch (e) {
      debugPrint('❌ GET error: $e');
      return ResponseModel(
        success: false,
        statusCode: 500,
        message: 'Unexpected error: $e',
        body: null,
      );
    }
  }

  Future<ResponseModel> post(
    String endPoint, {
    Map<String, String>? parameters,
    Map<String, dynamic>? body,
  }) async {
    debugPrint('HTTPS POST');
    debugPrint('body => $body');
    final uri = _getUri(endPoint);
    try {
      final response = await http
          .post(
            uri,
            headers: _requestHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _response(response);
    } on TimeoutException catch (_) {
      debugPrint('❌ POST timeout for $uri');
      return ResponseModel(
        success: false,
        statusCode: 408,
        message: 'Request timed out (POST $endPoint)',
        body: null,
      );
    } catch (e) {
      debugPrint('❌ POST error: $e');
      return ResponseModel(
        success: false,
        statusCode: 500,
        message: 'Unexpected error: $e',
        body: null,
      );
    }
  }

  Future<ResponseModel> put(
    String endPoint, {
    Map<String, String>? parameters,
    Map<String, dynamic>? body,
  }) async {
    debugPrint('HTTPS PUT');
    debugPrint('body => $body');
    final uri = _getUri(endPoint);
    try {
      final response = await http
          .put(
            uri,
            headers: _requestHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _response(response);
    } on TimeoutException catch (_) {
      debugPrint('❌ PUT timeout for $uri');
      return ResponseModel(
        success: false,
        statusCode: 408,
        message: 'Request timed out (PUT $endPoint)',
        body: null,
      );
    } catch (e) {
      debugPrint('❌ PUT error: $e');
      return ResponseModel(
        success: false,
        statusCode: 500,
        message: 'Unexpected error: $e',
        body: null,
      );
    }
  }

  Future<ResponseModel> patch(
    String endPoint, {
    Map<String, String>? parameters,
    Map<String, dynamic>? body,
  }) async {
    debugPrint('HTTPS PATCH');
    debugPrint('body => $body');
    final uri = _getUri(endPoint);
    try {
      final response = await http
          .patch(
            uri,
            headers: _requestHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _response(response);
    } on TimeoutException catch (_) {
      debugPrint('❌ PATCH timeout for $uri');
      return ResponseModel(
        success: false,
        statusCode: 408,
        message: 'Request timed out (PATCH $endPoint)',
        body: null,
      );
    } catch (e) {
      debugPrint('❌ PATCH error: $e');
      return ResponseModel(
        success: false,
        statusCode: 500,
        message: 'Unexpected error: $e',
        body: null,
      );
    }
  }

  Future<ResponseModel> delete(
    String endPoint, {
    Map<String, String>? parameters,
    Map<String, dynamic>? body,
  }) async {
    debugPrint('HTTPS DELETE');
    debugPrint('body => $body');
    final uri = _getUri(endPoint);
    try {
      final response = await http
          .delete(
            uri,
            headers: _requestHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _response(response);
    } on TimeoutException catch (_) {
      debugPrint('❌ DELETE timeout for $uri');
      return ResponseModel(
        success: false,
        statusCode: 408,
        message: 'Request timed out (DELETE $endPoint)',
        body: null,
      );
    } catch (e) {
      debugPrint('❌ DELETE error: $e');
      return ResponseModel(
        success: false,
        statusCode: 500,
        message: 'Unexpected error: $e',
        body: null,
      );
    }
  }

  static Uri _getUri(String endPoint) {
    final uri = Uri.parse('$_baseUrl/$endPoint');
    debugPrint('url => $uri');
    return uri;
  }

  static Map<String, String> _requestHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  ResponseModel _response(http.Response response) {
    return ResponseModel.fromMap(response);
  }
}
