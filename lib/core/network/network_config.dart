import '../constants/app_constants.dart';

/// Single source of truth for the shared Dio client's base options.
///
/// Any change to base URL or timeout values happens here (or, for the
/// URL, in [AppConstants.baseUrl] which this class reads through).
abstract final class NetworkConfig {
  NetworkConfig._();

  static String get baseUrl => AppConstants.baseUrl;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const Map<String, String> defaultHeaders = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
