class ListingModel {
  final int id;
  final String listingType; // 'property' or 'car'
  final String? title;
  final String? type; // property_type or usage_type
  final int regionId;
  final int cityId;
  final String? regionNameAr;
  final String? regionNameEn;
  final String? regionNameHe;
  final String? cityNameAr;
  final String? cityNameEn;
  final String? cityNameHe;
  final String priceType;
  final double? price;
  final double? priceFrom;
  final double? priceTo;
  final String currency;
  final String? thumbnail;
  final List<String> images;
  final String status;
  final bool isFavorite;
  final DateTime createdAt;

  // Property specific
  final int? bedrooms;
  final int? bathrooms;
  final double? areaM2;
  final int? floor;

  // Car specific
  final String? model;
  final String? modelAr;
  final String? modelEn;
  final String? modelHe;
  final String? gearbox;
  final bool withDriver;

  // Rental pricing (daily/weekly/monthly) - for both properties and cars
  final double? priceDaily;
  final double? priceWeekly;
  final double? priceMonthly;

  // Owner info
  final int? userId;
  final String? userName;

  // Contact info
  final String? bio;
  final String? contactPhone;
  final String? whatsapp;

  // Localized content
  final String? titleAr;
  final String? titleEn;
  final String? titleHe;
  final String? bioAr;
  final String? bioEn;
  final String? bioHe;
  final String? titleLocalized;
  final String? bioLocalized;

  // Language of user content (ar or he)
  final String language;

  // Featured listing info
  final String? badge; // gold, silver, bronze
  final bool isFeatured;
  final bool isTrusted;

  // Rejection info
  final String? rejectReason;

  // Expiry info
  final DateTime? expiresAt;

  // Rental status
  final bool isRented;

  ListingModel({
    required this.id,
    required this.listingType,
    this.title,
    this.type,
    required this.regionId,
    required this.cityId,
    this.regionNameAr,
    this.regionNameEn,
    this.regionNameHe,
    this.cityNameAr,
    this.cityNameEn,
    this.cityNameHe,
    required this.priceType,
    this.price,
    this.priceFrom,
    this.priceTo,
    this.currency = 'ILS',
    this.thumbnail,
    this.images = const [],
    required this.status,
    this.isFavorite = false,
    required this.createdAt,
    this.bedrooms,
    this.bathrooms,
    this.areaM2,
    this.floor,
    this.model,
    this.modelAr,
    this.modelEn,
    this.modelHe,
    this.gearbox,
    this.withDriver = false,
    this.priceDaily,
    this.priceWeekly,
    this.priceMonthly,
    this.userId,
    this.userName,
    this.bio,
    this.contactPhone,
    this.whatsapp,
    this.titleAr,
    this.titleEn,
    this.titleHe,
    this.bioAr,
    this.bioEn,
    this.bioHe,
    this.titleLocalized,
    this.bioLocalized,
    this.language = 'ar',
    this.badge,
    this.isFeatured = false,
    this.isTrusted = false,
    this.rejectReason,
    this.expiresAt,
    this.isRented = false,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      listingType: json['listing_type'] ?? json['type'] ?? 'property',
      title: json['title'],
      type: json['property_type'] ?? json['usage_type'] ?? json['type'],
      regionId: json['region_id'] is String
          ? int.parse(json['region_id'])
          : (json['region_id'] ?? 0),
      cityId: json['city_id'] is String
          ? int.parse(json['city_id'])
          : (json['city_id'] ?? 0),
      regionNameAr: json['region_name_ar'],
      regionNameEn: json['region_name_en'],
      regionNameHe: json['region_name_he'],
      cityNameAr: json['city_name_ar'],
      cityNameEn: json['city_name_en'],
      cityNameHe: json['city_name_he'],
      priceType: json['price_type'] ?? 'fixed',
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      priceFrom: json['price_from'] != null
          ? double.tryParse(json['price_from'].toString())
          : null,
      priceTo: json['price_to'] != null
          ? double.tryParse(json['price_to'].toString())
          : null,
      currency: json['currency'] ?? 'ILS',
      thumbnail: _fixImageUrl(json['thumbnail']),
      images: _parseImages(json['media']),
      status: json['status'] ?? 'active',
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
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
      model: json['model'],
      modelAr: json['model_ar'],
      modelEn: json['model_en'],
      modelHe: json['model_he'],
      gearbox: json['gearbox'],
      withDriver: json['with_driver'] == 1 || json['with_driver'] == true,
      priceDaily: json['price_daily'] != null
          ? double.tryParse(json['price_daily'].toString())
          : null,
      priceWeekly: json['price_weekly'] != null
          ? double.tryParse(json['price_weekly'].toString())
          : null,
      priceMonthly: json['price_monthly'] != null
          ? double.tryParse(json['price_monthly'].toString())
          : null,
      userId: json['user_id'] != null
          ? (json['user_id'] is String
                ? int.tryParse(json['user_id'])
                : json['user_id'])
          : null,
      userName: json['user_name'] ?? json['owner_name'],
      bio: json['bio'],
      contactPhone: json['contact_phone'],
      whatsapp: json['whatsapp'],
      titleAr: json['title_ar'],
      titleEn: json['title_en'],
      titleHe: json['title_he'],
      bioAr: json['bio_ar'],
      bioEn: json['bio_en'],
      bioHe: json['bio_he'],
      titleLocalized: json['title_localized'],
      bioLocalized: json['bio_localized'],
      language: json['language'] ?? 'ar',
      badge: json['badge'],
      isFeatured:
          json['is_featured'] == true ||
          json['is_featured'] == 1 ||
          json['badge'] != null,
      isTrusted: json['is_trusted'] == true || json['is_trusted'] == 1,
      rejectReason: json['reject_reason'],
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      isRented: json['is_rented'] == true || json['is_rented'] == 1,
    );
  }

  String getPrice() {
    if (priceType == 'negotiable') return 'قابل للتفاوض';
    if (priceType == 'range' && priceFrom != null && priceTo != null) {
      return '${priceFrom!.toInt()} - ${priceTo!.toInt()} ₪';
    }
    // Prefer daily price if available (for both properties and cars)
    if (priceDaily != null && priceDaily! > 0) {
      return '${priceDaily!.toInt()} ₪/يوم';
    }
    // Then monthly
    if (priceMonthly != null && priceMonthly! > 0) {
      return '${priceMonthly!.toInt()} ₪/شهر';
    }
    if (price != null) return '${price!.toInt()} ₪';
    return '';
  }

  String getLowestPrice() {
    final prices = <double>[
      if (priceDaily != null && priceDaily! > 0) priceDaily!,
      if (priceWeekly != null && priceWeekly! > 0) priceWeekly!,
      if (priceMonthly != null && priceMonthly! > 0) priceMonthly!,
      if (price != null && price! > 0) price!,
    ];
    if (prices.isEmpty) return '';
    prices.sort();
    return '${prices.first.toInt()} ₪';
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

  String getTitle(String lang) {
    // First try localized title from API
    if (titleLocalized != null && titleLocalized!.isNotEmpty) {
      return titleLocalized!;
    }
    // Then try specific language field
    switch (lang) {
      case 'en':
        return titleEn ?? titleAr ?? title ?? '';
      case 'he':
        return titleHe ?? titleAr ?? title ?? '';
      default:
        return titleAr ?? title ?? '';
    }
  }

  String getBio(String lang) {
    // First try localized bio from API
    if (bioLocalized != null && bioLocalized!.isNotEmpty) {
      return bioLocalized!;
    }
    // Then try specific language field
    switch (lang) {
      case 'en':
        return bioEn ?? bioAr ?? bio ?? '';
      case 'he':
        return bioHe ?? bioAr ?? bio ?? '';
      default:
        return bioAr ?? bio ?? '';
    }
  }

  String getModel(String lang) {
    switch (lang) {
      case 'en':
        return modelEn ?? modelAr ?? model ?? '';
      case 'he':
        return modelHe ?? modelAr ?? model ?? '';
      default:
        return modelAr ?? model ?? '';
    }
  }

  bool get isProperty => listingType == 'property';
  bool get isCar => listingType == 'car';
  bool get isActive => status == 'active' && !isExpired;
  bool get isDraft => status == 'draft';
  bool get isPending => status == 'pending_admin_review' || status == 'draft';
  bool get isRejected => status == 'rejected';
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  int get daysRemaining {
    if (expiresAt == null) return 0;
    final diff = expiresAt!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  String getStatusLabel() {
    switch (status) {
      case 'draft':
        return 'قيد المراجعة';
      case 'pending_admin_review':
        return 'قيد المراجعة';
      case 'pending_payment':
        return 'بانتظار الدفع';
      case 'active':
        return 'نشط';
      case 'paused':
        return 'متوقف';
      case 'expired':
        return 'منتهي';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  static String? _fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    // Production: URLs come from API with correct domain
    // For local dev with emulator, uncomment: return url.replaceAll('localhost', '10.0.2.2');
    return url;
  }

  static List<String> _parseImages(dynamic media) {
    if (media == null || media is! List) return [];
    final List<String> images = [];
    for (var m in media) {
      if (m is Map) {
        // Try url first (from detail API), then file_path (from list API)
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
