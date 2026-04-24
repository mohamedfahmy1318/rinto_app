import 'package:dio/dio.dart';

import '../../domain/locations/city.dart';
import '../../domain/locations/locations_repository.dart';
import '../../domain/locations/region.dart';
import 'dtos/city_dto.dart';
import 'dtos/region_dto.dart';
import 'locations_remote_datasource.dart';

class LocationsRepositoryImpl implements LocationsRepository {
  const LocationsRepositoryImpl({required LocationsRemoteDataSource dataSource})
    : _dataSource = dataSource;

  final LocationsRemoteDataSource _dataSource;

  @override
  Future<List<Region>> fetchRegions() async {
    try {
      final raw = await _dataSource.fetchRegions();
      return raw
          .map((json) => RegionDto.fromJson(json).toDomain())
          .toList(growable: false);
    } on DioException catch (e) {
      throw LocationsException(e);
    }
  }

  @override
  Future<List<City>> fetchCities() async {
    try {
      final raw = await _dataSource.fetchCities();
      return raw
          .map((json) => CityDto.fromJson(json).toDomain())
          .toList(growable: false);
    } on DioException catch (e) {
      throw LocationsException(e);
    }
  }
}
