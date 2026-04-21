import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/listing_model.dart';
import '../../providers/listings_provider.dart';
import '../../services/api_service.dart';

class EditListingScreen extends StatefulWidget {
  final ListingModel listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  // Images
  List<String> _existingImages = []; // URLs of existing images
  final List<File> _newImages = []; // New images to upload
  final ImagePicker _imagePicker = ImagePicker();
  static const int _maxImages = 10;

  // Common fields
  final _priceController = TextEditingController();
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
  final _modelController = TextEditingController();
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

  final List<Map<String, String>> _propertyTypes = [
    {'value': 'apartment', 'label': 'شقة'},
    {'value': 'villa_chalet', 'label': 'فيلا / شاليه'},
    {'value': 'shop_office', 'label': 'محل / مكتب'},
    {'value': 'student_housing', 'label': 'سكن طلاب'},
    {'value': 'land', 'label': 'أرض'},
  ];

  final List<Map<String, String>> _usageTypes = [
    {'value': 'daily', 'label': 'استخدام يومي'},
    {'value': 'wedding', 'label': 'زفة أعراس'},
    {'value': 'tourism', 'label': 'سياحية'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRegions();
    _populateFields();
  }

  void _populateFields() {
    final listing = widget.listing;

    // Load existing images
    _existingImages = List<String>.from(listing.images);

    // Common fields
    _bioController.text = listing.bio ?? '';
    _contactPhoneController.text = listing.contactPhone ?? '';
    _whatsappController.text = listing.whatsapp ?? '';

    if (listing.isProperty) {
      _titleController.text = listing.title ?? '';
      _selectedPropertyType = listing.type;
      _selectedRegionId = listing.regionId;
      _selectedCityId = listing.cityId;
      _priceController.text = listing.price?.toStringAsFixed(0) ?? '';
      _bedroomsController.text = listing.bedrooms?.toString() ?? '';
      _bathroomsController.text = listing.bathrooms?.toString() ?? '';
      _areaController.text = listing.areaM2?.toStringAsFixed(0) ?? '';
      _floorController.text = listing.floor?.toString() ?? '';

      // Load cities for selected region
      if (_selectedRegionId != null) {
        _loadCities(_selectedRegionId!);
      }
    } else {
      _modelController.text = listing.model ?? '';
      _selectedUsageType = listing.type;
      _selectedRegionId = listing.regionId;
      _selectedCityId = listing.cityId;
      _priceDailyController.text = listing.priceDaily?.toStringAsFixed(0) ?? '';
      _priceWeeklyController.text =
          listing.priceWeekly?.toStringAsFixed(0) ?? '';
      _priceMonthlyController.text =
          listing.priceMonthly?.toStringAsFixed(0) ?? '';
      _gearbox = listing.gearbox ?? 'automatic';
      _withDriver = listing.withDriver;

      // Load cities for selected region
      if (_selectedRegionId != null) {
        _loadCities(_selectedRegionId!);
      }
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
      });
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _bioController.dispose();
    _contactPhoneController.dispose();
    _whatsappController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _floorController.dispose();
    _modelController.dispose();
    _priceDailyController.dispose();
    _priceWeeklyController.dispose();
    _priceMonthlyController.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> data;
      String endpoint;

      if (widget.listing.isProperty) {
        data = {
          'title': _titleController.text,
          'property_type': _selectedPropertyType,
          'region_id': _selectedRegionId,
          'city_id': _selectedCityId,
          'address_text': _addressController.text,
          'price': double.tryParse(_priceController.text),
          'price_type': 'fixed',
          'bedrooms': int.tryParse(_bedroomsController.text),
          'bathrooms': int.tryParse(_bathroomsController.text),
          'area_m2': double.tryParse(_areaController.text),
          'floor': int.tryParse(_floorController.text),
          'bio': _bioController.text,
          'contact_phone': _contactPhoneController.text,
          'whatsapp': _whatsappController.text,
        };
        endpoint = 'properties/${widget.listing.id}';
      } else {
        data = {
          'model': _modelController.text,
          'usage_type': _selectedUsageType,
          'region_id': _selectedRegionId,
          'city_id': _selectedCityId,
          'price_daily': double.tryParse(_priceDailyController.text),
          'price_weekly': double.tryParse(_priceWeeklyController.text),
          'price_monthly': double.tryParse(_priceMonthlyController.text),
          'gearbox': _gearbox,
          'plate_color': _plateColor,
          'with_driver': _withDriver ? 1 : 0,
          'bio': _bioController.text,
          'contact_phone': _contactPhoneController.text,
          'whatsapp': _whatsappController.text,
        };
        endpoint = 'cars/${widget.listing.id}';
      }

      final response = await ApiService.put(endpoint, body: data);

      if (response.success) {
        // Upload new images if any
        if (_newImages.isNotEmpty) {
          final listingType = widget.listing.isProperty ? 'property' : 'car';
          await _uploadNewImages(widget.listing.id, listingType);
        }

        if (mounted) {
          Provider.of<ListingsProvider>(
            context,
            listen: false,
          ).fetchMyListings();
          await _showSuccessDialog();
          if (mounted) {
            Navigator.pop(context, true);
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

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: Text(
          context.tr('listing_sent_for_review'),
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
    final isProperty = widget.listing.isProperty;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isProperty ? context.tr('edit_property') : context.tr('edit_car'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Show rejection reason if rejected
            if (widget.listing.isRejected &&
                widget.listing.rejectReason != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('rejection_reason'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.listing.rejectReason!,
                      style: TextStyle(
                        color: isDark
                            ? Colors.red.shade300
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),

            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('edit_and_resubmit'),
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

            if (isProperty)
              ..._buildPropertyFields(isDark)
            else
              ..._buildCarFields(isDark),

            const SizedBox(height: 16),
            _buildCommonFields(isDark),

            const SizedBox(height: 16),
            _buildImagesPicker(isDark),

            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.tr('resubmit_for_review'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPropertyFields(bool isDark) {
    return [
      _buildDropdown(
        label: context.tr('property_type_label'),
        value: _selectedPropertyType,
        items: _propertyTypes
            .map(
              (t) =>
                  DropdownMenuItem(value: t['value'], child: Text(t['label']!)),
            )
            .toList(),
        onChanged: (v) => setState(() => _selectedPropertyType = v),
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
      _buildTextField(
        controller: _modelController,
        label: context.tr('model_required'),
        hint: context.tr('model_example'),
        validator: (v) => v?.isEmpty ?? true ? context.tr('required') : null,
      ),
      const SizedBox(height: 16),
      _buildDropdown(
        label: context.tr('usage_type_label'),
        value: _selectedUsageType,
        items: _usageTypes
            .map(
              (t) =>
                  DropdownMenuItem(value: t['value'], child: Text(t['label']!)),
            )
            .toList(),
        onChanged: (v) => setState(() => _selectedUsageType = v),
        validator: (v) => v == null ? context.tr('required') : null,
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
      const SizedBox(height: 16),
      _buildCarPricingFields(isDark),
    ];
  }

  Widget _buildCarPricingFields(bool isDark) {
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _priceDailyController,
                  label: context.tr('daily'),
                  keyboardType: TextInputType.number,
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

  Widget _buildCommonFields(bool isDark) {
    final isProperty = widget.listing.isProperty;
    return Column(
      children: [
        if (isProperty) ...[
          _buildTextField(
            controller: _priceController,
            label: context.tr('price_required'),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v?.isEmpty ?? true ? context.tr('required') : null,
          ),
          const SizedBox(height: 16),
        ],
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
            setState(() {
              _selectedRegionId = v;
              _selectedCityId = null;
              _cities = [];
            });
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: items.any((item) => item.value == value) ? value : null,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildImagesPicker(bool isDark) {
    final totalImages = _existingImages.length + _newImages.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.tr('images'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            Text(
              '$totalImages/$_maxImages',
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
              if (totalImages < _maxImages)
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
                          context.tr('add_images'),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Existing images
              ..._existingImages.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeExistingImage(index),
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
              // New images
              ..._newImages.asMap().entries.map((entry) {
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
                          onTap: () => _removeNewImage(index),
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
                      // New badge
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'جديد',
                            style: TextStyle(color: Colors.white, fontSize: 10),
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
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      final totalImages = _existingImages.length + _newImages.length;
      final remainingSlots = _maxImages - totalImages;
      if (remainingSlots <= 0) return;

      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFiles.isEmpty) return;

      final filesToAdd = pickedFiles.take(remainingSlots);

      for (final xFile in filesToAdd) {
        final compressedFile = await _compressImage(File(xFile.path));
        if (compressedFile != null) {
          setState(() => _newImages.add(compressedFile));
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

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _uploadNewImages(int listingId, String listingType) async {
    if (_newImages.isEmpty) return;

    for (int i = 0; i < _newImages.length; i++) {
      final file = _newImages[i];
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      await ApiService.post(
        'uploads/image',
        body: {
          'listing_id': listingId,
          'listing_type': listingType,
          'image': 'data:image/jpeg;base64,$base64Image',
          'sort_order': _existingImages.length + i,
        },
      );
    }
  }
}
