import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/locations/city.dart';
import '../../../providers/app_provider.dart';

/// Dropdown of [City] entities filtered by [selectedRegionId].
///
/// When the region changes and the currently-selected city no longer
/// belongs to the new region, this widget emits `onChanged(null)` so
/// the parent state can clear its city selection.
class CityPicker extends StatelessWidget {
  const CityPicker({
    super.key,
    required this.cities,
    required this.selectedRegionId,
    required this.selected,
    required this.onChanged,
  });

  final List<City> cities;
  final int? selectedRegionId;
  final int? selected;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppProvider>(context).languageCode;
    final filtered = selectedRegionId == null
        ? cities
        : cities.where((c) => c.regionId == selectedRegionId).toList();

    // If the current selection isn't in the filtered list, clear it.
    final validSelected =
        filtered.any((c) => c.id == selected) ? selected : null;
    if (validSelected != selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChanged(null);
      });
    }

    return DropdownButtonFormField<int>(
      // See RegionPicker for the reason this `value` stays.
      // ignore: deprecated_member_use
      value: validSelected,
      decoration: InputDecoration(
        labelText: context.tr('city'),
        prefixIcon: const Icon(Icons.location_city_outlined),
      ),
      items: filtered
          .map(
            (c) => DropdownMenuItem<int>(
              value: c.id,
              child: Text(c.localizedName(lang)),
            ),
          )
          .toList(),
      onChanged: filtered.isEmpty ? null : onChanged,
    );
  }
}
