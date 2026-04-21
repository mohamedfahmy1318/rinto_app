import 'package:flutter/material.dart';
import '../models/listing_type_model.dart';
import '../services/api_service.dart';

class ListingTypesProvider extends ChangeNotifier {
  List<ListingTypeModel> _propertyTypes = [];
  List<ListingTypeModel> _carTypes = [];
  bool _isLoading = false;
  bool _hasLoaded = false;

  List<ListingTypeModel> get propertyTypes => _propertyTypes;
  List<ListingTypeModel> get carTypes => _carTypes;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;

  Future<void> fetchTypes({bool force = false}) async {
    if (_hasLoaded && !force) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('types');

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        if (data['property_types'] != null) {
          _propertyTypes = (data['property_types'] as List)
              .map((e) => ListingTypeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        if (data['car_types'] != null) {
          _carTypes = (data['car_types'] as List)
              .map((e) => ListingTypeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        _hasLoaded = true;
      }
    } catch (e) {
      debugPrint('Error fetching types: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  ListingTypeModel? getPropertyTypeById(int id) {
    try {
      return _propertyTypes.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  ListingTypeModel? getCarTypeById(int id) {
    try {
      return _carTypes.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  ListingTypeModel? getPropertyTypeBySlug(String slug) {
    try {
      return _propertyTypes.firstWhere((t) => t.slug == slug);
    } catch (e) {
      return null;
    }
  }

  ListingTypeModel? getCarTypeBySlug(String slug) {
    try {
      return _carTypes.firstWhere((t) => t.slug == slug);
    } catch (e) {
      return null;
    }
  }
}
