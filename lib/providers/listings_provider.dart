import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/api_service.dart';

class ListingsProvider extends ChangeNotifier {
  List<ListingModel> _properties = [];
  List<ListingModel> _cars = [];
  List<ListingModel> _favorites = [];
  List<ListingModel> _myListings = [];

  bool _isLoadingProperties = false;
  bool _isLoadingCars = false;
  bool _isLoadingFavorites = false;
  bool _isLoadingMyListings = false;

  int _propertiesPage = 1;
  int _carsPage = 1;
  bool _hasMoreProperties = true;
  bool _hasMoreCars = true;

  // Filters
  String? _selectedRegion;
  String? _selectedCity;
  String? _selectedPropertyType;
  String? _selectedCarUsageType;
  String? _searchQuery;
  String _currentLang = 'ar';

  void setLanguage(String lang) {
    _currentLang = lang;
  }

  List<ListingModel> get properties => _properties;
  List<ListingModel> get cars => _cars;
  List<ListingModel> get favorites => _favorites;
  List<ListingModel> get myListings => _myListings;

  bool get isLoadingProperties => _isLoadingProperties;
  bool get isLoadingCars => _isLoadingCars;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isLoadingMyListings => _isLoadingMyListings;

  bool get hasMoreProperties => _hasMoreProperties;
  bool get hasMoreCars => _hasMoreCars;

  Future<void> fetchProperties({bool refresh = false}) async {
    if (_isLoadingProperties) return;
    if (refresh) {
      _propertiesPage = 1;
      _hasMoreProperties = true;
    }
    if (!_hasMoreProperties && !refresh) return;

    _isLoadingProperties = true;
    notifyListeners();

    final params = <String, dynamic>{
      'tab': 'properties',
      'page': _propertiesPage.toString(),
      'lang': _currentLang,
    };

    if (_selectedRegion != null) params['region_id'] = _selectedRegion;
    if (_selectedCity != null) params['city_id'] = _selectedCity;
    if (_selectedPropertyType != null) params['type'] = _selectedPropertyType;
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      params['search'] = _searchQuery;
    }

    final response = await ApiService.get('listings', params: params);

    _isLoadingProperties = false;

    if (response.success && response.data != null) {
      final listings = (response.data as List)
          .map((e) => ListingModel.fromJson(e))
          .toList();

      if (refresh) {
        _properties = listings;
      } else {
        _properties.addAll(listings);
      }

      _hasMoreProperties = response.pagination?['has_more'] ?? false;
      if (_hasMoreProperties) _propertiesPage++;
    }

    notifyListeners();
  }

  Future<void> fetchCars({bool refresh = false}) async {
    if (_isLoadingCars) return;
    if (refresh) {
      _carsPage = 1;
      _hasMoreCars = true;
    }
    if (!_hasMoreCars && !refresh) return;

    _isLoadingCars = true;
    notifyListeners();

    final params = <String, dynamic>{
      'tab': 'cars',
      'page': _carsPage.toString(),
      'lang': _currentLang,
    };

    if (_selectedRegion != null) params['region_id'] = _selectedRegion;
    if (_selectedCity != null) params['city_id'] = _selectedCity;
    if (_selectedCarUsageType != null) params['type'] = _selectedCarUsageType;
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      params['search'] = _searchQuery;
    }

    final response = await ApiService.get('listings', params: params);

    _isLoadingCars = false;

    if (response.success && response.data != null) {
      final listings = (response.data as List)
          .map((e) => ListingModel.fromJson(e))
          .toList();

      if (refresh) {
        _cars = listings;
      } else {
        _cars.addAll(listings);
      }

      _hasMoreCars = response.pagination?['has_more'] ?? false;
      if (_hasMoreCars) _carsPage++;
    }

    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    _isLoadingFavorites = true;
    notifyListeners();

    final response = await ApiService.get('favorites');

    _isLoadingFavorites = false;

    if (response.success && response.data != null) {
      _favorites = (response.data as List)
          .map((e) => ListingModel.fromJson(e))
          .toList();
    }

    notifyListeners();
  }

  Future<void> fetchMyListings({String? tab}) async {
    _isLoadingMyListings = true;
    notifyListeners();

    final params = <String, dynamic>{};
    if (tab != null) params['tab'] = tab;

    final response = await ApiService.get('users/my-listings', params: params);

    _isLoadingMyListings = false;

    if (response.success && response.data != null) {
      final dataList = response.data is List ? response.data : [];
      _myListings = (dataList as List)
          .map((e) => ListingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _myListings = [];
    }

    notifyListeners();
  }

  Future<bool> toggleFavorite(ListingModel listing) async {
    final type = listing.isProperty ? 'property' : 'car';
    final isFavorite = listing.isFavorite;

    ApiResponse response;
    if (isFavorite) {
      response = await ApiService.delete('favorites/${listing.id}?type=$type');
    } else {
      response = await ApiService.post(
        'favorites/${listing.id}',
        body: {'type': type},
      );
    }

    if (response.success) {
      // Update local state
      _updateFavoriteStatus(listing.id, listing.listingType, !isFavorite);
      notifyListeners();
      return true;
    }
    return false;
  }

  void _updateFavoriteStatus(int id, String type, bool isFavorite) {
    if (type == 'property') {
      final index = _properties.indexWhere((l) => l.id == id);
      if (index != -1) {
        _properties[index] = ListingModel(
          id: _properties[index].id,
          listingType: _properties[index].listingType,
          title: _properties[index].title,
          type: _properties[index].type,
          regionId: _properties[index].regionId,
          cityId: _properties[index].cityId,
          regionNameAr: _properties[index].regionNameAr,
          regionNameEn: _properties[index].regionNameEn,
          regionNameHe: _properties[index].regionNameHe,
          cityNameAr: _properties[index].cityNameAr,
          cityNameEn: _properties[index].cityNameEn,
          cityNameHe: _properties[index].cityNameHe,
          priceType: _properties[index].priceType,
          price: _properties[index].price,
          priceFrom: _properties[index].priceFrom,
          priceTo: _properties[index].priceTo,
          currency: _properties[index].currency,
          thumbnail: _properties[index].thumbnail,
          status: _properties[index].status,
          isFavorite: isFavorite,
          createdAt: _properties[index].createdAt,
          bedrooms: _properties[index].bedrooms,
          areaM2: _properties[index].areaM2,
        );
      }
    } else {
      final index = _cars.indexWhere((l) => l.id == id);
      if (index != -1) {
        _cars[index] = ListingModel(
          id: _cars[index].id,
          listingType: _cars[index].listingType,
          title: _cars[index].title,
          type: _cars[index].type,
          regionId: _cars[index].regionId,
          cityId: _cars[index].cityId,
          regionNameAr: _cars[index].regionNameAr,
          regionNameEn: _cars[index].regionNameEn,
          regionNameHe: _cars[index].regionNameHe,
          cityNameAr: _cars[index].cityNameAr,
          cityNameEn: _cars[index].cityNameEn,
          cityNameHe: _cars[index].cityNameHe,
          priceType: _cars[index].priceType,
          price: _cars[index].price,
          priceFrom: _cars[index].priceFrom,
          priceTo: _cars[index].priceTo,
          currency: _cars[index].currency,
          thumbnail: _cars[index].thumbnail,
          status: _cars[index].status,
          isFavorite: isFavorite,
          createdAt: _cars[index].createdAt,
          model: _cars[index].model,
          gearbox: _cars[index].gearbox,
          withDriver: _cars[index].withDriver,
        );
      }
    }

    if (!isFavorite) {
      _favorites.removeWhere((l) => l.id == id && l.listingType == type);
    }
  }

  void setFilters({
    String? regionId,
    String? cityId,
    String? propertyType,
    String? carUsageType,
    String? search,
  }) {
    _selectedRegion = regionId;
    _selectedCity = cityId;
    _selectedPropertyType = propertyType;
    _selectedCarUsageType = carUsageType;
    _searchQuery = search;
    notifyListeners();
  }

  void setPropertyTypeFilter(String? type) {
    _selectedPropertyType = type;
    notifyListeners();
  }

  void setCarUsageTypeFilter(String? type) {
    _selectedCarUsageType = type;
    notifyListeners();
  }

  void clearFilters() {
    _selectedRegion = null;
    _selectedCity = null;
    _selectedPropertyType = null;
    _selectedCarUsageType = null;
    _searchQuery = null;
    notifyListeners();
  }
}
