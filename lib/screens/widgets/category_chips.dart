import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/listing_types_provider.dart';

class CategoryChips extends StatefulWidget {
  final String type;
  final Function(String?)? onFilterChanged;

  const CategoryChips({super.key, required this.type, this.onFilterChanged});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingTypesProvider>(context, listen: false).fetchTypes();
    });
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'apartment':
        return Icons.apartment;
      case 'home':
        return Icons.home;
      case 'house':
        return Icons.house;
      case 'villa':
        return Icons.villa;
      case 'cabin':
        return Icons.cabin;
      case 'bed':
        return Icons.bed;
      case 'hotel':
        return Icons.hotel;
      case 'store':
        return Icons.store;
      case 'storefront':
        return Icons.storefront;
      case 'work':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'domain':
        return Icons.domain;
      case 'school':
        return Icons.school;
      case 'landscape':
        return Icons.landscape;
      case 'terrain':
        return Icons.terrain;
      case 'location_city':
        return Icons.location_city;
      case 'corporate_fare':
        return Icons.corporate_fare;
      case 'directions_car':
        return Icons.directions_car;
      case 'car_rental':
        return Icons.car_rental;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'airport_shuttle':
        return Icons.airport_shuttle;
      case 'favorite':
        return Icons.favorite;
      case 'flight':
        return Icons.flight;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'event':
        return Icons.event;
      default:
        return widget.type == 'property' ? Icons.home : Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final loc = AppLocalizations.of(context);

    return Consumer<ListingTypesProvider>(
      builder: (context, typesProvider, _) {
        final types = widget.type == 'property'
            ? typesProvider.propertyTypes
            : typesProvider.carTypes;

        // Build categories list with "All" option
        final categories = <Map<String, dynamic>>[
          {'key': null, 'label': loc.translate('all'), 'icon': Icons.grid_view},
          ...types.map(
            (t) => {
              'key': t.slug,
              'label': t.getName(lang),
              'icon': _getIconFromName(t.icon),
            },
          ),
        ];

        if (typesProvider.isLoading && types.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = index == _selectedIndex;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = index);
                  widget.onFilterChanged?.call(category['key'] as String?);
                },
                child: Container(
                  width: 75,
                  margin: const EdgeInsets.only(left: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          color: isDark
                              ? AppColors.darkCard
                              : Colors.grey.shade100,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          size: 28,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? Colors.white70
                                    : Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
