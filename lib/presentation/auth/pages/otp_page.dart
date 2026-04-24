import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/auth/auth_failure_reason.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_form_scaffold.dart';
import '../../widgets/app_otp_code_field.dart';
import '../../widgets/app_primary_button.dart';
import '../auth_error_messages.dart';
import '../auth_routes.dart';
import '../cubits/otp/otp_cubit.dart';
import '../cubits/otp/otp_state.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _code = '';

  void _onSubmitPressed(BuildContext ctx) {
    if (_code.length != 6) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text(ctx.tr('enter_complete_code'))),
      );
      return;
    }
    ctx.read<OtpCubit>().submit(_code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listenWhen: (_, curr) =>
          curr is OtpSucceeded ||
          curr is OtpResendSucceeded ||
          curr is OtpResendFailed,
      listener: (ctx, state) {
        if (state is OtpSucceeded) {
          Navigator.pushReplacement(
            ctx,
            resetPasswordRoute(phone: state.phone, code: state.code),
          );
        } else if (state is OtpResendSucceeded) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(ctx.tr('code_resent'))),
          );
        } else if (state is OtpResendFailed) {
          final msg = failureReasonToMessage(ctx, state.reason,
              op: AuthOperation.login);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      },
      builder: (ctx, state) {
        final isLoading = state is OtpSubmitting;
        final failureMessage = state is OtpFailed
            ? failureReasonToMessage(ctx, state.reason,
                op: AuthOperation.login)
            : null;

        return AppFormScaffold(
          titleKey: 'verify_code',
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.message,
              size: 80,
              color: Theme.of(ctx).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              ctx.tr('enter_otp'),
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${ctx.tr('code_sent_to')} ${state.phone}',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            AppOtpCodeField(
              onChanged: (value) => setState(() => _code = value),
              onCompleted: (value) => _onSubmitPressed(ctx),
            ),
            const SizedBox(height: 16),
            AppErrorBanner(message: failureMessage),
            const SizedBox(height: 16),
            AppPrimaryButton(
              labelKey: 'verify',
              isLoading: isLoading,
              onPressed: () => _onSubmitPressed(ctx),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ctx.tr('didnt_receive_code'),
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: state is OtpResending
                      ? null
                      : () => ctx.read<OtpCubit>().resend(),
                  child: Text(ctx.tr('resend')),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
