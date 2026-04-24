import 'package:equatable/equatable.dart';

import 'user_type.dart';

/// The authenticated user's session — token + identity fields.
///
/// [rawUserJson] retains the full backend `user` payload so the
/// legacy `AuthProvider.hydrateFromSession` can round-trip it into
/// SharedPreferences without dropping fields the new entity hasn't
/// named explicitly.
class Session extends Equatable {
  const Session({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.companyName,
    this.preferredLanguage,
    this.regionId,
    this.cityId,
    this.requiresApproval = false,
    this.requiresVerification = false,
    required this.rawUserJson,
  });

  final String token;
  final int userId;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final String? companyName;
  final String? preferredLanguage;
  final int? regionId;
  final int? cityId;
  final bool requiresApproval;
  final bool requiresVerification;
  final Map<String, Object?> rawUserJson;

  @override
  List<Object?> get props => [
    token,
    userId,
    name,
    email,
    phone,
    userType,
    companyName,
    preferredLanguage,
    regionId,
    cityId,
    requiresApproval,
    requiresVerification,
  ];
}
