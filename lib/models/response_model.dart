// lib/models/response_model.dart
import 'dart:convert' show jsonDecode;
import 'package:flutter/rendering.dart' show debugPrint;
import 'package:http/http.dart' show Response;

class ResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final dynamic body;

  const ResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.body,
  });

  factory ResponseModel.fromMap(Response response) {
    final statusCode = response.statusCode;
    final contentType = response.headers['content-type'] ?? '';
    final snippet = response.body.length > 200
        ? response.body.substring(0, 200)
        : response.body;
    
    debugPrint('🔄 Status code: $statusCode');
    debugPrint('🔄 Content-Type: $contentType');
    debugPrint('🔄 Body snippet: $snippet');

    // إذا لم يكن JSON، نعيد كائن بفشل بدل أن نرمي
    if (!contentType.contains('application/json')) {
      return ResponseModel(
        success: false,
        statusCode: statusCode,
        message: 'Server error: expected JSON but got HTML',
        body: null,
      );
    }

    // خلاف ذلك نحاول فكّ JSON
    dynamic parsed;
    try {
      parsed = jsonDecode(response.body);
    } catch (e) {
      return ResponseModel(
        success: false,
        statusCode: statusCode,
        message: 'Invalid JSON response',
        body: null,
      );
    }

    final msg = (parsed is Map<String, dynamic> && parsed['message'] is String)
        ? parsed['message'] as String
        : '';

    return ResponseModel(
      success: statusCode >= 200 && statusCode < 300,
      statusCode: statusCode,
      message: msg.isNotEmpty ? msg : 'OK',
      body: parsed,
    );
  }
}
