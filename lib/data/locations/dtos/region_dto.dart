import '../../../domain/locations/region.dart';

class RegionDto {
  const RegionDto._(this._json);

  factory RegionDto.fromJson(Map<String, Object?> json) => RegionDto._(json);

  final Map<String, Object?> _json;

  int get _id {
    final value = _json['id'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? _str(String key) => _json[key]?.toString();

  Region toDomain() => Region(
    id: _id,
    nameAr: _str('name_ar') ?? _str('name') ?? '',
    nameEn: _str('name_en'),
    nameHe: _str('name_he'),
  );
}
