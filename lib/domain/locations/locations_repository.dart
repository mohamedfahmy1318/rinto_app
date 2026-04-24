import 'city.dart';
import 'region.dart';

/// Domain-level contract for location lookups.
///
/// The legacy register form loaded the full regions + cities lists
/// once and filtered client-side. This repository preserves that
/// shape; a later migration may add a parameterised `fetchCitiesFor(regionId)`
/// method as a performance optimisation.
abstract interface class LocationsRepository {
  Future<List<Region>> fetchRegions();

  Future<List<City>> fetchCities();
}

class LocationsException implements Exception {
  const LocationsException([this.cause]);
  final Object? cause;

  @override
  String toString() => 'LocationsException($cause)';
}
