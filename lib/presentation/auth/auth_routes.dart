import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../domain/auth/auth_repository.dart';
import '../../domain/locations/locations_repository.dart';
import 'cubits/login/login_cubit.dart';
import 'cubits/register/register_cubit.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

/// Route helper for the migrated login page. Wraps [LoginPage] in a
/// [BlocProvider] so every call site gets a fresh Cubit.
Route<dynamic> loginRoute() {
  return MaterialPageRoute(builder: (_) => loginPageWithProvider());
}

/// Widget factory — for call sites that need a custom [Route] type
/// (e.g. splash screen uses a [PageRouteBuilder] with a fade
/// transition). Wraps [LoginPage] in its [BlocProvider].
Widget loginPageWithProvider() {
  return BlocProvider(
    create: (_) => LoginCubit(repository: getIt<AuthRepository>()),
    child: const LoginPage(),
  );
}

/// Route helper for the migrated register page. Kicks off
/// `loadLocations()` on construction so the pickers are populated by
/// the time the user reaches them.
Route<dynamic> registerRoute() {
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => RegisterCubit(
        authRepository: getIt<AuthRepository>(),
        locationsRepository: getIt<LocationsRepository>(),
      )..loadLocations(),
      child: const RegisterPage(),
    ),
  );
}
