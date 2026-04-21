import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../models/listing_model.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../add_listing/add_listing_screen.dart';
import '../edit_listing/edit_listing_screen.dart';
import '../listing_details/listing_details_screen.dart';
import '../auth/login_screen.dart';
import '../widgets/subscription_warning_banner.dart';
import '../checkout/checkout_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadListings();
    });
  }

  Future<void> _loadListings() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Wait for auth to initialize
    int retries = 0;
    while (!auth.isInitialized && retries < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      retries++;
      if (!mounted) return;
    }

    if (auth.isLoggedIn && mounted) {
      await Provider.of<ListingsProvider>(
        context,
        listen: false,
      ).fetchMyListings();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('my_listings')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          tabs: [
            Tab(text: context.tr('properties')),
            Tab(text: context.tr('cars')),
          ],
        ),
      ),
      body: Column(
        children: [
          // Subscription Warning Banner
          const SubscriptionWarningBanner(),
          // Listings
          Expanded(
            child: Consumer<ListingsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingMyListings) {
                  return const Center(child: CircularProgressIndicator());
                }

                final properties = provider.myListings
                    .where((l) => l.isProperty)
                    .toList();
                final cars = provider.myListings.where((l) => l.isCar).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildListView(properties, context.tr('no_results')),
                    _buildListView(cars, context.tr('no_results')),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddListingDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(context.tr('add')),
      ),
    );
  }

  void _showAddListingDialog(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Check if logged in
    if (!auth.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Any registered user can add listings (subscription required for activation)
    // Show dialog to choose listing type
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إضافة إعلان جديد',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildListingTypeButton(
              context,
              icon: Icons.apartment,
              title: 'عقار',
              subtitle: 'شقة، فيلا، محل، أرض...',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddListingScreen(listingType: 'property'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildListingTypeButton(
              context,
              icon: Icons.directions_car,
              title: 'سيارة',
              subtitle: 'سيارة للإيجار اليومي أو للأعراس',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddListingScreen(listingType: 'car'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildListingTypeButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<ListingModel> listings, String emptyMessage) {
    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt_rounded,
              size: 64,
              color: AppColors.darkTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(emptyMessage),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => Provider.of<ListingsProvider>(
        context,
        listen: false,
      ).fetchMyListings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final listing = listings[index];
          return _buildMyListingCard(listing);
        },
      ),
    );
  }

  Widget _buildMyListingCard(ListingModel listing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image with status overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: listing.thumbnail != null
                      ? Image.network(
                          listing.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              // Expired overlay
              if (listing.isExpired)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_off,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lang == 'he' ? 'פג תוקף' : 'منتهي الصلاحية',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Status badge
              Positioned(
                top: 12,
                right: 12,
                child: _buildStatusBadge(listing, lang),
              ),
              // Type badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        listing.isProperty
                            ? Icons.apartment
                            : Icons.directions_car,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        listing.isProperty
                            ? (lang == 'he' ? 'נכס' : 'عقار')
                            : (lang == 'he' ? 'רכב' : 'سيارة'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  listing.getTitle(lang),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.getCityName(lang),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Price and expiry row
                Row(
                  children: [
                    // Price
                    Text(
                      listing.getPrice(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    // Expiry info
                    if (listing.expiresAt != null && !listing.isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: listing.daysRemaining <= 3
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: listing.daysRemaining <= 3
                                  ? Colors.orange
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lang == 'he'
                                  ? '${listing.daysRemaining} ימים'
                                  : '${listing.daysRemaining} يوم',
                              style: TextStyle(
                                fontSize: 12,
                                color: listing.daysRemaining <= 3
                                    ? Colors.orange
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                // Rejection reason
                if (listing.isRejected && listing.rejectReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            listing.rejectReason!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Action buttons
                _buildActionButtons(listing, lang),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.image, size: 40, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildStatusBadge(ListingModel listing, String lang) {
    Color bgColor;
    Color textColor = Colors.white;
    String label;
    IconData icon;

    if (listing.isExpired) {
      bgColor = Colors.red;
      label = lang == 'he' ? 'פג תוקף' : 'منتهي';
      icon = Icons.timer_off;
    } else if (listing.isRejected) {
      bgColor = Colors.red;
      label = lang == 'he' ? 'נדחה' : 'مرفوض';
      icon = Icons.close;
    } else if (listing.isPending) {
      bgColor = Colors.orange;
      label = lang == 'he' ? 'ממתין' : 'قيد المراجعة';
      icon = Icons.hourglass_empty;
    } else if (listing.status == 'active') {
      bgColor = Colors.green;
      label = lang == 'he' ? 'פעיל' : 'نشط';
      icon = Icons.check_circle;
    } else {
      bgColor = Colors.grey;
      label = listing.getStatusLabel();
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ListingModel listing, String lang) {
    if (listing.isExpired) {
      // Show republish button for expired listings
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _republishListing(listing),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.refresh, size: 20),
          label: Text(
            lang == 'he' ? 'פרסם מחדש' : 'إعادة نشر',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (listing.isRejected) {
      // Show edit button for rejected listings
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToEdit(listing),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.edit, size: 20),
          label: Text(
            lang == 'he' ? 'ערוך ושלח מחדש' : 'تعديل وإعادة الإرسال',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Show action buttons for active listings
    return Column(
      children: [
        // Rental toggle button for active listings
        if (listing.status == 'active' && !listing.isExpired)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _toggleRented(listing),
                style: OutlinedButton.styleFrom(
                  foregroundColor: listing.isRented
                      ? Colors.green
                      : Colors.orange,
                  side: BorderSide(
                    color: listing.isRented ? Colors.green : Colors.orange,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  listing.isRented ? Icons.check_circle : Icons.home_work,
                  size: 18,
                ),
                label: Text(
                  listing.isRented
                      ? (lang == 'he'
                            ? 'סמן כזמין'
                            : (lang == 'en' ? 'Mark Available' : 'تحديد كمتاح'))
                      : (lang == 'he'
                            ? 'סמן כמושכר'
                            : (lang == 'en' ? 'Mark Rented' : 'تحديد كمؤجر')),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        // View and edit buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewListing(listing),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.visibility, size: 18),
                label: Text(lang == 'he' ? 'צפה' : 'عرض'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToEdit(listing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: Text(lang == 'he' ? 'ערוך' : 'تعديل'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _viewListing(ListingModel listing) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListingDetailsScreen(listing: listing)),
    );
  }

  Future<void> _toggleRented(ListingModel listing) async {
    final lang = Localizations.localeOf(context).languageCode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.post(
        'listings/${listing.id}/toggle-rented',
        body: {'type': listing.listingType},
      );

      if (mounted) Navigator.pop(context);

      if (response.success) {
        if (mounted) {
          final isRented = response.data?['is_rented'] ?? false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRented
                    ? (lang == 'he'
                          ? 'המודעה סומנה כמושכרת'
                          : (lang == 'en'
                                ? 'Listing marked as rented'
                                : 'تم تحديد الإعلان كمؤجر'))
                    : (lang == 'he'
                          ? 'המודעה סומנה כזמינה'
                          : (lang == 'en'
                                ? 'Listing marked as available'
                                : 'تم تحديد الإعلان كمتاح')),
              ),
              backgroundColor: Colors.green,
            ),
          );
          final listingsProvider = Provider.of<ListingsProvider>(
            context,
            listen: false,
          );
          // Refresh my listings and home screen data
          listingsProvider.fetchMyListings();
          listingsProvider.fetchProperties(refresh: true);
          listingsProvider.fetchCars(refresh: true);
        }
      } else {
        if (mounted) {
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
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang == 'he' ? 'שגיאת רשת' : 'خطأ في الاتصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _republishListing(ListingModel listing) async {
    final lang = Localizations.localeOf(context).languageCode;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == 'he' ? 'פרסום מחדש' : 'إعادة النشر'),
        content: Text(
          lang == 'he'
              ? 'האם ברצונך לפרסם מחדש את המודעה? פעולה זו תשתמש בחבילה הפעילה שלך.'
              : 'هل تريد إعادة نشر هذا الإعلان؟ سيتم استخدام باقتك النشطة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang == 'he' ? 'ביטול' : 'إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(lang == 'he' ? 'פרסם מחדש' : 'إعادة نشر'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.post(
        'listings/${listing.id}/republish',
        body: {'type': listing.listingType},
      );

      if (mounted) Navigator.pop(context); // Close loading

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lang == 'he'
                    ? 'המודעה פורסמה מחדש בהצלחה'
                    : 'تم إعادة نشر الإعلان بنجاح',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh listings
          Provider.of<ListingsProvider>(
            context,
            listen: false,
          ).fetchMyListings();
        }
      } else {
        if (!mounted) return;
        // No subscription or limit reached → redirect to checkout
        final reason = response.data is Map ? response.data['reason'] : null;
        if (reason == 'no_subscription' || reason == 'limit_reached' || response.statusCode == 403) {
          final goToCheckout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(lang == 'he' ? 'נדרשת חבילה' : 'باقة مطلوبة'),
              content: Text(
                response.data is Map && response.data['message_ar'] != null
                    ? (lang == 'he'
                        ? (response.data['message_he'] ?? response.data['message_ar'])
                        : response.data['message_ar'])
                    : (lang == 'he'
                        ? 'אין לך חבילה פעילה. האם תרצה לרכוש חבילה?'
                        : 'ليس لديك باقة نشطة. هل تريد شراء باقة؟'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(lang == 'he' ? 'ביטול' : 'إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text(lang == 'he' ? 'רכוש חבילה' : 'شراء باقة'),
                ),
              ],
            ),
          );
          if (goToCheckout == true && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CheckoutScreen(
                  category: listing.isProperty ? 'properties' : 'cars',
                  propertyType: listing.isProperty ? listing.type : null,
                  carUsageType: listing.isCar ? listing.type : null,
                ),
              ),
            );
          }
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
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang == 'he' ? 'שגיאת רשת' : 'خطأ في الاتصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToEdit(ListingModel listing) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditListingScreen(listing: listing)),
    );

    if (result == true && mounted) {
      // Refresh listings after successful edit
      Provider.of<ListingsProvider>(context, listen: false).fetchMyListings();
    }
  }
}
