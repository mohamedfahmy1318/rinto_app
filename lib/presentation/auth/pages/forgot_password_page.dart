import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_form_scaffold.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../auth_error_messages.dart';
import '../auth_routes.dart';
import '../cubits/forgot_password/forgot_password_cubit.dart';
import '../cubits/forgot_password/forgot_password_state.dart';
import '../../../domain/auth/auth_failure_reason.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotPasswordCubit>().submit(
      _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (_, curr) => curr is ForgotPasswordSucceeded,
      listener: (ctx, state) {
        if (state is ForgotPasswordSucceeded) {
          Navigator.pushReplacement(ctx, otpRoute(phone: state.phone));
        }
      },
      builder: (ctx, state) {
        final isLoading = state is ForgotPasswordSubmitting;
        final failureMessage = state is ForgotPasswordFailed
            ? failureReasonToMessage(ctx, state.reason,
                op: AuthOperation.login)
            : null;

        return AppFormScaffold(
          titleKey: 'forgot_password',
          formKey: _formKey,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.lock_reset,
              size: 80,
              color: Theme.of(ctx).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              ctx.tr('reset_password'),
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ctx.tr('forgot_password_subtitle'),
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            AppTextField(
              controller: _phoneController,
              labelKey: 'phone',
              hintText: '+972501234567',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return ctx.tr('required_field');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppErrorBanner(message: failureMessage),
            const SizedBox(height: 16),
            AppPrimaryButton(
              labelKey: 'send_code',
              isLoading: isLoading,
              onPressed: _onSubmitPressed,
            ),
          ],
        );
      },
    );
  }
}
