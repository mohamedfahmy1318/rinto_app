class PlanModel {
  final int id;
  final String category;
  final String nameAr;
  final String nameEn;
  final String nameHe;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionHe;
  final String planType;
  final int? listingsCount;
  final bool isUnlimited;
  final int durationDays;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final String currency;
  final String? badge;
  final bool isFeatured;
  final String? iosProductId;
  final String? androidProductId;

  PlanModel({
    required this.id,
    required this.category,
    required this.nameAr,
    required this.nameEn,
    required this.nameHe,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionHe,
    required this.planType,
    this.listingsCount,
    this.isUnlimited = false,
    required this.durationDays,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.currency = 'ILS',
    this.badge,
    this.isFeatured = false,
    this.iosProductId,
    this.androidProductId,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      category: json['category'] ?? 'properties',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameHe: json['name_he'] ?? '',
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      descriptionHe: json['description_he'],
      planType: json['plan_type'] ?? 'single',
      listingsCount: json['listings_count'] != null
          ? int.tryParse(json['listings_count'].toString())
          : null,
      isUnlimited: json['is_unlimited'] == 1 || json['is_unlimited'] == true,
      durationDays: json['duration_days'] is String
          ? int.parse(json['duration_days'])
          : (json['duration_days'] ?? 30),
      price: double.tryParse(json['price'].toString()) ?? 0,
      originalPrice: json['original_price'] != null
          ? double.tryParse(json['original_price'].toString())
          : null,
      discountPercent: json['discount_percent'] != null
          ? int.tryParse(json['discount_percent'].toString())
          : null,
      currency: json['currency'] ?? 'ILS',
      badge: json['badge'],
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      iosProductId: json['ios_product_id'],
      androidProductId: json['android_product_id'],
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

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  String getListingsText(String lang) {
    if (isUnlimited) {
      return lang == 'ar'
          ? 'غير محدود'
          : (lang == 'he' ? 'ללא הגבלה' : 'Unlimited');
    }
    return '$listingsCount ${lang == 'ar' ? 'إعلانات' : (lang == 'he' ? 'מודעות' : 'listings')}';
  }
}
