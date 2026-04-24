import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/auth/auth_failure_reason.dart';
import '../../../domain/auth/entities/auth_credentials.dart';
import '../../../providers/auth_provider.dart';
// Legacy-bridge: forgot-password screen is out of scope for this
// feature and still uses the legacy AuthProvider directly.
import '../../../screens/auth/forgot_password_screen.dart';
import '../../../screens/main_screen.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_form_scaffold.dart';
import '../../widgets/app_password_field.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../auth_error_messages.dart';
import '../auth_routes.dart';
import '../cubits/login/login_cubit.dart';
import '../cubits/login/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().submit(
      AuthCredentials(
        login: _phoneController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _onLoginSucceeded(LoginSucceeded state) async {
    // Legacy-bridge: push the session into AuthProvider so every
    // non-migrated consumer keeps working. See
    // specs/002-auth-login-register/contracts/legacy_bridge.contract.md.
    await context.read<AuthProvider>().hydrateFromSession(state.session);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBackground = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (_, curr) => curr is LoginSucceeded,
      listener: (ctx, state) {
        if (state is LoginSucceeded) _onLoginSucceeded(state);
      },
      builder: (ctx, state) {
        final isLoading = state is LoginSubmitting;
        final failureMessage = state is LoginFailed
            ? failureReasonToMessage(ctx, state.reason,
                op: AuthOperation.login)
            : null;

        return AppFormScaffold(
          titleKey: 'login',
          formKey: _formKey,
          children: [
            const SizedBox(height: 32),
            _LoginHeader(isDark: isDark, onBackground: onBackground),
            const SizedBox(height: 48),
            AppTextField(
              controller: _phoneController,
              labelKey: 'phone',
              hintText: '+972501234567',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            AppPasswordField(
              controller: _passwordController,
              labelKey: 'password',
              validator: _passwordValidator,
            ),
            const SizedBox(height: 8),
            _ForgotPasswordLink(),
            const SizedBox(height: 16),
            AppErrorBanner(message: failureMessage),
            const SizedBox(height: 16),
            AppPrimaryButton(
              labelKey: 'login',
              isLoading: isLoading,
              onPressed: _onSubmitPressed,
            ),
            const SizedBox(height: 24),
            _RegisterPrompt(onBackground: onBackground),
          ],
        );
      },
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) return context.tr('required_field');
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return context.tr('required_field');
    if (value.length < 6) return context.tr('password_min_length');
    return null;
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.isDark, required this.onBackground});

  final bool isDark;
  final Color onBackground;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            height: 60,
            width: 240,
            child: Image.asset(
              isDark
                  ? 'assets/images/logo_dark.png'
                  : 'assets/images/logo_light.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Builder(
          builder: (context) => Text(
            context.tr('login_subtitle'),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: onBackground),
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
          );
        },
        child: Text(context.tr('forgot_password')),
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.onBackground});

  final Color onBackground;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('no_account'),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: onBackground),
        ),
        TextButton(
          onPressed: () => Navigator.push(context, registerRoute()),
          child: Text(context.tr('register')),
        ),
      ],
    );
  }
}
