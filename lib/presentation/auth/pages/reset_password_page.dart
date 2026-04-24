import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/auth/auth_failure_reason.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_form_scaffold.dart';
import '../../widgets/app_password_field.dart';
import '../../widgets/app_primary_button.dart';
import '../auth_error_messages.dart';
import '../cubits/reset_password/reset_password_cubit.dart';
import '../cubits/reset_password/reset_password_state.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ResetPasswordCubit>().submit(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listenWhen: (_, curr) => curr is ResetPasswordSucceeded,
      listener: (ctx, state) {
        if (state is ResetPasswordSucceeded) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(ctx.tr('password_reset_success'))),
          );
          Navigator.of(ctx).popUntil((r) => r.isFirst);
        }
      },
      builder: (ctx, state) {
        final isLoading = state is ResetPasswordSubmitting;
        final failureMessage = state is ResetPasswordFailed
            ? failureReasonToMessage(ctx, state.reason,
                op: AuthOperation.login)
            : null;

        return AppFormScaffold(
          titleKey: 'reset_password',
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
              ctx.tr('new_password'),
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            AppPasswordField(
              controller: _passwordController,
              labelKey: 'password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return ctx.tr('required_field');
                }
                if (value.length < 6) {
                  return ctx.tr('password_min_length');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppPasswordField(
              controller: _confirmController,
              labelKey: 'confirm_password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return ctx.tr('required_field');
                }
                if (value != _passwordController.text) {
                  return ctx.tr('passwords_not_match');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppErrorBanner(message: failureMessage),
            const SizedBox(height: 16),
            AppPrimaryButton(
              labelKey: 'reset_password',
              isLoading: isLoading,
              onPressed: _onSubmitPressed,
            ),
          ],
        );
      },
    );
  }
}
