import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../providers/listing_types_provider.dart';
import '../../services/api_service.dart';
import '../widgets/listing_card.dart';
import '../../models/listing_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  List<ListingModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _filtersExpanded = true;

  // Main filters
  String _listingType = 'property'; // property, car
  String?
  _propertyType; // apartment, villa_chalet, shop_office, student_housing, land
  String? _carUsageType; // daily, wedding, tourism

  // Location filters
  int? _selectedRegionId;
  int? _selectedCityId;

  // Property specific filters
  int? _minBedrooms;

  // Car specific filters
  String? _gearbox; // automatic, manual
  bool? _withDriver;

  // Data lists
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _loadRegions();
    _loadCities();
    // Load dynamic types
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingTypesProvider>(context, listen: false).fetchTypes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
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
        _filterCitiesByRegion();
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
    // Reset city if not in filtered list
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

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _filtersExpanded = false; // Collapse filters after search
    });

    try {
      List<ListingModel> allResults = [];
      final query = _searchController.text.trim();
      final minPrice = _minPriceController.text.trim();
      final maxPrice = _maxPriceController.text.trim();

      if (_listingType == 'property') {
        final params = <String, dynamic>{};
        if (query.isNotEmpty) params['search'] = query;
        if (_selectedRegionId != null) {
          params['region_id'] = _selectedRegionId.toString();
        }
        if (_selectedCityId != null) {
          params['city_id'] = _selectedCityId.toString();
        }
        if (_propertyType != null) params['property_type'] = _propertyType;
        if (minPrice.isNotEmpty) params['price_min'] = minPrice;
        if (maxPrice.isNotEmpty) params['price_max'] = maxPrice;
        if (_minBedrooms != null) params['bedrooms'] = _minBedrooms.toString();

        final response = await ApiService.get('properties', params: params);
        if (response.success && response.data != null) {
          final props = (response.data as List)
              .map(
                (e) =>
                    ListingModel.fromJson({...e, 'listing_type': 'property'}),
              )
              .toList();
          allResults.addAll(props);
        }
      } else {
        final params = <String, dynamic>{};
        if (query.isNotEmpty) params['search'] = query;
        if (_selectedRegionId != null) {
          params['region_id'] = _selectedRegionId.toString();
        }
        if (_selectedCityId != null) {
          params['city_id'] = _selectedCityId.toString();
        }
        if (_carUsageType != null) params['usage_type'] = _carUsageType;
        if (minPrice.isNotEmpty) params['price_min'] = minPrice;
        if (maxPrice.isNotEmpty) params['price_max'] = maxPrice;
        if (_gearbox != null) params['gearbox'] = _gearbox;
        if (_withDriver != null) {
          params['with_driver'] = _withDriver! ? '1' : '0';
        }

        final response = await ApiService.get('cars', params: params);
        if (response.success && response.data != null) {
          final cars = (response.data as List)
              .map((e) => ListingModel.fromJson({...e, 'listing_type': 'car'}))
              .toList();
          allResults.addAll(cars);
        }
      }

      setState(() {
        _results = allResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _propertyType = null;
      _carUsageType = null;
      _selectedRegionId = null;
      _selectedCityId = null;
      _minBedrooms = null;
      _gearbox = null;
      _withDriver = null;
      _filteredCities = _cities;
      _results = [];
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<AppProvider>(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('search')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFilters,
            tooltip: context.tr('reset'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Collapsible Filters Header
          if (_hasSearched)
            InkWell(
              onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('filters'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      _filtersExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ],
                ),
              ),
            ),

          // Filters Section (Animated)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _filtersExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Listing Type Toggle
                  _buildListingTypeToggle(isDark, lang),
                  const SizedBox(height: 16),

                  // Search TextField
                  _buildSearchField(isDark, lang),
                  const SizedBox(height: 12),

                  // Sub-type filter (Property Type or Car Usage)
                  _buildSubTypeFilter(isDark, lang),
                  const SizedBox(height: 12),

                  // Location filters
                  _buildLocationFilters(isDark, lang),
                  const SizedBox(height: 12),

                  // Price Range
                  _buildPriceRange(isDark, lang),
                  const SizedBox(height: 12),

                  // Additional filters based on type
                  if (_listingType == 'property')
                    _buildPropertyFilters(isDark, lang)
                  else
                    _buildCarFilters(isDark, lang),

                  const SizedBox(height: 16),

                  // Search button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: Text(context.tr('search')),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),

          // Results Section
          Expanded(child: _buildResults(isDark, lang)),
        ],
      ),
    );
  }

  Widget _buildListingTypeToggle(bool isDark, String lang) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _listingType = 'property';
                _carUsageType = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _listingType == 'property'
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apartment,
                      color: _listingType == 'property'
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black54),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('properties'),
                      style: TextStyle(
                        color: _listingType == 'property'
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black54),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _listingType = 'car';
                _propertyType = null;
                _minBedrooms = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _listingType == 'car'
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: _listingType == 'car'
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black54),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('cars'),
                      style: TextStyle(
                        color: _listingType == 'car'
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black54),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark, String lang) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: context.tr('search_hint'),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.darkCard : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (v) => setState(() {}),
    );
  }

  Widget _buildSubTypeFilter(bool isDark, String lang) {
    final typesProvider = Provider.of<ListingTypesProvider>(context);

    if (_listingType == 'property') {
      final propertyTypes = typesProvider.propertyTypes;
      return _buildDropdown<String?>(
        value: _propertyType,
        hint: context.tr('property_type'),
        isDark: isDark,
        items: [
          DropdownMenuItem(value: null, child: Text(context.tr('all'))),
          ...propertyTypes.map(
            (type) => DropdownMenuItem(
              value: type.slug,
              child: Text(type.getName(lang)),
            ),
          ),
        ],
        onChanged: (v) => setState(() => _propertyType = v),
      );
    } else {
      final carTypes = typesProvider.carTypes;
      return _buildDropdown<String?>(
        value: _carUsageType,
        hint: context.tr('car_usage_type'),
        isDark: isDark,
        items: [
          DropdownMenuItem(value: null, child: Text(context.tr('all'))),
          ...carTypes.map(
            (type) => DropdownMenuItem(
              value: type.slug,
              child: Text(type.getName(lang)),
            ),
          ),
        ],
        onChanged: (v) => setState(() => _carUsageType = v),
      );
    }
  }

  Widget _buildLocationFilters(bool isDark, String lang) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown<int?>(
            value: _selectedRegionId,
            hint: context.tr('region'),
            isDark: isDark,
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(context.tr('all_regions')),
              ),
              ..._regions.map(
                (r) => DropdownMenuItem(
                  value: r['id'] is int
                      ? r['id']
                      : int.tryParse(r['id'].toString()),
                  child: Text(_getLocalizedName(r, lang)),
                ),
              ),
            ],
            onChanged: (v) {
              setState(() {
                _selectedRegionId = v;
                _selectedCityId = null;
                _filterCitiesByRegion();
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown<int?>(
            value: _selectedCityId,
            hint: context.tr('city'),
            isDark: isDark,
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(context.tr('all_cities')),
              ),
              ..._filteredCities.map(
                (c) => DropdownMenuItem(
                  value: c['id'] is int
                      ? c['id']
                      : int.tryParse(c['id'].toString()),
                  child: Text(_getLocalizedName(c, lang)),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _selectedCityId = v),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRange(bool isDark, String lang) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: context.tr('min_price'),
              prefixIcon: const Icon(Icons.attach_money, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.darkCard : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: context.tr('max_price'),
              prefixIcon: const Icon(Icons.attach_money, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.darkCard : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyFilters(bool isDark, String lang) {
    return _buildDropdown<int?>(
      value: _minBedrooms,
      hint: context.tr('bedrooms'),
      isDark: isDark,
      items: [
        DropdownMenuItem(value: null, child: Text(context.tr('all'))),
        DropdownMenuItem(value: 1, child: Text('1+')),
        DropdownMenuItem(value: 2, child: Text('2+')),
        DropdownMenuItem(value: 3, child: Text('3+')),
        DropdownMenuItem(value: 4, child: Text('4+')),
        DropdownMenuItem(value: 5, child: Text('5+')),
      ],
      onChanged: (v) => setState(() => _minBedrooms = v),
    );
  }

  Widget _buildCarFilters(bool isDark, String lang) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown<String?>(
            value: _gearbox,
            hint: context.tr('gearbox'),
            isDark: isDark,
            items: [
              DropdownMenuItem(value: null, child: Text(context.tr('all'))),
              DropdownMenuItem(
                value: 'automatic',
                child: Text(context.tr('automatic')),
              ),
              DropdownMenuItem(
                value: 'manual',
                child: Text(context.tr('manual')),
              ),
            ],
            onChanged: (v) => setState(() => _gearbox = v),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdown<bool?>(
            value: _withDriver,
            hint: context.tr('with_driver'),
            isDark: isDark,
            items: [
              DropdownMenuItem(value: null, child: Text(context.tr('all'))),
              DropdownMenuItem(
                value: true,
                child: Text(context.tr('with_driver')),
              ),
              DropdownMenuItem(
                value: false,
                child: Text(context.tr('without_driver')),
              ),
            ],
            onChanged: (v) => setState(() => _withDriver = v),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String hint,
    required bool isDark,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(fontSize: 14)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildResults(bool isDark, String lang) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list,
              size: 64,
              color: isDark ? Colors.white30 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              lang == 'en'
                  ? 'Set filters and tap Search'
                  : (lang == 'he'
                        ? 'הגדר מסננים ולחץ חיפוש'
                        : 'حدد الفلاتر واضغط بحث'),
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDark ? Colors.white30 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('no_results'),
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${_results.length} ${context.tr('search_results')}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return ListingCard(listing: _results[index]);
            },
          ),
        ),
      ],
    );
  }
}
