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
import 'package:rento_go/presentation/auth/cubits/login/login_cubit.dart';
import 'package:rento_go/presentation/auth/cubits/login/login_state.dart';
import 'package:rento_go/presentation/auth/pages/login_page.dart';
import 'package:rento_go/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

class _FakeAuthProvider extends AuthProvider {
  final List<Session> hydratedSessions = [];

  @override
  Future<void> hydrateFromSession(Session session) async {
    hydratedSessions.add(session);
  }
}

Widget _buildTestApp(
  _MockLoginCubit cubit,
  _FakeAuthProvider authProvider,
) {
  return MaterialApp(
    supportedLocales: const [Locale('ar'), Locale('he'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    locale: const Locale('ar'),
    home: ChangeNotifierProvider<AuthProvider>.value(
      value: authProvider,
      child: BlocProvider<LoginCubit>.value(
        value: cubit,
        child: const LoginPage(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('LoginPage', () {
    testWidgets(
      'submit button shows spinner while state is LoginSubmitting',
      (tester) async {
        final cubit = _MockLoginCubit();
        final auth = _FakeAuthProvider();
        when(() => cubit.state).thenReturn(const LoginSubmitting());
        whenListen(
          cubit,
          Stream<LoginState>.value(const LoginSubmitting()),
          initialState: const LoginSubmitting(),
        );

        await tester.pumpWidget(_buildTestApp(cubit, auth));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows the localized error banner when state is LoginFailed',
      (tester) async {
        final cubit = _MockLoginCubit();
        final auth = _FakeAuthProvider();
        const failed = LoginFailed(AuthFailureReason.invalidCredentials);
        when(() => cubit.state).thenReturn(failed);
        whenListen(
          cubit,
          Stream<LoginState>.value(failed),
          initialState: failed,
        );

        await tester.pumpWidget(_buildTestApp(cubit, auth));
        await tester.pump();

        // The Arabic legacy message is used verbatim in every locale v1.
        expect(
          find.text('رقم الهاتف أو كلمة المرور غير صحيحة'),
          findsOneWidget,
        );
      },
    );
  });
}
