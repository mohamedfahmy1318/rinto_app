import 'package:equatable/equatable.dart';

import '../../../../domain/auth/auth_failure_reason.dart';
import '../../../../domain/auth/entities/session.dart';
import '../../../../domain/locations/city.dart';
import '../../../../domain/locations/region.dart';

/// Every variant carries the loaded regions/cities + loading flag so
/// the register page can keep rendering the location pickers while a
/// submit is in flight.
sealed class RegisterState extends Equatable {
  const RegisterState({
    required this.regions,
    required this.cities,
    required this.isLocationsLoading,
  });

  final List<Region> regions;
  final List<City> cities;
  final bool isLocationsLoading;

  @override
  List<Object?> get props => [regions, cities, isLocationsLoading];
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial({
    super.regions = const [],
    super.cities = const [],
    super.isLocationsLoading = true,
  });

  RegisterInitial copyWith({
    List<Region>? regions,
    List<City>? cities,
    bool? isLocationsLoading,
  }) {
    return RegisterInitial(
      regions: regions ?? this.regions,
      cities: cities ?? this.cities,
      isLocationsLoading: isLocationsLoading ?? this.isLocationsLoading,
    );
  }
}

final class RegisterLocationsFailed extends RegisterState {
  const RegisterLocationsFailed({
    required super.regions,
    required super.cities,
    this.cause,
  }) : super(isLocationsLoading: false);

  final Object? cause;

  @override
  List<Object?> get props => [...super.props, cause];
}

final class RegisterSubmitting extends RegisterState {
  const RegisterSubmitting({
    required super.regions,
    required super.cities,
  }) : super(isLocationsLoading: false);
}

final class RegisterSucceededAuthenticated extends RegisterState {
  const RegisterSucceededAuthenticated({
    required super.regions,
    required super.cities,
    required this.session,
  }) : super(isLocationsLoading: false);

  final Session session;

  @override
  List<Object?> get props => [...super.props, session];
}

final class RegisterPendingApprovalState extends RegisterState {
  const RegisterPendingApprovalState({
    required super.regions,
    required super.cities,
    required this.message,
  }) : super(isLocationsLoading: false);

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}

final class RegisterNeedsVerificationState extends RegisterState {
  const RegisterNeedsVerificationState({
    required super.regions,
    required super.cities,
    required this.message,
  }) : super(isLocationsLoading: false);

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}

final class RegisterFailed extends RegisterState {
  const RegisterFailed({
    required super.regions,
    required super.cities,
    required this.reason,
  }) : super(isLocationsLoading: false);

  final AuthFailureReason reason;

  @override
  List<Object?> get props => [...super.props, reason];
}
