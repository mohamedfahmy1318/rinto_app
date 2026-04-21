import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../models/banner_model.dart';

class BannerDetailsScreen extends StatefulWidget {
  final BannerModel banner;

  const BannerDetailsScreen({super.key, required this.banner});

  @override
  State<BannerDetailsScreen> createState() => _BannerDetailsScreenState();
}

class _BannerDetailsScreenState extends State<BannerDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;
    final banner = widget.banner;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: _buildImageGallery()),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lang == 'he' ? 'מודעה מומלצת' : 'إعلان مميز',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    banner.getTitle(lang),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location
                  if (banner.getCityName(lang).isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${banner.getCityName(lang)}${banner.getRegionName(lang).isNotEmpty ? ' - ${banner.getRegionName(lang)}' : ''}',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Price
                  if (banner.getPrice().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.payments, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            banner.getPrice(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Details based on type
                  if (banner.isProperty) _buildPropertyDetails(isDark, lang),
                  if (banner.isCar) _buildCarDetails(isDark, lang),

                  // Description
                  if (banner.getDescription(lang).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      lang == 'he' ? 'תיאור' : 'الوصف',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      banner.getDescription(lang),
                      style: TextStyle(
                        height: 1.6,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],

                  // Address
                  if (banner.addressText != null &&
                      banner.addressText!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      lang == 'he' ? 'כתובת' : 'العنوان',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(banner.addressText!),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildContactBar(isDark, lang),
    );
  }

  Widget _buildImageGallery() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final images = widget.banner.images.isNotEmpty
        ? widget.banner.images
        : (widget.banner.thumbnail != null ? [widget.banner.thumbnail!] : []);

    if (images.isEmpty) {
      return Container(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        child: Center(
          child: Icon(
            Icons.image,
            size: 64,
            color: isDark ? Colors.grey.shade600 : Colors.grey,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background color
        Container(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),

        // Image PageView
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Container(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              child: Image.network(
                images[index],
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Page indicators
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Image counter
        if (images.length > 1)
          Positioned(
            top: 60,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPropertyDetails(bool isDark, String lang) {
    final banner = widget.banner;
    final details = <Widget>[];

    if (banner.bedrooms != null) {
      details.add(
        _buildDetailItem(
          Icons.bed,
          '${banner.bedrooms}',
          lang == 'he' ? 'חדרי שינה' : 'غرف نوم',
          isDark,
        ),
      );
    }

    if (banner.bathrooms != null) {
      details.add(
        _buildDetailItem(
          Icons.bathtub,
          '${banner.bathrooms}',
          lang == 'he' ? 'חדרי אמבט' : 'حمامات',
          isDark,
        ),
      );
    }

    if (banner.areaM2 != null) {
      details.add(
        _buildDetailItem(
          Icons.square_foot,
          '${banner.areaM2!.toInt()} م²',
          lang == 'he' ? 'שטח' : 'المساحة',
          isDark,
        ),
      );
    }

    if (banner.floor != null) {
      details.add(
        _buildDetailItem(
          Icons.layers,
          '${banner.floor}',
          lang == 'he' ? 'קומה' : 'الطابق',
          isDark,
        ),
      );
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: details,
      ),
    );
  }

  Widget _buildCarDetails(bool isDark, String lang) {
    final banner = widget.banner;
    final details = <Widget>[];

    if (banner.carModel != null) {
      details.add(
        _buildDetailItem(
          Icons.directions_car,
          banner.carModel!,
          lang == 'he' ? 'דגם' : 'الموديل',
          isDark,
        ),
      );
    }

    if (banner.carYear != null) {
      details.add(
        _buildDetailItem(
          Icons.calendar_today,
          '${banner.carYear}',
          lang == 'he' ? 'שנה' : 'السنة',
          isDark,
        ),
      );
    }

    if (banner.gearbox != null) {
      details.add(
        _buildDetailItem(
          Icons.settings,
          banner.gearbox == 'automatic'
              ? (lang == 'he' ? 'אוטומטי' : 'أوتوماتيك')
              : (lang == 'he' ? 'ידני' : 'عادي'),
          lang == 'he' ? 'תיבת הילוכים' : 'ناقل الحركة',
          isDark,
        ),
      );
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: details,
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String value,
    String label,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContactBar(bool isDark, String lang) {
    final banner = widget.banner;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (banner.contactPhone != null &&
              banner.contactPhone!.isNotEmpty) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchPhone(banner.contactPhone!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.phone),
                label: Text(lang == 'he' ? 'התקשר' : 'اتصال'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (banner.whatsapp != null && banner.whatsapp!.isNotEmpty)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchWhatsApp(banner.whatsapp!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.chat),
                label: Text(lang == 'he' ? 'וואטסאפ' : 'واتساب'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
