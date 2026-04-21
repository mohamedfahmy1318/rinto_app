import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/listing_model.dart';
import '../../providers/app_provider.dart';
import '../listing_details/listing_details_screen.dart';

class GridListingCard extends StatelessWidget {
  final ListingModel listing;

  const GridListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<AppProvider>(context).languageCode;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailsScreen(listing: listing),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: AppColors.darkCardBorder.withOpacity(0.3))
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Price Badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Image
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: listing.thumbnail != null
                        ? CachedNetworkImage(
                            imageUrl: listing.thumbnail!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: isDark
                                  ? AppColors.darkCard
                                  : Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary.withOpacity(0.5),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) =>
                                _buildPlaceholder(isDark),
                          )
                        : _buildPlaceholder(isDark),
                  ),
                  // Price Badge - Top Right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        listing.getPrice(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Featured Badge - Top Left
                  if (listing.isFeatured && listing.isActive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getBadgeLabel(listing.badge, lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Status Badge (for non-active)
                  if (!listing.isActive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          listing.getStatusLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Rented Badge - Bottom Right
                  if (listing.isRented && listing.isActive)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.home_work,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lang == 'he'
                                  ? 'מושכר'
                                  : (lang == 'en' ? 'Rented' : 'مؤجر'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.getTitle(lang).isNotEmpty
                        ? listing.getTitle(lang)
                        : (listing.isProperty
                              ? context.tr('for_rent')
                              : listing.getModel(lang).isNotEmpty
                              ? listing.getModel(lang)
                              : context.tr('for_rent')),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Location & Time
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${listing.getCityName(lang)} • ${_getTimeAgo(listing.createdAt.toIso8601String(), lang)}',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(String? dateString, String lang) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 30) {
        final months = (diff.inDays / 30).floor();
        return lang == 'en'
            ? '$months month'
            : (lang == 'he' ? '$months חודש' : '$months شهر');
      } else if (diff.inDays > 0) {
        return lang == 'en'
            ? '${diff.inDays} days'
            : (lang == 'he' ? '${diff.inDays} ימים' : '${diff.inDays} أيام');
      } else if (diff.inHours > 0) {
        return lang == 'en'
            ? '${diff.inHours} hours'
            : (lang == 'he' ? '${diff.inHours} שעות' : '${diff.inHours} ساعات');
      } else {
        return lang == 'en' ? 'Now' : (lang == 'he' ? 'עכשיו' : 'الآن');
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkCardBorder : Colors.grey.shade200,
      child: Center(
        child: Icon(
          listing.isProperty ? Icons.apartment : Icons.directions_car,
          size: 40,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (listing.status) {
      case 'draft':
      case 'pending_admin_review':
        return Colors.orange;
      case 'pending_payment':
        return Colors.blue;
      case 'paused':
        return Colors.grey;
      case 'expired':
        return Colors.grey.shade700;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getBadgeLabel(String? badge, String lang) {
    switch (badge) {
      case 'gold':
        return lang == 'en' ? 'Gold' : (lang == 'he' ? 'זהב' : 'ذهبي');
      case 'silver':
        return lang == 'en' ? 'Silver' : (lang == 'he' ? 'כסף' : 'فضي');
      case 'bronze':
        return lang == 'en' ? 'Bronze' : (lang == 'he' ? 'ארד' : 'برونزي');
      default:
        return lang == 'en' ? 'Featured' : (lang == 'he' ? 'מומלץ' : 'مميز');
    }
  }
}
