import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rento_go/core/localization/app_localizations.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/presentation/auth/cubits/forgot_password/forgot_password_cubit.dart';
import 'package:rento_go/presentation/auth/cubits/forgot_password/forgot_password_state.dart';
import 'package:rento_go/presentation/auth/pages/forgot_password_page.dart';

class _MockForgotPasswordCubit extends MockCubit<ForgotPasswordState>
    implements ForgotPasswordCubit {}

Widget _app(_MockForgotPasswordCubit cubit) {
  return MaterialApp(
    supportedLocales: const [Locale('ar'), Locale('he'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    locale: const Locale('ar'),
    home: BlocProvider<ForgotPasswordCubit>.value(
      value: cubit,
      child: const ForgotPasswordPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'renders the phone field + send-code button in Initial state',
    (tester) async {
      final cubit = _MockForgotPasswordCubit();
      when(() => cubit.state).thenReturn(const ForgotPasswordInitial());
      whenListen(
        cubit,
        Stream<ForgotPasswordState>.value(const ForgotPasswordInitial()),
        initialState: const ForgotPasswordInitial(),
      );

      await tester.pumpWidget(_app(cubit));
      await tester.pump();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    },
  );

  testWidgets(
    'renders the localized error banner when state is Failed',
    (tester) async {
      final cubit = _MockForgotPasswordCubit();
      const failed = ForgotPasswordFailed(AuthFailureReason.invalidPhone);
      when(() => cubit.state).thenReturn(failed);
      whenListen(
        cubit,
        Stream<ForgotPasswordState>.value(failed),
        initialState: failed,
      );

      await tester.pumpWidget(_app(cubit));
      await tester.pump();

      expect(find.text('رقم الهاتف غير صالح'), findsOneWidget);
    },
  );
}
