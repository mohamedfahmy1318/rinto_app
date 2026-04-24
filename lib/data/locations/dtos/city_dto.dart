import '../../../domain/locations/city.dart';

class CityDto {
  const CityDto._(this._json);

  factory CityDto.fromJson(Map<String, Object?> json) => CityDto._(json);

  final Map<String, Object?> _json;

  int _intAt(String key) {
    final value = _json[key];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? _str(String key) => _json[key]?.toString();

  City toDomain() => City(
    id: _intAt('id'),
    regionId: _intAt('region_id'),
    nameAr: _str('name_ar') ?? _str('name') ?? '',
    nameEn: _str('name_en'),
    nameHe: _str('name_he'),
  );
}
