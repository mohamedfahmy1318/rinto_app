import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/auth/auth_failure_reason.dart';
import '../../../domain/auth/entities/register_details.dart';
import '../../../domain/auth/entities/user_type.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/main_screen.dart';
import '../../widgets/app_error_banner.dart';
import '../../widgets/app_form_scaffold.dart';
import '../../widgets/app_password_field.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../auth_error_messages.dart';
import '../cubits/register/register_cubit.dart';
import '../cubits/register/register_state.dart';
import '../widgets/city_picker.dart';
import '../widgets/region_picker.dart';
import '../widgets/terms_checkbox.dart';
import '../widgets/user_type_selector.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  UserType _userType = UserType.renter;
  int? _regionId;
  int? _cityId;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showSnackBar(context.tr('must_accept_terms'));
      return;
    }
    if (_userType.isLandlord && (_regionId == null || _cityId == null)) {
      _showSnackBar(context.tr('select_location_required'));
      return;
    }
    context.read<RegisterCubit>().submit(
      RegisterDetails(
        name: _nameController.text.trim(),
        companyName: _userType.isLandlord
            ? _companyController.text.trim()
            : null,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        userType: _userType,
        regionId: _userType.isLandlord ? _regionId : null,
        cityId: _userType.isLandlord ? _cityId : null,
      ),
    );
  }

  Future<void> _onAuthenticated(RegisterSucceededAuthenticated state) async {
    await context.read<AuthProvider>().hydrateFromSession(state.session);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  Future<void> _onPendingApproval(RegisterPendingApprovalState state) async {
    await _showOutcomeDialog(
      title: context.tr('account_under_review'),
      message: state.message.isNotEmpty
          ? state.message
          : context.tr('auth_error_account_pending'),
    );
  }

  Future<void> _onNeedsVerification(
    RegisterNeedsVerificationState state,
  ) async {
    await _showOutcomeDialog(
      title: context.tr('verification_required'),
      message: state.message.isNotEmpty
          ? state.message
          : context.tr('verification_required_body'),
    );
  }

  Future<void> _showOutcomeDialog({
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (_, curr) =>
          curr is RegisterSucceededAuthenticated ||
          curr is RegisterPendingApprovalState ||
          curr is RegisterNeedsVerificationState,
      listener: (ctx, state) {
        if (state is RegisterSucceededAuthenticated) _onAuthenticated(state);
        if (state is RegisterPendingApprovalState) _onPendingApproval(state);
        if (state is RegisterNeedsVerificationState) {
          _onNeedsVerification(state);
        }
      },
      builder: (ctx, state) {
        final isLoading = state is RegisterSubmitting;
        final failureMessage = state is RegisterFailed
            ? failureReasonToMessage(ctx, state.reason,
                op: AuthOperation.register)
            : null;

        return AppFormScaffold(
          titleKey: 'register',
          formKey: _formKey,
          children: [
            const SizedBox(height: 16),
            Text(
              context.tr('register_subtitle'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            UserTypeSelector(
              value: _userType,
              onChanged: (v) => setState(() {
                _userType = v;
                if (!v.isLandlord) {
                  _regionId = null;
                  _cityId = null;
                }
              }),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              labelKey: 'full_name',
              prefixIcon: Icons.person_outline,
              validator: _requiredValidator,
            ),
            if (_userType.isLandlord) ...[
              const SizedBox(height: 16),
              AppTextField(
                controller: _companyController,
                labelKey: 'company_name',
                prefixIcon: Icons.business_outlined,
                validator: _requiredValidator,
              ),
            ],
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              labelKey: 'email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              validator: _emailValidator,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              labelKey: 'phone',
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
            const SizedBox(height: 16),
            AppPasswordField(
              controller: _confirmController,
              labelKey: 'confirm_password',
              validator: _confirmValidator,
            ),
            if (_userType.isLandlord) ...[
              const SizedBox(height: 16),
              RegionPicker(
                regions: state.regions,
                selected: _regionId,
                onChanged: (v) => setState(() {
                  _regionId = v;
                  _cityId = null;
                }),
              ),
              const SizedBox(height: 16),
              CityPicker(
                cities: state.cities,
                selectedRegionId: _regionId,
                selected: _cityId,
                onChanged: (v) => setState(() => _cityId = v),
              ),
            ],
            const SizedBox(height: 16),
            TermsCheckbox(
              value: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v),
            ),
            const SizedBox(height: 16),
            AppErrorBanner(message: failureMessage),
            const SizedBox(height: 16),
            AppPrimaryButton(
              labelKey: 'register',
              isLoading: isLoading,
              onPressed: _onSubmitPressed,
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.tr('required_field');
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.tr('required_field');
    }
    if (!value.contains('@') || !value.contains('.')) {
      return context.tr('invalid_email');
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return context.tr('required_field');
    if (value.length < 6) return context.tr('password_min_length');
    return null;
  }

  String? _confirmValidator(String? value) {
    if (value == null || value.isEmpty) return context.tr('required_field');
    if (value != _passwordController.text) {
      return context.tr('passwords_do_not_match');
    }
    return null;
  }
}
