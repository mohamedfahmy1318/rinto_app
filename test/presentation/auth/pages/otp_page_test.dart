import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rento_go/core/localization/app_localizations.dart';
import 'package:rento_go/domain/auth/auth_failure_reason.dart';
import 'package:rento_go/presentation/auth/cubits/otp/otp_cubit.dart';
import 'package:rento_go/presentation/auth/cubits/otp/otp_state.dart';
import 'package:rento_go/presentation/auth/pages/otp_page.dart';

class _MockOtpCubit extends MockCubit<OtpState> implements OtpCubit {}

const _phone = '+972501234567';

Widget _app(_MockOtpCubit cubit) {
  return MaterialApp(
    supportedLocales: const [Locale('ar'), Locale('he'), Locale('en')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    locale: const Locale('ar'),
    home: BlocProvider<OtpCubit>.value(
      value: cubit,
      child: const OtpPage(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders 6 OTP digit boxes + resend link + verify button',
      (tester) async {
    final cubit = _MockOtpCubit();
    when(() => cubit.state).thenReturn(const OtpInitial(phone: _phone));
    whenListen(
      cubit,
      Stream<OtpState>.value(const OtpInitial(phone: _phone)),
      initialState: const OtpInitial(phone: _phone),
    );

    await tester.pumpWidget(_app(cubit));
    await tester.pump();

    // 6 OTP input boxes from AppOtpCodeField
    expect(find.byType(TextFormField), findsNWidgets(6));
    // Verify button + resend TextButton
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets(
    'renders the Arabic invalidOtp banner when state is OtpFailed',
    (tester) async {
      final cubit = _MockOtpCubit();
      const failed = OtpFailed(
        phone: _phone,
        reason: AuthFailureReason.invalidOtp,
      );
      when(() => cubit.state).thenReturn(failed);
      whenListen(
        cubit,
        Stream<OtpState>.value(failed),
        initialState: failed,
      );

      await tester.pumpWidget(_app(cubit));
      await tester.pump();

      expect(find.text('رمز التحقق غير صحيح'), findsOneWidget);
    },
  );
}
