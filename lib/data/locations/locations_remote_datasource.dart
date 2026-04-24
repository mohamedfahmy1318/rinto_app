import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';

class LocationsRemoteDataSource {
  const LocationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Map<String, Object?>>> fetchRegions() async {
    final response = await _dio.get<List<dynamic>>(ApiEndpoints.regions);
    return _asListOfMaps(response.data);
  }

  Future<List<Map<String, Object?>>> fetchCities() async {
    final response = await _dio.get<List<dynamic>>(ApiEndpoints.cities);
    return _asListOfMaps(response.data);
  }

  List<Map<String, Object?>> _asListOfMaps(List<dynamic>? data) {
    if (data == null) return const <Map<String, Object?>>[];
    return data
        .whereType<Map<String, Object?>>()
        .toList(growable: false);
  }
}
