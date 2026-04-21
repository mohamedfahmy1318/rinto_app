import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class ApiService {
  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    try {
      var uri = Uri.parse('${AppConstants.baseUrl}/$endpoint');
      if (params != null && params.isNotEmpty) {
        uri = uri.replace(
          queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
        );
      }

      debugPrint('API GET: $uri');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );
      debugPrint('API GET Response: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('API GET Error: $e');
      return ApiResponse(success: false, message: e.toString());
    }
  }

  static Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/$endpoint');
      debugPrint('API POST: $uri');
      debugPrint('API POST Body: $body');
      debugPrint('API POST Headers: $_headers');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );
      debugPrint('API POST Response: ${response.statusCode}');
      debugPrint('API POST Response Body: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      debugPrint('API POST Error: $e');
      return ApiResponse(success: false, message: 'فشل الاتصال بالخادم');
    }
  }

  static Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  static Future<ApiResponse> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/$endpoint');
      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  static ApiResponse _handleResponse(http.Response response) {
    debugPrint('API Response Status: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}');

    try {
      final data = jsonDecode(response.body);

      // Build error message including validation errors
      String message = data['message'] ?? '';
      if (data['errors'] != null && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          message = errors.values.first.toString();
        }
      }

      // Translate common API error messages
      message = _translateMessage(message);

      return ApiResponse(
        success: data['success'] == true,
        message: message,
        data: data['data'],
        pagination: data['pagination'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('API Response Parse Error: $e');
      // If status is 2xx, consider it success even if parsing failed
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          message: 'تمت العملية بنجاح',
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        message: 'فشل الاتصال بالخادم: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  static String _translateMessage(String message) {
    final translations = {
      'You already have a pending request for this plan':
          'لديك طلب معلق بالفعل لهذه الباقة. يرجى انتظار الموافقة أو إلغاء الطلب السابق.',
      'You already have a pending request for this category':
          'لديك طلب معلق بالفعل لهذه الفئة. يرجى انتظار الموافقة أو إلغاء الطلب السابق.',
      'Plan not found': 'الباقة غير موجودة',
      'Plan ID is required': 'معرف الباقة مطلوب',
      'Subscription request submitted successfully':
          'تم إرسال طلب الاشتراك بنجاح',
      'Only pending requests can be cancelled':
          'يمكن إلغاء الطلبات المعلقة فقط',
      'Request not found': 'الطلب غير موجود',
      'Request cancelled successfully': 'تم إلغاء الطلب بنجاح',
    };

    for (final entry in translations.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }
    return message;
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? pagination;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.pagination,
    this.statusCode,
  });
}
