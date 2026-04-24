import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../domain/locations/region.dart';
import '../../../providers/app_provider.dart';

/// Dropdown of [Region] entities. Disabled while the list is empty
/// (loading). Surfaces the current UI language via [AppProvider] to
/// render localized region names.
class RegionPicker extends StatelessWidget {
  const RegionPicker({
    super.key,
    required this.regions,
    required this.selected,
    required this.onChanged,
  });

  final List<Region> regions;
  final int? selected;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppProvider>(context).languageCode;
    return DropdownButtonFormField<int>(
      // `value` is deprecated in favour of `initialValue`, but
      // `initialValue` is uncontrolled — it ignores later parent
      // rebuilds. This picker is state-driven, so we need the
      // controlled form. Drop this ignore when Flutter exposes a
      // controlled replacement.
      // ignore: deprecated_member_use
      value: selected,
      decoration: InputDecoration(
        labelText: context.tr('region'),
        prefixIcon: const Icon(Icons.location_on_outlined),
      ),
      items: regions
          .map(
            (r) => DropdownMenuItem<int>(
              value: r.id,
              child: Text(r.localizedName(lang)),
            ),
          )
          .toList(),
      onChanged: regions.isEmpty ? null : onChanged,
    );
  }
}
