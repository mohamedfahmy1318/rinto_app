class ListingTypeModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String nameHe;
  final String slug;
  final String? icon;

  ListingTypeModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameHe,
    required this.slug,
    this.icon,
  });

  factory ListingTypeModel.fromJson(Map<String, dynamic> json) {
    return ListingTypeModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameHe: json['name_he'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'],
    );
  }

  String getName(String lang) {
    switch (lang) {
      case 'he':
        return nameHe;
      case 'en':
        return nameEn;
      default:
        return nameAr;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_he': nameHe,
      'slug': slug,
      'icon': icon,
    };
  }
}
