import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:rento_go/core/localization/app_localizations.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/domain/auth/entities/session.dart';
import 'package:rento_go/presentation/auth/cubits/register/register_cubit.dart';
import 'package:rento_go/presentation/auth/cubits/register/register_state.dart';
import 'package:rento_go/presentation/auth/pages/register_page.dart';
import 'package:rento_go/providers/app_provider.dart';
import 'package:rento_go/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRegisterCubit extends MockCubit<RegisterState>
    implements RegisterCubit {}

class _FakeAuthProvider extends AuthProvider {
  @override
  Future<void> hydrateFromSession(Session session) async {}
}

Widget _app(_MockRegisterCubit cubit) {
  return MaterialApp(
    supportedLocales: const [Locale('ar'), Locale('he'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    locale: const Locale('ar'),
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => _FakeAuthProvider(),
        ),
        ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
      ],
      child: BlocProvider<RegisterCubit>.value(
        value: cubit,
        child: const RegisterPage(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'renders user-type chips, name/email/phone fields, and the submit button',
    (tester) async {
      final cubit = _MockRegisterCubit();
      when(() => cubit.state).thenReturn(const RegisterInitial(
        regions: [],
        cities: [],
        isLocationsLoading: false,
      ));
      whenListen(cubit,
          Stream<RegisterState>.fromIterable(const [
            RegisterInitial(
              regions: [],
              cities: [],
              isLocationsLoading: false,
            ),
          ]),
          initialState: const RegisterInitial(
            regions: [],
            cities: [],
            isLocationsLoading: false,
          ));

      await tester.pumpWidget(_app(cubit));
      await tester.pump();

      // User-type chips are rendered (4 of them).
      expect(find.byType(ChoiceChip), findsNWidgets(4));
      // Core text fields present (name, email, phone, password × 2).
      expect(find.byType(TextFormField), findsAtLeastNWidgets(5));
    },
  );

  testWidgets(
    'renders the localized error banner when state is RegisterFailed',
    (tester) async {
      final cubit = _MockRegisterCubit();
      const failed = RegisterFailed(
        regions: [],
        cities: [],
        reason: AuthFailureReason.emailAlreadyExists,
      );
      when(() => cubit.state).thenReturn(failed);
      whenListen(
        cubit,
        Stream<RegisterState>.value(failed),
        initialState: failed,
      );

      await tester.pumpWidget(_app(cubit));
      await tester.pump();

      expect(find.text('البريد الإلكتروني مستخدم مسبقاً'), findsOneWidget);
    },
  );
}
