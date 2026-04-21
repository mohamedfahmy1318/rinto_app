import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/listing_model.dart';
import '../../providers/listings_provider.dart';
import '../../providers/app_provider.dart';
import '../listing_details/listing_details_screen.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;

  const ListingCard({super.key, required this.listing});

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
        height: 140,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: listing.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: listing.thumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: isDark
                              ? AppColors.darkCard
                              : Colors.grey.shade300,
                        ),
                        errorWidget: (_, __, ___) => _buildPlaceholder(isDark),
                      )
                    : _buildPlaceholder(isDark),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Right side - Title and info
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            listing.getTitle(lang).isNotEmpty
                                ? listing.getTitle(lang)
                                : (listing.isProperty
                                      ? context.tr('for_rent')
                                      : context.tr('for_rent')),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${listing.getCityName(lang)}، ${listing.getRegionName(lang)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
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
                    // Left side - Price and details
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                listing.getPrice(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (listing.isProperty && listing.areaM2 != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.square_foot,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${listing.areaM2!.toInt()} متر',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          if (listing.isProperty && listing.bedrooms != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.bed,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${listing.bedrooms} م',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Favorite Button
              Positioned(
                bottom: 12,
                left: 12,
                child: _buildFavoriteButton(context),
              ),
              // Status Badge (for non-active listings)
              if (!listing.isActive)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      listing.getStatusLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Featured Badge
              if (listing.isFeatured && listing.isActive)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getBadgeColors(listing.badge),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _getBadgeColors(
                            listing.badge,
                          )[0].withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          _getBadgeLabel(listing.badge, context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Rented Badge - Bottom Right
              if (listing.isRented && listing.isActive)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
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
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lang == 'he'
                              ? 'מושכר'
                              : (lang == 'en' ? 'Rented' : 'مؤجر'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Trusted Badge
              if (listing.isTrusted && listing.isActive)
                Positioned(
                  top: listing.isFeatured ? 44 : 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('featured_listing'),
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
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
      child: Center(
        child: Icon(
          listing.isProperty ? Icons.apartment : Icons.directions_car,
          size: 48,
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

  List<Color> _getBadgeColors(String? badge) {
    switch (badge) {
      case 'gold':
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 'silver':
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)];
      case 'bronze':
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      default:
        return [Colors.blue, Colors.blueAccent];
    }
  }

  String _getBadgeLabel(String? badge, BuildContext context) {
    final lang = Provider.of<AppProvider>(context, listen: false).languageCode;
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

  Widget _buildFavoriteButton(BuildContext context) {
    return Consumer<ListingsProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () => provider.toggleFavorite(listing),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              listing.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: listing.isFavorite ? Colors.red : Colors.white,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPropertyInfo(BuildContext context, bool isDark) {
    return Row(
      children: [
        if (listing.bedrooms != null) ...[
          _buildInfoChip(Icons.bed_rounded, '${listing.bedrooms}', isDark),
          const SizedBox(width: 12),
        ],
        if (listing.areaM2 != null) ...[
          _buildInfoChip(
            Icons.square_foot_rounded,
            '${listing.areaM2!.toInt()} م²',
            isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildCarInfo(BuildContext context, bool isDark) {
    final lang = Provider.of<AppProvider>(context, listen: false).languageCode;
    return Row(
      children: [
        if (listing.model != null) ...[
          _buildInfoChip(Icons.directions_car, listing.getModel(lang), isDark),
          const SizedBox(width: 12),
        ],
        if (listing.gearbox != null) ...[
          _buildInfoChip(
            Icons.settings,
            listing.gearbox == 'automatic' ? 'أوتوماتيك' : 'عادي',
            isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
