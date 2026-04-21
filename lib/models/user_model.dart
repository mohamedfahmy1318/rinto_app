class UserModel {
  final int id;
  final String name;
  final String? companyName;
  final String email;
  final String phone;
  final String userType;
  final String? profileImage;
  final bool isVerifiedPhone;
  final bool isVerifiedEmail;
  final bool isTrusted;
  final String preferredLanguage;
  final int? regionId;
  final int? cityId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    this.companyName,
    required this.email,
    required this.phone,
    required this.userType,
    this.profileImage,
    this.isVerifiedPhone = false,
    this.isVerifiedEmail = false,
    this.isTrusted = false,
    this.preferredLanguage = 'ar',
    this.regionId,
    this.cityId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      companyName: json['company_name'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'] ?? 'renter',
      profileImage: json['profile_image'],
      isVerifiedPhone:
          json['is_verified_phone'] == 1 || json['is_verified_phone'] == true,
      isVerifiedEmail:
          json['is_verified_email'] == 1 || json['is_verified_email'] == true,
      isTrusted: json['is_trusted'] == 1 || json['is_trusted'] == true,
      preferredLanguage: json['preferred_language'] ?? 'ar',
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
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'email': email,
      'phone': phone,
      'user_type': userType,
      'profile_image': profileImage,
      'is_verified_phone': isVerifiedPhone,
      'is_verified_email': isVerifiedEmail,
      'is_trusted': isTrusted,
      'preferred_language': preferredLanguage,
      'region_id': regionId,
      'city_id': cityId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Any registered user can create listings (subscription required for activation)
  bool get canCreatePropertyListing => true;
  bool get canCreateCarListing => true;
  bool get canCreateListing => true;
}
