import '../../../domain/auth/entities/session.dart';
import '../../../domain/auth/entities/user_type.dart';
import 'user_dto.dart';

/// Parses the full auth response (`token` + `user` sub-object +
/// top-level approval/verification flags) and converts it to a
/// domain [Session].
class SessionDto {
  const SessionDto._({
    required this.token,
    required this.user,
    required this.requiresApproval,
    required this.requiresVerification,
  });

  factory SessionDto.fromJson(Map<String, Object?> json) {
    final rawUser = json['user'];
    final userMap = rawUser is Map<String, Object?>
        ? rawUser
        : <String, Object?>{};
    return SessionDto._(
      token: (json['token'] ?? '').toString(),
      user: UserDto.fromJson(userMap),
      requiresApproval: json['requires_approval'] == true,
      requiresVerification: json['requires_verification'] == true,
    );
  }

  final String token;
  final UserDto user;
  final bool requiresApproval;
  final bool requiresVerification;

  Session toDomain() {
    final userType = UserType.fromApiValue(user.userTypeApi) ?? UserType.renter;
    return Session(
      token: token,
      userId: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      userType: userType,
      companyName: user.companyName,
      preferredLanguage: user.preferredLanguage,
      regionId: user.regionId,
      cityId: user.cityId,
      requiresApproval: requiresApproval,
      requiresVerification: requiresVerification,
      rawUserJson: user.raw,
    );
  }
}
