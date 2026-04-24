import 'package:equatable/equatable.dart';

import 'user_type.dart';

/// Registration input. [companyName] is required iff
/// [userType.isLandlord] is true. [regionId] / [cityId] are optional
/// but when both are provided the city MUST belong to the region —
/// enforced by the `CityPicker` widget, not by this entity.
class RegisterDetails extends Equatable {
  const RegisterDetails({
    required this.name,
    this.companyName,
    required this.email,
    required this.phone,
    required this.password,
    required this.userType,
    this.regionId,
    this.cityId,
  });

  final String name;
  final String? companyName;
  final String email;
  final String phone;
  final String password;
  final UserType userType;
  final int? regionId;
  final int? cityId;

  @override
  List<Object?> get props => [
    name,
    companyName,
    email,
    phone,
    password,
    userType,
    regionId,
    cityId,
  ];
}
