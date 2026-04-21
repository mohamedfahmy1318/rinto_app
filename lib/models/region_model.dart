class RegionModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String nameHe;
  final String slug;
  final List<CityModel> cities;

  RegionModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameHe,
    required this.slug,
    this.cities = const [],
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameHe: json['name_he'] ?? '',
      slug: json['slug'] ?? '',
      cities: json['cities'] != null
          ? (json['cities'] as List).map((c) => CityModel.fromJson(c)).toList()
          : [],
    );
  }

  String getName(String lang) {
    switch (lang) {
      case 'en':
        return nameEn;
      case 'he':
        return nameHe;
      default:
        return nameAr;
    }
  }
}

class CityModel {
  final int id;
  final int regionId;
  final String nameAr;
  final String nameEn;
  final String nameHe;
  final String slug;

  CityModel({
    required this.id,
    required this.regionId,
    required this.nameAr,
    required this.nameEn,
    required this.nameHe,
    required this.slug,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      regionId: json['region_id'] is String
          ? int.parse(json['region_id'])
          : (json['region_id'] ?? 0),
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameHe: json['name_he'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  String getName(String lang) {
    switch (lang) {
      case 'en':
        return nameEn;
      case 'he':
        return nameHe;
      default:
        return nameAr;
    }
  }
}
