import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/auth/auth_repository.dart';
import '../../../../domain/auth/entities/register_details.dart';
import '../../../../domain/auth/entities/register_outcome.dart';
import '../../../../domain/locations/locations_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required AuthRepository authRepository,
    required LocationsRepository locationsRepository,
  }) : _authRepository = authRepository,
       _locationsRepository = locationsRepository,
       super(const RegisterInitial());

  final AuthRepository _authRepository;
  final LocationsRepository _locationsRepository;

  /// Loads regions + cities from the backend once per Cubit instance.
  /// Reentrant-safe: concurrent calls while already loading are no-ops.
  Future<void> loadLocations() async {
    final current = state;
    if (current is RegisterInitial && !current.isLocationsLoading) {
      // Already loaded — the register page sometimes re-invokes
      // loadLocations on hot-reload; skip redundant fetches.
      return;
    }
    try {
      final regionsFuture = _locationsRepository.fetchRegions();
      final citiesFuture = _locationsRepository.fetchCities();
      final regions = await regionsFuture;
      final cities = await citiesFuture;
      emit(
        RegisterInitial(
          regions: regions,
          cities: cities,
          isLocationsLoading: false,
        ),
      );
    } catch (e) {
      emit(RegisterLocationsFailed(
        regions: current.regions,
        cities: current.cities,
        cause: e,
      ));
    }
  }

  /// Idempotent while already submitting.
  Future<void> submit(RegisterDetails details) async {
    if (state is RegisterSubmitting) return;
    final s = state;
    emit(RegisterSubmitting(regions: s.regions, cities: s.cities));
    try {
      final outcome = await _authRepository.register(details);
      switch (outcome) {
        case RegisterAuthenticated(:final session):
          emit(RegisterSucceededAuthenticated(
            regions: s.regions,
            cities: s.cities,
            session: session,
          ));
        case RegisterPendingApproval(:final message):
          emit(RegisterPendingApprovalState(
            regions: s.regions,
            cities: s.cities,
            message: message,
          ));
        case RegisterNeedsVerification(:final message):
          emit(RegisterNeedsVerificationState(
            regions: s.regions,
            cities: s.cities,
            message: message,
          ));
      }
    } on AuthException catch (e) {
      emit(RegisterFailed(
        regions: s.regions,
        cities: s.cities,
        reason: e.reason,
      ));
    }
  }

  void reset() {
    final s = state;
    emit(RegisterInitial(
      regions: s.regions,
      cities: s.cities,
      isLocationsLoading: false,
    ));
  }
}
