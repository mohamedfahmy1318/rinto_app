import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../widgets/grid_listing_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/cta_banner.dart';
import '../widgets/admin_banner_widget.dart';
import '../add_listing/add_listing_screen.dart';
import '../../presentation/auth/auth_routes.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _propertiesScrollController = ScrollController();
  final ScrollController _carsScrollController = ScrollController();
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _loadUnreadNotificationsCount();
    });

    _propertiesScrollController.addListener(_onPropertiesScroll);
    _carsScrollController.addListener(_onCarsScroll);
  }

  void _loadInitialData() {
    final provider = Provider.of<ListingsProvider>(context, listen: false);
    provider.fetchProperties(refresh: true);
    provider.fetchCars(refresh: true);
  }

  Future<void> _loadUnreadNotificationsCount() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) return;

    try {
      final response = await ApiService.get('notifications/unread-count');
      if (response.success && response.data != null && mounted) {
        setState(() {
          _unreadNotificationsCount = response.data['unread_count'] ?? 0;
        });
      }
    } catch (_) {}
  }

  void _onTabChanged() {
    setState(() {});
  }

  void _onPropertiesScroll() {
    if (_propertiesScrollController.position.pixels >=
        _propertiesScrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<ListingsProvider>(context, listen: false);
      if (!provider.isLoadingProperties && provider.hasMoreProperties) {
        provider.fetchProperties();
      }
    }
  }

  void _onCarsScroll() {
    if (_carsScrollController.position.pixels >=
        _carsScrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<ListingsProvider>(context, listen: false);
      if (!provider.isLoadingCars && provider.hasMoreCars) {
        provider.fetchCars();
      }
    }
  }

  void _showAddListingDialog(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!auth.isLoggedIn) {
      Navigator.push(context, loginRoute());
      return;
    }

    // All registered users can add listings (subscription required)
    const canAddProperty = true;
    const canAddCar = true;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('listing_type'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (canAddProperty)
              ListTile(
                leading: const Icon(Icons.apartment, color: Colors.blue),
                title: Text(context.tr('properties')),
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
            if (canAddCar)
              ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.orange),
                title: Text(context.tr('cars')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddListingScreen(listingType: 'car'),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _propertiesScrollController.dispose();
    _carsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and toggle
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // App Logo - different for light/dark mode
                      SizedBox(
                        width: 160,
                        height: 40,
                        child: Image.asset(
                          isDark
                              ? 'assets/images/logo_dark.png'
                              : 'assets/images/logo_light.png',
                          height: 40,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      const Spacer(),
                      // Notifications Bell
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          if (!auth.isLoggedIn) return const SizedBox.shrink();
                          return Stack(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const NotificationsScreen(),
                                    ),
                                  ).then(
                                    (_) => _loadUnreadNotificationsCount(),
                                  );
                                },
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                  size: 26,
                                ),
                              ),
                              if (_unreadNotificationsCount > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      _unreadNotificationsCount > 99
                                          ? '99+'
                                          : '$_unreadNotificationsCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      // Toggle Button
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _tabController.animateTo(1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _tabController.index == 1
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  context.tr('cars'),
                                  style: TextStyle(
                                    color: _tabController.index == 1
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white70
                                              : Colors.black54),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _tabController.animateTo(0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _tabController.index == 0
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  context.tr('properties'),
                                  style: TextStyle(
                                    color: _tabController.index == 0
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white70
                                              : Colors.black54),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SearchBarWidget(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildPropertiesTab(), _buildCarsTab()],
              ),
            ),
            // Bottom Add Listing Banner
            AddListingBanner(onTap: () => _showAddListingDialog(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesTab() {
    return Consumer<ListingsProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: () => provider.fetchProperties(refresh: true),
          child: CustomScrollView(
            controller: _propertiesScrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Category chips
                      CategoryChips(
                        type: 'property',
                        onFilterChanged: (filter) {
                          final p = Provider.of<ListingsProvider>(
                            context,
                            listen: false,
                          );
                          p.setPropertyTypeFilter(filter);
                          p.fetchProperties(refresh: true);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Admin Promotional Banners
                      const AdminBannerWidget(bannerType: 'property'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Listings Grid
              if (provider.properties.isEmpty && !provider.isLoadingProperties)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildEmptyState(context.tr('no_results')),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getGridColumns(context),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return GridListingCard(
                        listing: provider.properties[index],
                      );
                    }, childCount: provider.properties.length),
                  ),
                ),
              if (provider.isLoadingProperties)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          ),
        );
      },
    );
  }

  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }

  Widget _buildCarsTab() {
    return Consumer<ListingsProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: () => provider.fetchCars(refresh: true),
          child: CustomScrollView(
            controller: _carsScrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Category chips
                      CategoryChips(
                        type: 'car',
                        onFilterChanged: (filter) {
                          final p = Provider.of<ListingsProvider>(
                            context,
                            listen: false,
                          );
                          p.setCarUsageTypeFilter(filter);
                          p.fetchCars(refresh: true);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Admin Promotional Banners
                      const AdminBannerWidget(bannerType: 'car'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              // Listings Grid
              if (provider.cars.isEmpty && !provider.isLoadingCars)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: _buildEmptyState(context.tr('no_results')),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getGridColumns(context),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return GridListingCard(listing: provider.cars[index]);
                    }, childCount: provider.cars.length),
                  ),
                ),
              if (provider.isLoadingCars)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.darkTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
