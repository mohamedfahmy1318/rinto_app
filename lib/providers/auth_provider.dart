import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/di/service_locator.dart';
import '../core/storage/token_reader.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && _token != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(StorageKeys.token);
    final userJson = prefs.getString(StorageKeys.user);

    if (_token != null && userJson != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson));
        ApiService.setToken(_token);
      } catch (e) {
        await logout();
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<Map<String, dynamic>> register({
    required String name,
    String? companyName,
    required String email,
    required String phone,
    required String password,
    required String userType,
    int? regionId,
    int? cityId,
  }) async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.post(
      'auth/register',
      body: {
        'name': name,
        'company_name': companyName,
        'email': email,
        'phone': phone,
        'password': password,
        'user_type': userType,
        'region_id': regionId,
        'city_id': cityId,
      },
    );

    _isLoading = false;

    if (!response.success) {
      notifyListeners();
      String errorMsg = _translateRegisterError(response.message);
      throw Exception(errorMsg);
    }

    if (response.data != null) {
      // Check if token is provided (only for renters)
      if (response.data['token'] != null) {
        await _saveAuth(response.data);
      }
      notifyListeners();
      return {
        'success': true,
        'requiresApproval': response.data['requires_approval'] == true,
        'requiresVerification': response.data['requires_verification'] == true,
        'message': response.message,
      };
    }

    notifyListeners();
    return {'success': true, 'message': response.message};
  }

  Future<bool> login({required String login, required String password}) async {
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.post(
      'auth/login',
      body: {'login': login, 'password': password},
    );

    _isLoading = false;

    if (!response.success) {
      notifyListeners();
      // Translate English error messages to Arabic
      String errorMsg = _translateLoginError(response.message);
      throw Exception(errorMsg);
    }

    if (response.data != null) {
      await _saveAuth(response.data);
      notifyListeners();
      return true;
    }

    notifyListeners();
    throw Exception('فشل تسجيل الدخول');
  }

  String _translateLoginError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('pending') || msg.contains('approval')) {
      return 'حسابك قيد المراجعة من قبل الإدارة';
    }
    if (msg.contains('blocked')) {
      return 'تم حظر حسابك';
    }
    if (msg.contains('invalid') || msg.contains('credentials')) {
      return 'رقم الهاتف أو كلمة المرور غير صحيحة';
    }
    if (msg.contains('required')) {
      return 'يرجى إدخال جميع الحقول المطلوبة';
    }
    if (message.isNotEmpty) {
      return message;
    }
    return 'فشل تسجيل الدخول';
  }

  String _translateRegisterError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('email') && msg.contains('exists')) {
      return 'البريد الإلكتروني مستخدم مسبقاً';
    }
    if (msg.contains('phone') && msg.contains('exists')) {
      return 'رقم الهاتف مستخدم مسبقاً';
    }
    if (msg.contains('email already')) {
      return 'البريد الإلكتروني مستخدم مسبقاً';
    }
    if (msg.contains('phone already')) {
      return 'رقم الهاتف مستخدم مسبقاً';
    }
    if (msg.contains('invalid email')) {
      return 'البريد الإلكتروني غير صالح';
    }
    if (msg.contains('invalid phone')) {
      return 'رقم الهاتف غير صالح';
    }
    if (msg.contains('password') && msg.contains('least')) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    if (msg.contains('required')) {
      return 'يرجى إدخال جميع الحقول المطلوبة';
    }
    if (msg.contains('validation')) {
      return 'يرجى التحقق من البيانات المدخلة';
    }
    if (message.isNotEmpty) {
      return message;
    }
    return 'فشل التسجيل';
  }

  Future<void> _saveAuth(Map<String, dynamic> data) async {
    _token = data['token'];
    _user = UserModel.fromJson(data['user']);
    ApiService.setToken(_token);
    if (getIt.isRegistered<TokenReader>()) {
      getIt<TokenReader>().setToken(_token);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, _token!);
    await prefs.setString(StorageKeys.user, jsonEncode(data['user']));

    // Save FCM token to server for push notifications (Android only for now)
    if (!kIsWeb && Platform.isAndroid) {
      await _saveFcmToken();
      await FCMService.subscribeToTopic('user_type_${_user!.userType}');
      await FCMService.subscribeToTopic('all_users');
    }
  }

  Future<void> _saveFcmToken() async {
    try {
      final fcmToken = await FCMService.getToken();
      if (fcmToken != null && _user != null) {
        await ApiService.post(
          'users/fcm-token',
          body: {'fcm_token': fcmToken, 'user_id': _user!.id},
        );
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  Future<void> logout() async {
    // Unsubscribe from topics (Android only for now)
    if (_user != null && !kIsWeb && Platform.isAndroid) {
      await FCMService.unsubscribeFromTopic('user_type_${_user!.userType}');
      await FCMService.unsubscribeFromTopic('all_users');
    }

    _user = null;
    _token = null;
    ApiService.setToken(null);
    if (getIt.isRegistered<TokenReader>()) {
      getIt<TokenReader>().clear();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.user);

    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_token == null) return;

    final response = await ApiService.get('me');
    if (response.success && response.data != null) {
      _user = UserModel.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.user, jsonEncode(response.data));
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String phone) async {
    final response = await ApiService.post(
      'auth/forgot-password',
      body: {'phone': phone},
    );
    if (!response.success) {
      throw Exception(
        response.message.isNotEmpty ? response.message : 'Failed to send OTP',
      );
    }
  }

  Future<void> verifyPhone(String phone, String otp) async {
    final response = await ApiService.post(
      'auth/verify-phone',
      body: {'phone': phone, 'otp': otp},
    );
    if (!response.success) {
      throw Exception(
        response.message.isNotEmpty ? response.message : 'Invalid OTP',
      );
    }
  }

  Future<void> resendOtp(String phone, String type) async {
    final response = await ApiService.post(
      'auth/resend-otp',
      body: {'phone': phone, 'type': type},
    );
    if (!response.success) {
      throw Exception(
        response.message.isNotEmpty ? response.message : 'Failed to resend OTP',
      );
    }
  }

  Future<void> resetPassword(String phone, String otp, String password) async {
    final response = await ApiService.post(
      'auth/reset-password',
      body: {'phone': phone, 'otp': otp, 'password': password},
    );
    if (!response.success) {
      throw Exception(
        response.message.isNotEmpty
            ? response.message
            : 'Failed to reset password',
      );
    }
  }
}
