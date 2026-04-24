import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rento_go/data/locations/locations_remote_datasource.dart';
import 'package:rento_go/data/locations/locations_repository_impl.dart';

class _MockDataSource extends Mock implements LocationsRemoteDataSource {}

void main() {
  late _MockDataSource dataSource;
  late LocationsRepositoryImpl repo;

  setUp(() {
    dataSource = _MockDataSource();
    repo = LocationsRepositoryImpl(dataSource: dataSource);
  });

  test('fetchRegions maps DTO maps to Region entities preserving localized names',
      () async {
    when(() => dataSource.fetchRegions()).thenAnswer(
      (_) async => <Map<String, Object?>>[
        <String, Object?>{
          'id': 1,
          'name_ar': 'حيفا',
          'name_en': 'Haifa',
          'name_he': 'חיפה',
        },
        <String, Object?>{
          'id': 2,
          'name_ar': 'القدس',
        },
      ],
    );

    final regions = await repo.fetchRegions();

    expect(regions, hasLength(2));
    expect(regions[0].id, 1);
    expect(regions[0].localizedName('en'), 'Haifa');
    expect(regions[0].localizedName('he'), 'חיפה');
    expect(regions[1].localizedName('en'), 'القدس',
        reason: 'falls back to Arabic when English is missing');
  });

  test('fetchCities maps DTO maps to City entities with regionId', () async {
    when(() => dataSource.fetchCities()).thenAnswer(
      (_) async => <Map<String, Object?>>[
        <String, Object?>{
          'id': 10,
          'region_id': 1,
          'name_ar': 'عكا',
          'name_en': 'Acre',
        },
      ],
    );

    final cities = await repo.fetchCities();

    expect(cities, hasLength(1));
    expect(cities.first.id, 10);
    expect(cities.first.regionId, 1);
    expect(cities.first.localizedName('en'), 'Acre');
  });
}
