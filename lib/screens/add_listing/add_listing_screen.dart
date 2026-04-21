import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../providers/listing_types_provider.dart';
import '../../services/api_service.dart';
import '../checkout/checkout_screen.dart';

class AddListingScreen extends StatefulWidget {
  final String listingType; // 'property' or 'car'

  const AddListingScreen({super.key, required this.listingType});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, dynamic>? _activeSubscription;
  String? _error;

  // Payment options
  Map<String, dynamic>? _freeBonus;
  List<Map<String, dynamic>> _activeSubscriptions = [];
  List<Map<String, dynamic>> _availablePlans = [];
  int? _selectedSubscriptionId; // null means buy new, -1 means free bonus
  bool _loadingPaymentOptions = false;

  // Images
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  static const int _maxImages = 10;

  // Common fields
  final _bioController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _whatsappController = TextEditingController();

  // Property fields
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  final _floorController = TextEditingController();
  String? _selectedPropertyType;
  int? _selectedRegionId;
  int? _selectedCityId;

  // Car fields
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceDailyController = TextEditingController();
  final _priceWeeklyController = TextEditingController();
  final _priceMonthlyController = TextEditingController();
  String? _selectedUsageType;
  String _gearbox = 'automatic';
  String _plateColor = 'yellow';
  bool _withDriver = false;

  // Data
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _cities = [];

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    _loadRegions();
    _loadTypes();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _contactPhoneController.text = auth.user?.phone ?? '';
  }

  Future<void> _loadTypes() async {
    final typesProvider = Provider.of<ListingTypesProvider>(
      context,
      listen: false,
    );
    await typesProvider.fetchTypes();
  }

  Future<void> _checkSubscription() async {
    final category = widget.listingType == 'property' ? 'properties' : 'cars';
    final response = await ApiService.get(
      'subscriptions/can-add?category=$category',
    );

    if (mounted) {
      setState(() {
        if (response.success &&
            response.data != null &&
            response.data['can_add'] == true) {
          _activeSubscription = response.data['subscription'];
        } else {
          _activeSubscription = null;
        }
      });
    }
  }

  Future<void> _loadPaymentOptions() async {
    final category = widget.listingType == 'property' ? 'properties' : 'cars';
    final subType = widget.listingType == 'property'
        ? _selectedPropertyType
        : _selectedUsageType;

    if (subType == null) return;

    setState(() => _loadingPaymentOptions = true);

    final response = await ApiService.get(
      'subscriptions/available-for-listing',
      params: {'category': category, 'sub_type': subType},
    );

    if (mounted && response.success && response.data != null) {
      setState(() {
        _freeBonus = response.data['free_bonus'];
        _activeSubscriptions = List<Map<String, dynamic>>.from(
          response.data['active_subscriptions'] ?? [],
        );
        _availablePlans = List<Map<String, dynamic>>.from(
          response.data['available_plans'] ?? [],
        );

        // Auto-select first available option
        if (_freeBonus != null) {
          _selectedSubscriptionId = -1; // Free bonus
        } else if (_activeSubscriptions.isNotEmpty) {
          _selectedSubscriptionId = _activeSubscriptions.first['id'];
        } else {
          _selectedSubscriptionId = null; // Need to buy
        }

        _loadingPaymentOptions = false;
      });
    } else {
      setState(() => _loadingPaymentOptions = false);
    }
  }

  Future<void> _loadRegions() async {
    final response = await ApiService.get('regions');
    if (response.success && response.data != null) {
      setState(() {
        _regions = List<Map<String, dynamic>>.from(response.data);
      });
    }
  }

  Future<void> _loadCities(int regionId) async {
    final response = await ApiService.get('regions/$regionId/cities');
    if (response.success && response.data != null) {
      setState(() {
        _cities = List<Map<String, dynamic>>.from(response.data);
        _selectedCityId = null;
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _contactPhoneController.dispose();
    _whatsappController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _floorController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceDailyController.dispose();
    _priceWeeklyController.dispose();
    _priceMonthlyController.dispose();
    super.dispose();
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user selected a payment option
    if (_selectedSubscriptionId == null) {
      final lang = Localizations.localeOf(context).languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'he'
                ? 'יש לבחור אפשרות תשלום או לרכוש חבילה'
                : 'يرجى اختيار خيار دفع أو شراء باقة',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> data;

      if (widget.listingType == 'property') {
        // Get current language for listing content
        final currentLang = Localizations.localeOf(context).languageCode;

        // Get subscription ID (if -1, it's the free bonus)
        int? subId;
        if (_selectedSubscriptionId == -1) {
          subId = _freeBonus?['id'];
        } else {
          subId = _selectedSubscriptionId;
        }

        data = {
          'title': _titleController.text,
          'property_type': _selectedPropertyType,
          'region_id': _selectedRegionId,
          'city_id': _selectedCityId,
          'address_text': _addressController.text,
          'price':
              double.tryParse(_priceMonthlyController.text) ??
              double.tryParse(_priceDailyController.text),
          'price_type': 'fixed',
          'price_daily': double.tryParse(_priceDailyController.text),
          'price_weekly': double.tryParse(_priceWeeklyController.text),
          'price_monthly': double.tryParse(_priceMonthlyController.text),
          'currency': 'ILS',
          'bedrooms': int.tryParse(_bedroomsController.text),
          'bathrooms': int.tryParse(_bathroomsController.text),
          'area_m2': double.tryParse(_areaController.text),
          'floor': int.tryParse(_floorController.text),
          'bio': _bioController.text,
          'language': currentLang,
          'contact_phone': _contactPhoneController.text,
          'whatsapp': _whatsappController.text,
          'subscription_id': subId,
        };
      } else {
        // Get current language for listing content
        final currentLang = Localizations.localeOf(context).languageCode;

        // Get subscription ID (if -1, it's the free bonus)
        int? subId;
        if (_selectedSubscriptionId == -1) {
          subId = _freeBonus?['id'];
        } else {
          subId = _selectedSubscriptionId;
        }

        data = {
          'brand': _brandController.text,
          'model': _modelController.text,
          'year': int.tryParse(_yearController.text),
          'usage_type': _selectedUsageType,
          'region_id': _selectedRegionId,
          'city_id': _selectedCityId,
          'price': double.tryParse(_priceDailyController.text),
          'price_type': 'fixed',
          'price_daily': double.tryParse(_priceDailyController.text),
          'price_weekly': double.tryParse(_priceWeeklyController.text),
          'price_monthly': double.tryParse(_priceMonthlyController.text),
          'currency': 'ILS',
          'gearbox': _gearbox,
          'plate_color': _plateColor,
          'with_driver': _withDriver ? 1 : 0,
          'bio': _bioController.text,
          'language': currentLang,
          'contact_phone': _contactPhoneController.text,
          'whatsapp': _whatsappController.text,
          'subscription_id': subId,
        };
      }

      final endpoint = widget.listingType == 'property' ? 'properties' : 'cars';
      final response = await ApiService.post(endpoint, body: data);

      if (response.success && response.data != null) {
        // Upload images if any
        final listingId = response.data['id'];
        if (listingId != null && _selectedImages.isNotEmpty) {
          await _uploadImages(listingId, widget.listingType);
        }

        if (mounted) {
          Provider.of<ListingsProvider>(
            context,
            listen: false,
          ).fetchMyListings();
          await _showListingPendingDialog();
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else if (response.success) {
        // Success but no data returned
        if (mounted) {
          Provider.of<ListingsProvider>(
            context,
            listen: false,
          ).fetchMyListings();
          await _showListingPendingDialog();
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        setState(() {
          _error = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showListingPendingDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: Text(
          context.tr('listing_added_success'),
          textAlign: TextAlign.center,
        ),
        content: Text(
          context.tr('listing_under_review'),
          textAlign: TextAlign.center,
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isProperty = widget.listingType == 'property';
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isProperty
              ? context.tr('add_property_title')
              : context.tr('add_car_title'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Show subscription status only if active
            if (_activeSubscription != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${context.tr('active_subscription')}: ${lang == 'he' ? (_activeSubscription!['name_he'] ?? _activeSubscription!['name_ar']) : (lang == 'en' ? (_activeSubscription!['name_en'] ?? _activeSubscription!['name_ar']) : _activeSubscription!['name_ar'])}',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            // Images Section
            _buildImagesSection(isDark),
            const SizedBox(height: 24),

            if (isProperty)
              ..._buildPropertyFields(isDark)
            else
              ..._buildCarFields(isDark),

            const SizedBox(height: 16),
            _buildCommonFields(isDark),

            const SizedBox(height: 24),

            // Payment Options Section
            _buildPaymentOptionsSection(isDark),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(context.tr('review_notice'))),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitListing,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.tr('publish_listing')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPropertyFields(bool isDark) {
    final typesProvider = Provider.of<ListingTypesProvider>(context);
    final lang = Localizations.localeOf(context).languageCode;
    final propertyTypes = typesProvider.propertyTypes;

    return [
      _buildDropdown(
        label: context.tr('property_type_label'),
        value: _selectedPropertyType,
        items: propertyTypes
            .map(
              (t) =>
                  DropdownMenuItem(value: t.slug, child: Text(t.getName(lang))),
            )
            .toList(),
        onChanged: (v) {
          setState(() {
            _selectedPropertyType = v;
            _freeBonus = null;
            _activeSubscriptions = [];
            _availablePlans = [];
            _selectedSubscriptionId = null;
          });
          _loadPaymentOptions();
        },
        validator: (v) => v == null ? context.tr('required') : null,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _titleController,
        label: context.tr('title_label'),
        hint: context.tr('title_example'),
      ),
      const SizedBox(height: 16),
      _buildRegionCityDropdowns(),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _addressController,
        label: context.tr('address'),
        hint: context.tr('address_hint'),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _bedroomsController,
              label: context.tr('bedrooms'),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller: _bathroomsController,
              label: context.tr('bathrooms_label'),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _areaController,
              label: context.tr('area'),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller: _floorController,
              label: context.tr('floor_label'),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildCarFields(bool isDark) {
    return [
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _brandController,
              label: context.tr('brand_required'),
              hint: context.tr('brand_example'),
              validator: (v) =>
                  v?.isEmpty ?? true ? context.tr('required') : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller: _modelController,
              label: context.tr('model_required'),
              hint: context.tr('model_example'),
              validator: (v) =>
                  v?.isEmpty ?? true ? context.tr('required') : null,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _yearController,
              label: context.tr('year_required'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v?.isEmpty ?? true ? context.tr('required') : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Consumer<ListingTypesProvider>(
              builder: (context, typesProvider, _) {
                final lang = Localizations.localeOf(context).languageCode;
                final carTypes = typesProvider.carTypes;
                return _buildDropdown(
                  label: context.tr('usage_type_label'),
                  value: _selectedUsageType,
                  items: carTypes
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.slug,
                          child: Text(t.getName(lang)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedUsageType = v;
                      _freeBonus = null;
                      _activeSubscriptions = [];
                      _availablePlans = [];
                      _selectedSubscriptionId = null;
                    });
                    _loadPaymentOptions();
                  },
                  validator: (v) => v == null ? context.tr('required') : null,
                );
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _buildRegionCityDropdowns(),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildDropdown(
              label: context.tr('gearbox_label'),
              value: _gearbox,
              items: [
                DropdownMenuItem(
                  value: 'automatic',
                  child: Text(context.tr('automatic')),
                ),
                DropdownMenuItem(
                  value: 'manual',
                  child: Text(context.tr('manual')),
                ),
              ],
              onChanged: (v) => setState(() => _gearbox = v ?? 'automatic'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown(
              label: context.tr('plate_color_label'),
              value: _plateColor,
              items: [
                DropdownMenuItem(
                  value: 'yellow',
                  child: Text(context.tr('yellow')),
                ),
                DropdownMenuItem(
                  value: 'white',
                  child: Text(context.tr('white')),
                ),
                DropdownMenuItem(
                  value: 'green',
                  child: Text(context.tr('green')),
                ),
              ],
              onChanged: (v) => setState(() => _plateColor = v ?? 'yellow'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: Text(context.tr('with_driver')),
        value: _withDriver,
        onChanged: (v) => setState(() => _withDriver = v),
        activeThumbColor: AppColors.primary,
      ),
    ];
  }

  Widget _buildCommonFields(bool isDark) {
    final isProperty = widget.listingType == 'property';
    return Column(
      children: [
        // Daily/Weekly/Monthly pricing fields (for both properties and cars)
        _buildRentalPricingFields(isDark),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _bioController,
          label: context.tr('description'),
          hint: context.tr('description_hint'),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _contactPhoneController,
                label: context.tr('contact_phone'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v?.isEmpty ?? true ? context.tr('required') : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _whatsappController,
                label: context.tr('whatsapp_number'),
                hint: '+972...',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRentalPricingFields(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('rental_prices'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('enter_one_price'),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _priceDailyController,
                  label: context.tr('daily'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (_priceDailyController.text.isEmpty &&
                        _priceWeeklyController.text.isEmpty &&
                        _priceMonthlyController.text.isEmpty) {
                      return context.tr('enter_one_price');
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _priceWeeklyController,
                  label: context.tr('weekly'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _priceMonthlyController,
                  label: context.tr('monthly'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegionCityDropdowns() {
    return Column(
      children: [
        _buildDropdown<int>(
          label: 'المنطقة *',
          value: _selectedRegionId,
          items: _regions
              .map(
                (r) => DropdownMenuItem<int>(
                  value: r['id'] is int
                      ? r['id']
                      : int.tryParse(r['id'].toString()) ?? 0,
                  child: Text(r['name_ar'] ?? ''),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() => _selectedRegionId = v);
            if (v != null) _loadCities(v);
          },
          validator: (v) => v == null ? 'مطلوب' : null,
        ),
        const SizedBox(height: 16),
        _buildDropdown<int>(
          label: 'المدينة *',
          value: _selectedCityId,
          items: _cities
              .map(
                (c) => DropdownMenuItem<int>(
                  value: c['id'] is int
                      ? c['id']
                      : int.tryParse(c['id'].toString()) ?? 0,
                  child: Text(c['name_ar'] ?? ''),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedCityId = v),
          validator: (v) => v == null ? 'مطلوب' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }

  Widget _buildPaymentOptionsSection(bool isDark) {
    final lang = Localizations.localeOf(context).languageCode;
    final subType = widget.listingType == 'property'
        ? _selectedPropertyType
        : _selectedUsageType;

    // If no type selected yet, show message
    if (subType == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                lang == 'he'
                    ? 'יש לבחור סוג מודעה כדי לראות אפשרויות תשלום'
                    : 'يرجى اختيار نوع الإعلان لعرض خيارات الدفع',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    // Load payment options if not loaded
    if (_freeBonus == null &&
        _activeSubscriptions.isEmpty &&
        _availablePlans.isEmpty &&
        !_loadingPaymentOptions) {
      _loadPaymentOptions();
    }

    if (_loadingPaymentOptions) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasOptions = _freeBonus != null || _activeSubscriptions.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang == 'he' ? 'אפשרויות תשלום' : 'خيارات الدفع',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Free Bonus Option
          if (_freeBonus != null)
            _buildPaymentOption(
              id: -1,
              title: lang == 'he'
                  ? 'חבילת ברוכים הבאים (חינם)'
                  : 'باقة الترحيب (مجانية)',
              subtitle: lang == 'he'
                  ? 'מודעות נותרו: ${_freeBonus!['listings_remaining']}'
                  : 'متبقي: ${_freeBonus!['listings_remaining']} إعلان',
              icon: Icons.card_giftcard,
              color: Colors.green,
              isDark: isDark,
            ),

          // Active Subscriptions
          ..._activeSubscriptions.map(
            (sub) => _buildPaymentOption(
              id: sub['id'],
              title: sub['name_ar'] ?? sub['name_en'] ?? 'باقة',
              subtitle: lang == 'he'
                  ? 'מודעות נותרו: ${sub['listings_remaining']}'
                  : 'متبقي: ${sub['listings_remaining']} إعلان',
              icon: Icons.check_circle,
              color: AppColors.primary,
              isDark: isDark,
              badge: sub['badge'],
            ),
          ),

          // Buy New Option
          _buildPaymentOption(
            id: null,
            title: lang == 'he' ? 'רכוש חבילה חדשה' : 'شراء باقة جديدة',
            subtitle: hasOptions
                ? (lang == 'he'
                      ? 'שמור על החבילות הקיימות'
                      : 'احتفظ بباقاتك الحالية')
                : (lang == 'he' ? 'נדרש לפרסום המודעה' : 'مطلوب لنشر الإعلان'),
            icon: Icons.shopping_cart,
            color: Colors.blue,
            isDark: isDark,
            showArrow: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required int? id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    String? badge,
    bool showArrow = false,
  }) {
    final isSelected = _selectedSubscriptionId == id;

    return GestureDetector(
      onTap: () {
        if (id == null) {
          // Navigate to checkout
          final isProperty = widget.listingType == 'property';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckoutScreen(
                category: isProperty ? 'properties' : 'cars',
                propertyType: isProperty ? _selectedPropertyType : null,
                carUsageType: !isProperty ? _selectedUsageType : null,
              ),
            ),
          ).then((_) => _loadPaymentOptions());
        } else {
          setState(() => _selectedSubscriptionId = id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : (isDark ? Colors.black26 : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.white12 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (id != null)
              Radio<int?>(
                value: id,
                groupValue: _selectedSubscriptionId,
                onChanged: (v) => setState(() => _selectedSubscriptionId = v),
                activeColor: color,
              )
            else
              const SizedBox(width: 12),
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
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
            if (showArrow)
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }

  Widget _buildImagesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'صور الإعلان',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '${_selectedImages.length}/$_maxImages',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              if (_selectedImages.length < _maxImages)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'إضافة صور',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Selected images
              ..._selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          file,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'يمكنك إضافة حتى $_maxImages صور',
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFiles.isEmpty) return;

      final remainingSlots = _maxImages - _selectedImages.length;
      final filesToAdd = pickedFiles.take(remainingSlots);

      for (final xFile in filesToAdd) {
        final compressedFile = await _compressImage(File(xFile.path));
        if (compressedFile != null) {
          setState(() => _selectedImages.add(compressedFile));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الصور: $e')));
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf('.');
      final targetPath = '${filePath.substring(0, lastIndex)}_compressed.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (result != null) {
        return File(result.path);
      }
      return file;
    } catch (e) {
      return file;
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadImages(int listingId, String listingType) async {
    if (_selectedImages.isEmpty) return;

    for (int i = 0; i < _selectedImages.length; i++) {
      final file = _selectedImages[i];
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      await ApiService.post(
        'uploads/image',
        body: {
          'listing_id': listingId,
          'listing_type': listingType,
          'image': 'data:image/jpeg;base64,$base64Image',
          'sort_order': i,
        },
      );
    }
  }
}
