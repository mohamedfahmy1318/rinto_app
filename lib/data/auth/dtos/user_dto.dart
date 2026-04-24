/// Parses the `user` sub-object the backend returns inside auth responses.
///
/// Kept as a thin wrapper that knows the JSON shape. Conversion into a
/// [Session] happens inside [SessionDto] which retains the raw map so
/// the legacy provider can round-trip it.
class UserDto {
  const UserDto._(this.raw);

  factory UserDto.fromJson(Map<String, Object?> json) => UserDto._(json);

  final Map<String, Object?> raw;

  int get id {
    final value = raw['id'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String? _stringOrNull(String key) {
    final value = raw[key];
    if (value == null) return null;
    return value.toString();
  }

  String get name => _stringOrNull('name') ?? '';
  String get email => _stringOrNull('email') ?? '';
  String get phone => _stringOrNull('phone') ?? '';
  String? get companyName => _stringOrNull('company_name');
  String get userTypeApi => _stringOrNull('user_type') ?? 'renter';
  String? get preferredLanguage => _stringOrNull('preferred_language');

  int? _intOrNull(String key) {
    final value = raw[key];
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int? get regionId => _intOrNull('region_id');
  int? get cityId => _intOrNull('city_id');
}
