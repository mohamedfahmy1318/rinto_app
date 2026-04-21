class BannerModel {
  final int id;
  final String title;
  final String? titleAr;
  final String? titleEn;
  final String? titleHe;
  final String? description;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionHe;
  final String bannerType; // property, car, general
  final String? thumbnail;
  final List<String> images;

  // Location
  final int? regionId;
  final int? cityId;
  final String? regionNameAr;
  final String? regionNameEn;
  final String? regionNameHe;
  final String? cityNameAr;
  final String? cityNameEn;
  final String? cityNameHe;
  final String? addressText;

  // Price
  final double? price;
  final String? priceText;
  final String currency;

  // Property specific
  final String? propertyType;
  final int? bedrooms;
  final int? bathrooms;
  final double? areaM2;
  final int? floor;

  // Car specific
  final String? carModel;
  final int? carYear;
  final String? gearbox;

  // Contact
  final String? contactPhone;
  final String? whatsapp;

  // Metadata
  final int viewsCount;
  final DateTime createdAt;

  BannerModel({
    required this.id,
    required this.title,
    this.titleAr,
    this.titleEn,
    this.titleHe,
    this.description,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionHe,
    required this.bannerType,
    this.thumbnail,
    this.images = const [],
    this.regionId,
    this.cityId,
    this.regionNameAr,
    this.regionNameEn,
    this.regionNameHe,
    this.cityNameAr,
    this.cityNameEn,
    this.cityNameHe,
    this.addressText,
    this.price,
    this.priceText,
    this.currency = 'ILS',
    this.propertyType,
    this.bedrooms,
    this.bathrooms,
    this.areaM2,
    this.floor,
    this.carModel,
    this.carYear,
    this.gearbox,
    this.contactPhone,
    this.whatsapp,
    this.viewsCount = 0,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      title: json['title'] ?? '',
      titleAr: json['title_ar'],
      titleEn: json['title_en'],
      titleHe: json['title_he'],
      description: json['description'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
      descriptionHe: json['description_he'],
      bannerType: json['banner_type'] ?? 'property',
      thumbnail: json['thumbnail'],
      images: _parseImages(json['media']),
      regionId: json['region_id'] != null
          ? (json['region_id'] is String
                ? int.tryParse(json['region_id'])
                : json['region_id'])
          : null,
      cityId: json['city_id'] != null
          ? (json['city_id'] is String
                ? int.tryParse(json['city_id'])
                : json['city_id'])
          : null,
      regionNameAr: json['region_name_ar'],
      regionNameEn: json['region_name_en'],
      regionNameHe: json['region_name_he'],
      cityNameAr: json['city_name_ar'],
      cityNameEn: json['city_name_en'],
      cityNameHe: json['city_name_he'],
      addressText: json['address_text'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      priceText: json['price_text'],
      currency: json['currency'] ?? 'ILS',
      propertyType: json['property_type'],
      bedrooms: json['bedrooms'] != null
          ? int.tryParse(json['bedrooms'].toString())
          : null,
      bathrooms: json['bathrooms'] != null
          ? int.tryParse(json['bathrooms'].toString())
          : null,
      areaM2: json['area_m2'] != null
          ? double.tryParse(json['area_m2'].toString())
          : null,
      floor: json['floor'] != null
          ? int.tryParse(json['floor'].toString())
          : null,
      carModel: json['car_model'],
      carYear: json['car_year'] != null
          ? int.tryParse(json['car_year'].toString())
          : null,
      gearbox: json['gearbox'],
      contactPhone: json['contact_phone'],
      whatsapp: json['whatsapp'],
      viewsCount: json['views_count'] != null
          ? int.tryParse(json['views_count'].toString()) ?? 0
          : 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String getPrice() {
    if (price != null && price! > 0) {
      return '${price!.toInt()} ₪';
    }
    if (priceText != null && priceText!.isNotEmpty) {
      return priceText!;
    }
    return '';
  }

  String getCityName(String lang) {
    switch (lang) {
      case 'en':
        return cityNameEn ?? cityNameAr ?? '';
      case 'he':
        return cityNameHe ?? cityNameAr ?? '';
      default:
        return cityNameAr ?? '';
    }
  }

  String getRegionName(String lang) {
    switch (lang) {
      case 'en':
        return regionNameEn ?? regionNameAr ?? '';
      case 'he':
        return regionNameHe ?? regionNameAr ?? '';
      default:
        return regionNameAr ?? '';
    }
  }

  bool get isProperty => bannerType == 'property';
  bool get isCar => bannerType == 'car';

  String getTitle(String lang) {
    switch (lang) {
      case 'en':
        return titleEn ?? titleAr ?? title;
      case 'he':
        return titleHe ?? titleAr ?? title;
      default:
        return titleAr ?? title;
    }
  }

  String getDescription(String lang) {
    switch (lang) {
      case 'en':
        return descriptionEn ?? descriptionAr ?? description ?? '';
      case 'he':
        return descriptionHe ?? descriptionAr ?? description ?? '';
      default:
        return descriptionAr ?? description ?? '';
    }
  }

  static List<String> _parseImages(dynamic media) {
    if (media == null || media is! List) return [];
    final List<String> images = [];
    for (var m in media) {
      if (m is Map) {
        String? imageUrl = m['url']?.toString();
        if (imageUrl == null || imageUrl.isEmpty) {
          final filePath = m['file_path']?.toString();
          if (filePath != null && filePath.isNotEmpty) {
            imageUrl = filePath.startsWith('http')
                ? filePath
                : 'https://rento-go.com/uploads/$filePath';
          }
        }
        if (imageUrl != null && imageUrl.isNotEmpty) {
          images.add(imageUrl);
        }
      }
    }
    return images;
  }
}
