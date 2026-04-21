import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String _selectedUserType = 'renter';

  // Location fields
  int? _selectedRegionId;
  int? _selectedCityId;
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _filteredCities = [];

  final List<Map<String, String>> _userTypes = [
    {'value': 'renter', 'label': 'مستأجر'},
    {'value': 'owner', 'label': 'مالك عقار'},
    {'value': 'office', 'label': 'مكتب عقارات'},
    {'value': 'car_lessor', 'label': 'مؤجر سيارات'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRegions();
    _loadCities();
  }

  Future<void> _loadRegions() async {
    final response = await ApiService.get('regions');
    if (response.success && response.data != null) {
      setState(() {
        _regions = List<Map<String, dynamic>>.from(response.data);
      });
    }
  }

  Future<void> _loadCities() async {
    final response = await ApiService.get('cities');
    if (response.success && response.data != null) {
      setState(() {
        _cities = List<Map<String, dynamic>>.from(response.data);
        _filteredCities = _cities;
      });
    }
  }

  void _filterCitiesByRegion() {
    if (_selectedRegionId == null) {
      _filteredCities = _cities;
    } else {
      _filteredCities = _cities.where((c) {
        final regionId = c['region_id'] is int
            ? c['region_id']
            : int.tryParse(c['region_id'].toString());
        return regionId == _selectedRegionId;
      }).toList();
    }
    if (_selectedCityId != null) {
      final cityExists = _filteredCities.any((c) {
        final id = c['id'] is int ? c['id'] : int.tryParse(c['id'].toString());
        return id == _selectedCityId;
      });
      if (!cityExists) _selectedCityId = null;
    }
  }

  String _getLocalizedName(Map<String, dynamic> item, String lang) {
    if (lang == 'en') return item['name_en'] ?? item['name_ar'] ?? '';
    if (lang == 'he') return item['name_he'] ?? item['name_ar'] ?? '';
    return item['name_ar'] ?? '';
  }

  Future<void> _showTermsDialog() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('terms_of_service')),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: FutureBuilder(
            future: ApiService.get(
              'settings/terms?lang=${Provider.of<AppProvider>(context, listen: false).languageCode}',
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data!.success) {
                final content = snapshot.data!.data['content'] ?? '';
                return SingleChildScrollView(
                  child: Text(
                    content.replaceAll(RegExp(r'<[^>]*>'), ''),
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }
              return Center(child: Text(context.tr('error_loading')));
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('close')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate location selection
    if (_selectedRegionId == null || _selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('select_location_required')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: _selectedUserType,
        regionId: _selectedRegionId,
        cityId: _selectedCityId,
      );

      if (mounted) {
        String message;
        if (result['requiresApproval'] == true) {
          message = 'تم التسجيل بنجاح! حسابك قيد المراجعة من قبل الإدارة.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop(); // Go back to login
        } else {
          // Show welcome dialog with free bonus info
          await _showWelcomeBonusDialog();
          // Navigate to main screen after successful registration
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showWelcomeBonusDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('welcome_title'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('welcome_bonus_title'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('welcome_bonus_desc'),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                context.tr('start_now'),
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('register')), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // App Logo
                Center(
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        isDark
                            ? 'assets/images/logo_dark.png'
                            : 'assets/images/logo_light.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr('create_account'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('register_subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: context.tr('full_name'),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('required_field');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: context.tr('phone'),
                    prefixIcon: const Icon(Icons.phone),
                    hintText: '+972501234567',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('required_field');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: context.tr('email'),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.contains('@')) {
                        return context.tr('invalid_email');
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedUserType,
                  decoration: InputDecoration(
                    labelText: context.tr('user_type'),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: _userTypes.map((type) {
                    return DropdownMenuItem(
                      value: type['value'],
                      child: Text(type['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedUserType = value!);
                  },
                ),
                const SizedBox(height: 16),
                // Region dropdown
                DropdownButtonFormField<int>(
                  initialValue: _selectedRegionId,
                  decoration: InputDecoration(
                    labelText: context.tr('region'),
                    prefixIcon: const Icon(Icons.map),
                  ),
                  items: _regions.map((r) {
                    final id = r['id'] is int
                        ? r['id']
                        : int.tryParse(r['id'].toString());
                    final lang = Provider.of<AppProvider>(
                      context,
                      listen: false,
                    ).languageCode;
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(_getLocalizedName(r, lang)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegionId = value;
                      _selectedCityId = null;
                      _filterCitiesByRegion();
                    });
                  },
                  validator: (value) {
                    if (value == null) return context.tr('required_field');
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // City dropdown
                DropdownButtonFormField<int>(
                  initialValue: _selectedCityId,
                  decoration: InputDecoration(
                    labelText: context.tr('city'),
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  items: _filteredCities.map((c) {
                    final id = c['id'] is int
                        ? c['id']
                        : int.tryParse(c['id'].toString());
                    final lang = Provider.of<AppProvider>(
                      context,
                      listen: false,
                    ).languageCode;
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(_getLocalizedName(c, lang)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCityId = value);
                  },
                  validator: (value) {
                    if (value == null) return context.tr('required_field');
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: context.tr('password'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('required_field');
                    }
                    if (value.length < 6) {
                      return context.tr('password_min_length');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: context.tr('confirm_password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('required_field');
                    }
                    if (value != _passwordController.text) {
                      return context.tr('passwords_not_match');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Terms and Conditions Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Wrap(
                            children: [
                              Text(
                                context.tr('agree_to'),
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showTermsDialog(),
                                child: Text(
                                  context.tr('terms_of_service'),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_agreedToTerms && _isLoading == false)
                  const SizedBox.shrink(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading || !_agreedToTerms ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.tr('register'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('have_account'),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.tr('login')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
