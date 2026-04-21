import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../models/listing_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../services/api_service.dart';
import '../../services/chat_service.dart';
import '../chat/chat_screen.dart';
import '../auth/login_screen.dart';

class ListingDetailsScreen extends StatefulWidget {
  final ListingModel listing;

  const ListingDetailsScreen({super.key, required this.listing});

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  int _currentImageIndex = 0;
  late PageController _pageController;
  ListingModel? _fullListing;
  bool _isLoading = true;

  ListingModel get listing => _fullListing ?? widget.listing;

  Future<void> _toggleFavorite() async {
    final provider = Provider.of<ListingsProvider>(context, listen: false);
    final success = await provider.toggleFavorite(listing);
    if (success && mounted && _fullListing != null) {
      setState(() {
        _fullListing = ListingModel(
          id: _fullListing!.id,
          listingType: _fullListing!.listingType,
          title: _fullListing!.title,
          type: _fullListing!.type,
          regionId: _fullListing!.regionId,
          cityId: _fullListing!.cityId,
          regionNameAr: _fullListing!.regionNameAr,
          regionNameEn: _fullListing!.regionNameEn,
          regionNameHe: _fullListing!.regionNameHe,
          cityNameAr: _fullListing!.cityNameAr,
          cityNameEn: _fullListing!.cityNameEn,
          cityNameHe: _fullListing!.cityNameHe,
          priceType: _fullListing!.priceType,
          price: _fullListing!.price,
          priceFrom: _fullListing!.priceFrom,
          priceTo: _fullListing!.priceTo,
          currency: _fullListing!.currency,
          thumbnail: _fullListing!.thumbnail,
          images: _fullListing!.images,
          status: _fullListing!.status,
          isFavorite: !_fullListing!.isFavorite,
          createdAt: _fullListing!.createdAt,
          bedrooms: _fullListing!.bedrooms,
          bathrooms: _fullListing!.bathrooms,
          areaM2: _fullListing!.areaM2,
          floor: _fullListing!.floor,
          model: _fullListing!.model,
          gearbox: _fullListing!.gearbox,
          withDriver: _fullListing!.withDriver,
          priceDaily: _fullListing!.priceDaily,
          priceWeekly: _fullListing!.priceWeekly,
          priceMonthly: _fullListing!.priceMonthly,
          userId: _fullListing!.userId,
          userName: _fullListing!.userName,
          bio: _fullListing!.bio,
          contactPhone: _fullListing!.contactPhone,
          whatsapp: _fullListing!.whatsapp,
          titleAr: _fullListing!.titleAr,
          titleEn: _fullListing!.titleEn,
          titleHe: _fullListing!.titleHe,
          bioAr: _fullListing!.bioAr,
          bioEn: _fullListing!.bioEn,
          bioHe: _fullListing!.bioHe,
          badge: _fullListing!.badge,
          isFeatured: _fullListing!.isFeatured,
          isTrusted: _fullListing!.isTrusted,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchFullListing();
  }

  Future<void> _fetchFullListing() async {
    final type = widget.listing.isProperty ? 'properties' : 'cars';
    final response = await ApiService.get('$type/${widget.listing.id}');

    if (mounted && response.success && response.data != null) {
      setState(() {
        _fullListing = ListingModel.fromJson(response.data);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getTimeAgo(String lang) {
    try {
      final now = DateTime.now();
      final diff = now.difference(listing.createdAt);
      if (diff.inDays > 0) {
        if (lang == 'he') return 'לפני ${diff.inDays} ימים';
        if (lang == 'en') return '${diff.inDays} days ago';
        return 'منذ ${diff.inDays} يوم';
      } else if (diff.inHours > 0) {
        if (lang == 'he') return 'לפני ${diff.inHours} שעות';
        if (lang == 'en') return '${diff.inHours} hours ago';
        return 'منذ ${diff.inHours} ساعة';
      } else {
        if (lang == 'he') return 'לפני ${diff.inMinutes} דקות';
        if (lang == 'en') return '${diff.inMinutes} minutes ago';
        return 'منذ ${diff.inMinutes} دقيقة';
      }
    } catch (_) {
      return '';
    }
  }

  String _getPropertyTypeName(String lang) {
    final type = listing.type;
    if (type == null) return '';
    final types = {
      'apartment': {'ar': 'شقة', 'he': 'דירה', 'en': 'Apartment'},
      'villa_chalet': {'ar': 'فيلا/شاليه', 'he': 'וילה', 'en': 'Villa'},
      'shop_office': {'ar': 'محل/مكتب', 'he': 'חנות', 'en': 'Shop'},
      'student_housing': {
        'ar': 'سكن طلاب',
        'he': 'דיור סטודנטים',
        'en': 'Student',
      },
      'land': {'ar': 'أرض', 'he': 'קרקע', 'en': 'Land'},
      'daily': {'ar': 'يومي', 'he': 'יומי', 'en': 'Daily'},
      'wedding': {'ar': 'أعراس', 'he': 'חתונות', 'en': 'Wedding'},
      'tourism': {'ar': 'سياحة', 'he': 'תיירות', 'en': 'Tourism'},
    };
    return types[type]?[lang] ?? types[type]?['ar'] ?? type;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<AppProvider>(context).languageCode;
    final allImages = listing.images.isNotEmpty
        ? listing.images
        : (listing.thumbnail != null ? [listing.thumbnail!] : <String>[]);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade100,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Image Section with floating buttons
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Stack(
                    children: [
                      // Image Carousel
                      allImages.isNotEmpty
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: allImages.length,
                              onPageChanged: (index) {
                                setState(() => _currentImageIndex = index);
                              },
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: allImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  placeholder: (_, __) => Container(
                                    color: isDark
                                        ? AppColors.darkCard
                                        : Colors.grey.shade300,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      _buildPlaceholder(isDark),
                                );
                              },
                            )
                          : _buildPlaceholder(isDark),

                      // Top floating buttons
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            _buildFloatingButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.pop(context),
                            ),
                            // Action buttons
                            Row(
                              children: [
                                _buildFloatingButton(
                                  icon: listing.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  onTap: _toggleFavorite,
                                  iconColor: listing.isFavorite
                                      ? Colors.red
                                      : Colors.white,
                                ),
                                const SizedBox(width: 8),
                                _buildFloatingButton(
                                  icon: Icons.flag_outlined,
                                  onTap: () => _showReportDialog(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Image indicator dots
                      if (allImages.length > 1)
                        Positioned(
                          bottom: 60,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              allImages.length,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: _currentImageIndex == index ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == index
                                      ? AppColors.primary
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // White Card Section
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags Row + Price
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tags
                              Expanded(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildTag(
                                      _getPropertyTypeName(lang),
                                      isDark,
                                    ),
                                    _buildTag(
                                      listing.getRegionName(lang),
                                      isDark,
                                    ),
                                  ],
                                ),
                              ),
                              // Price
                              Text(
                                listing.getPrice(),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Featured Badge (if trusted)
                          if (listing.isTrusted == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                lang == 'he'
                                    ? 'מומלץ'
                                    : (lang == 'en' ? 'Featured' : 'مميز'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (listing.isTrusted == true)
                            const SizedBox(height: 12),

                          // Title
                          Text(
                            listing.getTitle(lang).isNotEmpty
                                ? listing.getTitle(lang)
                                : listing.getModel(lang),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Location & Time
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: isDark
                                    ? Colors.grey
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                listing.getCityName(lang),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: isDark
                                    ? Colors.grey
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getTimeAgo(lang),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Details Grid 2x2
                          if (listing.isProperty)
                            _buildPropertyDetailsGrid(isDark, lang)
                          else
                            _buildCarDetailsGrid(isDark, lang),

                          const SizedBox(height: 24),

                          // Description
                          if (listing.getBio(lang).isNotEmpty) ...[
                            Text(
                              lang == 'he'
                                  ? 'תיאור'
                                  : (lang == 'en' ? 'Description' : 'الوصف'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              listing.getBio(lang),
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Multiple prices (daily/weekly/monthly) for both cars and properties
                          if (_hasMultiplePrices()) ...[
                            _buildCarPricesSection(isDark, lang),
                            const SizedBox(height: 24),
                          ],

                          // Extra space for bottom button
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Call Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildBottomButtons(context, isDark, lang),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPropertyDetailsGrid(bool isDark, String lang) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        if (listing.bedrooms != null)
          _buildDetailBox(
            icon: Icons.bed_outlined,
            label: lang == 'he'
                ? 'חדרי שינה'
                : (lang == 'en' ? 'Bedrooms' : 'غرف النوم'),
            value: '${listing.bedrooms}',
            isDark: isDark,
          ),
        if (listing.bathrooms != null)
          _buildDetailBox(
            icon: Icons.bathtub_outlined,
            label: lang == 'he'
                ? 'חדרי אמבטיה'
                : (lang == 'en' ? 'Bathrooms' : 'الحمامات'),
            value: '${listing.bathrooms}',
            isDark: isDark,
          ),
        if (listing.areaM2 != null)
          _buildDetailBox(
            icon: Icons.square_foot_outlined,
            label: lang == 'he' ? 'שטח' : (lang == 'en' ? 'Area' : 'المساحة'),
            value: '${listing.areaM2!.toInt()} m²',
            isDark: isDark,
          ),
        if (listing.floor != null)
          _buildDetailBox(
            icon: Icons.stairs_outlined,
            label: lang == 'he' ? 'קומה' : (lang == 'en' ? 'Floor' : 'الطابق'),
            value: '${listing.floor}',
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildCarDetailsGrid(bool isDark, String lang) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        if (listing.model != null)
          _buildDetailBox(
            icon: Icons.directions_car_outlined,
            label: lang == 'he' ? 'דגם' : (lang == 'en' ? 'Model' : 'الموديل'),
            value: listing.getModel(lang),
            isDark: isDark,
          ),
        if (listing.gearbox != null)
          _buildDetailBox(
            icon: Icons.settings_outlined,
            label: lang == 'he'
                ? 'תיבת הילוכים'
                : (lang == 'en' ? 'Gearbox' : 'ناقل الحركة'),
            value: listing.gearbox == 'automatic'
                ? (lang == 'he'
                      ? 'אוטומטי'
                      : (lang == 'en' ? 'Automatic' : 'أوتوماتيك'))
                : (lang == 'he' ? 'ידני' : (lang == 'en' ? 'Manual' : 'عادي')),
            isDark: isDark,
          ),
        _buildDetailBox(
          icon: Icons.person_outline,
          label: lang == 'he' ? 'נהג' : (lang == 'en' ? 'Driver' : 'السائق'),
          value: listing.withDriver == true
              ? (lang == 'he'
                    ? 'עם נהג'
                    : (lang == 'en' ? 'With driver' : 'مع سائق'))
              : (lang == 'he'
                    ? 'בלי נהג'
                    : (lang == 'en' ? 'Without driver' : 'بدون سائق')),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDetailBox({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, double price) {
    return Column(
      children: [
        Text(
          '${price.toInt()} ₪',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCarPricesSection(bool isDark, String lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.5)
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (listing.priceDaily != null && listing.priceDaily! > 0)
            _buildPriceItem(
              lang == 'he' ? 'יומי' : (lang == 'en' ? 'Daily' : 'يومي'),
              listing.priceDaily!,
            ),
          if (listing.priceWeekly != null && listing.priceWeekly! > 0)
            _buildPriceItem(
              lang == 'he' ? 'שבועי' : (lang == 'en' ? 'Weekly' : 'أسبوعي'),
              listing.priceWeekly!,
            ),
          if (listing.priceMonthly != null && listing.priceMonthly! > 0)
            _buildPriceItem(
              lang == 'he' ? 'חודשי' : (lang == 'en' ? 'Monthly' : 'شهري'),
              listing.priceMonthly!,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, bool isDark, String lang) {
    final hasPhone =
        listing.contactPhone != null && listing.contactPhone!.isNotEmpty;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isOwnListing = auth.user?.id.toString() == listing.userId.toString();

    return Row(
      children: [
        // Call Button (main)
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: hasPhone
                ? () => _makePhoneCall(listing.contactPhone!)
                : null,
            icon: const Icon(Icons.phone, size: 20),
            label: Text(
              '${lang == 'he' ? 'התקשר' : (lang == 'en' ? 'Call' : 'اتصل')}: ${listing.contactPhone ?? ''}',
              style: const TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Chat (in-app messaging)
        if (!isOwnListing)
          _buildSmallActionButton(
            icon: Icons.chat_bubble_outline,
            color: AppColors.primary,
            onTap: () => _startChat(context),
          ),
        if (!isOwnListing) const SizedBox(width: 10),
        // WhatsApp
        _buildWhatsAppButton(
          onTap: () =>
              _openWhatsApp(listing.whatsapp ?? listing.contactPhone ?? ''),
        ),
      ],
    );
  }

  Widget _buildSmallActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildWhatsAppButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF25D366),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'WA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final lang = Provider.of<AppProvider>(context, listen: false).languageCode;

    if (!auth.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    String getText(String en, String he, String ar) {
      if (lang == 'he') return he;
      if (lang == 'en') return en;
      return ar;
    }

    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          bool isSending = false;

          return StatefulBuilder(
            builder: (ctx, setStateSending) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.flag_outlined, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(getText('Report Listing', 'דווח על מודעה', 'الإبلاغ عن الإعلان')),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getText(
                        'Please describe the reason for reporting this listing:',
                        'אנא תאר את סיבת הדיווח על מודעה זו:',
                        'يرجى وصف سبب الإبلاغ عن هذا الإعلان:',
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 4,
                      maxLength: 1000,
                      textDirection: lang == 'en' ? TextDirection.ltr : TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: getText(
                          'e.g. Fake listing, wrong price...',
                          'לדוגמה: מודעה מזויפת, מחיר שגוי...',
                          'مثال: إعلان مزيف، سعر خاطئ...',
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().length < 10) {
                          return getText(
                            'Please write at least 10 characters',
                            'אנא כתוב לפחות 10 תווים',
                            'يرجى كتابة 10 أحرف على الأقل',
                          );
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(ctx),
                  child: Text(getText('Cancel', 'ביטול', 'إلغاء')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isSending
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setStateSending(() => isSending = true);

                          final response = await ApiService.post(
                            'reports',
                            body: {
                              'listing_type': listing.listingType,
                              'listing_id': listing.id,
                              'reason': reasonController.text.trim(),
                            },
                          );

                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response.success
                                    ? getText(
                                        'Report submitted. Thank you!',
                                        'הדיווח נשלח. תודה!',
                                        'تم إرسال البلاغ. شكراً!',
                                      )
                                    : (response.message.isNotEmpty
                                        ? response.message
                                        : getText('Error occurred', 'אירעה שגיאה', 'حدث خطأ')),
                              ),
                              backgroundColor: response.success ? Colors.green : Colors.red,
                            ),
                          );
                        },
                  child: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(getText('Submit Report', 'שלח דיווח', 'إرسال البلاغ'),
                          style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Center(
        child: Icon(
          listing.isProperty ? Icons.apartment : Icons.directions_car,
          size: 64,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  bool _hasMultiplePrices() {
    int priceCount = 0;
    if (listing.priceDaily != null && listing.priceDaily! > 0) priceCount++;
    if (listing.priceWeekly != null && listing.priceWeekly! > 0) priceCount++;
    if (listing.priceMonthly != null && listing.priceMonthly! > 0) priceCount++;
    return priceCount > 0;
  }

  Future<void> _startChat(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!auth.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final response = await ChatService.getOrCreateConversation(
      listingType: listing.isProperty ? 'property' : 'car',
      listingId: listing.id,
    );

    if (mounted) {
      Navigator.pop(context); // Close loading

      if (response.success && response.data != null) {
        final rawId = response.data['id'];
        final conversationId = rawId is int
            ? rawId
            : int.tryParse(rawId.toString()) ?? 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversationId,
              otherUserName: listing.userName ?? 'صاحب الإعلان',
              listingTitle: listing.title ?? '',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty ? response.message : 'حدث خطأ',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
