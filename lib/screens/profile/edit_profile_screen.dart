import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();

  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _cities = [];
  int? _selectedRegionId;
  int? _selectedCityId;
  bool _isLoading = false;
  bool _isLoadingRegions = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRegions();
  }

  void _loadUserData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = auth.user?.name ?? '';
    _companyNameController.text = auth.user?.companyName ?? '';
  }

  Future<void> _loadRegions() async {
    final response = await ApiService.get('regions');
    if (response.success && response.data != null) {
      setState(() {
        _regions = List<Map<String, dynamic>>.from(response.data);
        _isLoadingRegions = false;
      });

      // Load user's current region and city
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user?.regionId != null) {
        _selectedRegionId = auth.user!.regionId;
        await _loadCities(_selectedRegionId!);
        if (auth.user?.cityId != null) {
          _selectedCityId = auth.user!.cityId;
        }
      }
    } else {
      setState(() => _isLoadingRegions = false);
    }
  }

  Future<void> _loadCities(int regionId) async {
    final response = await ApiService.get('regions/$regionId/cities');
    if (response.success && response.data != null) {
      setState(() {
        _cities = List<Map<String, dynamic>>.from(response.data);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await ApiService.post(
      'users/update-profile',
      body: {
        'name': _nameController.text.trim(),
        'company_name': _companyNameController.text.trim(),
        'region_id': _selectedRegionId,
        'city_id': _selectedCityId,
      },
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (response.success) {
        await Provider.of<AuthProvider>(context, listen: false).refreshUser();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('profile_updated_successfully')),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : context.tr('update_failed'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('edit_profile'))),
      body: _isLoadingRegions
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: context.tr('name'),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.tr('name_required');
                        }
                        if (value.trim().length < 2) {
                          return context.tr('name_too_short');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Company Name (only for office users)
                    if (auth.user?.userType == 'office') ...[
                      TextFormField(
                        controller: _companyNameController,
                        decoration: InputDecoration(
                          labelText: context.tr('company_name'),
                          prefixIcon: const Icon(Icons.business_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Region Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedRegionId,
                      decoration: InputDecoration(
                        labelText: context.tr('region'),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _regions.map((region) {
                        String name = region['name_ar'] ?? '';
                        if (locale == 'en') {
                          name = region['name_en'] ?? region['name_ar'];
                        }
                        if (locale == 'he') {
                          name = region['name_he'] ?? region['name_ar'];
                        }
                        return DropdownMenuItem<int>(
                          value: region['id'],
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRegionId = value;
                          _selectedCityId = null;
                          _cities = [];
                        });
                        if (value != null) {
                          _loadCities(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // City Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCityId,
                      decoration: InputDecoration(
                        labelText: context.tr('city'),
                        prefixIcon: const Icon(Icons.location_city_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _cities.map((city) {
                        String name = city['name_ar'] ?? '';
                        if (locale == 'en') {
                          name = city['name_en'] ?? city['name_ar'];
                        }
                        if (locale == 'he') {
                          name = city['name_he'] ?? city['name_ar'];
                        }
                        return DropdownMenuItem<int>(
                          value: city['id'],
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCityId = value);
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.tr('save')),
                    ),
                    const SizedBox(height: 32),

                    // Security Section
                    Text(
                      context.tr('security_settings'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Change Password
                    _buildSecurityOption(
                      context,
                      icon: Icons.lock_outline,
                      title: context.tr('change_password'),
                      onTap: () => _showChangePasswordDialog(context),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Change Email
                    _buildSecurityOption(
                      context,
                      icon: Icons.email_outlined,
                      title: context.tr('change_email'),
                      subtitle: auth.user?.email ?? '',
                      onTap: () => _showChangeEmailDialog(context),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),

                    // Change Phone
                    _buildSecurityOption(
                      context,
                      icon: Icons.phone_outlined,
                      title: context.tr('change_phone'),
                      subtitle: auth.user?.phone ?? '',
                      onTap: () => _showChangePhoneDialog(context),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSecurityOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: AppColors.darkCardBorder) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('change_password')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('current_password'),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? context.tr('required') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('new_password'),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v?.isEmpty ?? true) return context.tr('required');
                  if (v!.length < 6) return context.tr('password_too_short');
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );

    if (result == true) {
      _changePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );
    }
  }

  Future<void> _changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final response = await ApiService.post(
      'users/change-password',
      body: {'current_password': currentPassword, 'new_password': newPassword},
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.success
                ? context.tr('password_changed_successfully')
                : (response.message.isNotEmpty
                      ? response.message
                      : context.tr('update_failed')),
          ),
          backgroundColor: response.success ? AppColors.success : Colors.red,
        ),
      );
    }
  }

  Future<void> _showChangeEmailDialog(BuildContext context) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('change_email')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.tr('new_email'),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v?.isEmpty ?? true) return context.tr('required');
                  if (!v!.contains('@')) return context.tr('invalid_email');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('password'),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? context.tr('required') : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );

    if (result == true) {
      _changeEmail(emailController.text, passwordController.text);
    }
  }

  Future<void> _changeEmail(String newEmail, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final response = await ApiService.post(
      'users/change-email',
      body: {'new_email': newEmail, 'password': password},
    );

    if (mounted) {
      Navigator.pop(context);
      if (response.success) {
        await Provider.of<AuthProvider>(context, listen: false).refreshUser();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.success
                ? context.tr('email_changed_successfully')
                : (response.message.isNotEmpty
                      ? response.message
                      : context.tr('update_failed')),
          ),
          backgroundColor: response.success ? AppColors.success : Colors.red,
        ),
      );
    }
  }

  Future<void> _showChangePhoneDialog(BuildContext context) async {
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('change_phone')),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: context.tr('new_phone'),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v?.isEmpty ?? true) return context.tr('required');
                  if (v!.length < 9) return context.tr('invalid_phone');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('password'),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? context.tr('required') : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );

    if (result == true) {
      _changePhone(phoneController.text, passwordController.text);
    }
  }

  Future<void> _changePhone(String newPhone, String password) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final response = await ApiService.post(
      'users/change-phone',
      body: {'new_phone': newPhone, 'password': password},
    );

    if (mounted) {
      Navigator.pop(context);
      if (response.success) {
        await Provider.of<AuthProvider>(context, listen: false).refreshUser();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.success
                ? context.tr('phone_changed_successfully')
                : (response.message.isNotEmpty
                      ? response.message
                      : context.tr('update_failed')),
          ),
          backgroundColor: response.success ? AppColors.success : Colors.red,
        ),
      );
    }
  }
}
