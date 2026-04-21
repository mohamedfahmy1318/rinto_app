import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/apple_iap_service.dart';
import '../../services/google_iap_service.dart';
import '../auth/login_screen.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _propertyPageController;
  late PageController _carPageController;

  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  List<Map<String, dynamic>> _propertyPlans = [];
  List<Map<String, dynamic>> _carPlans = [];
  Map<String, dynamic>? _selectedPlan;
  int _currentPropertyIndex = 0;
  int _currentCarIndex = 0;

  Map<String, dynamic>? _activePropertySubscription;
  Map<String, dynamic>? _activeCarSubscription;

  String _paymentMethod = 'bank_transfer';
  List<String> _enabledMethods = [];
  Map<String, String> _bankDetails = {};
  final _senderNameController = TextEditingController();

  final AppleIAPService _appleIapService = AppleIAPService();
  final GoogleIAPService _googleIapService = GoogleIAPService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _propertyPageController = PageController(viewportFraction: 0.85);
    _carPageController = PageController(viewportFraction: 0.85);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentMethods();
      _loadData();
      _initializeIAP();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _propertyPageController.dispose();
    _carPageController.dispose();
    _senderNameController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    final response = await ApiService.get(
      'settings/payment-methods',
      params: {'platform': platform},
    );
    if (response.success && response.data != null) {
      setState(() {
        _enabledMethods = List<String>.from(
          response.data['enabled_methods'] ?? [],
        );
        if (response.data['bank_details'] != null) {
          _bankDetails = Map<String, String>.from(
            (response.data['bank_details'] as Map).map(
              (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
            ),
          );
        }
        if (_enabledMethods.isNotEmpty) {
          _paymentMethod = _enabledMethods.contains('bank_transfer')
              ? 'bank_transfer'
              : _enabledMethods.first;
        }
      });
    }
  }

  Future<void> _initializeIAP() async {
    if (Platform.isIOS) {
      await _appleIapService.initialize();
      _appleIapService.onPurchaseSuccess = (id) {
        if (mounted) {
          setState(() => _isProcessing = false);
          _showSuccessDialog().then((_) => _loadData());
        }
      };
      _appleIapService.onError = (msg) {
        if (mounted) {
          setState(() => _isProcessing = false);
          _showFailureDialog(msg);
        }
      };
      _appleIapService.onPurchaseCancelled = () {
        if (mounted) setState(() => _isProcessing = false);
      };
    } else if (Platform.isAndroid) {
      await _googleIapService.initialize();
      _googleIapService.onPurchaseSuccess = (id) {
        if (mounted) {
          setState(() => _isProcessing = false);
          _showSuccessDialog().then((_) => _loadData());
        }
      };
      _googleIapService.onError = (msg) {
        if (mounted) {
          setState(() => _isProcessing = false);
          _showFailureDialog(msg);
        }
      };
      _googleIapService.onPurchaseCancelled = () {
        if (mounted) setState(() => _isProcessing = false);
      };
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final plansResponse = await ApiService.get('plans');
      if (plansResponse.success && plansResponse.data != null) {
        final data = plansResponse.data;
        if (data is Map) {
          final propData = data['properties'];
          final carData = data['cars'];
          if (propData is Map) {
            _propertyPlans = [
              ...List<Map<String, dynamic>>.from(propData['specific'] ?? []),
              ...List<Map<String, dynamic>>.from(propData['general'] ?? []),
            ];
          } else if (propData is List) {
            _propertyPlans = List<Map<String, dynamic>>.from(propData);
          }
          if (carData is Map) {
            _carPlans = [
              ...List<Map<String, dynamic>>.from(carData['specific'] ?? []),
              ...List<Map<String, dynamic>>.from(carData['general'] ?? []),
            ];
          } else if (carData is List) {
            _carPlans = List<Map<String, dynamic>>.from(carData);
          }
        }
      } else {
        _error = plansResponse.message.isNotEmpty
            ? plansResponse.message
            : 'فشل تحميل الباقات';
      }
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isLoggedIn) {
        final propSub = await ApiService.get(
          'subscriptions/active',
          params: {'category': 'properties'},
        );
        if (propSub.success && propSub.data != null) {
          _activePropertySubscription = propSub.data;
        }
        final carSub = await ApiService.get(
          'subscriptions/active',
          params: {'category': 'cars'},
        );
        if (carSub.success && carSub.data != null) {
          _activeCarSubscription = carSub.data;
        }
      }
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handlePayment() async {
    if (_selectedPlan == null) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    if (_paymentMethod == 'apple_iap') {
      await _processAppleIAP();
    } else if (_paymentMethod == 'google_iap') {
      await _processGoogleIAP();
    } else if (_paymentMethod == 'test') {
      await _processTestPayment();
    } else {
      await _processBankTransfer();
    }
  }

  Future<void> _processTestPayment() async {
    setState(() => _isProcessing = true);
    try {
      final response = await ApiService.post(
        'subscriptions/purchase',
        body: {
          'plan_id': _selectedPlan!['id'],
          'payment_method': 'test',
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
      if (mounted) {
        if (response.success) {
          await _showSuccessDialog();
          _loadData();
        } else {
          await _showFailureDialog(response.message);
        }
      }
    } catch (e) {
      if (mounted) await _showFailureDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _processAppleIAP() async {
    final productId = _selectedPlan!['ios_product_id'] as String?;
    if (productId == null || productId.isEmpty) {
      _showFailureDialog('Product ID not configured');
      return;
    }
    setState(() => _isProcessing = true);
    if (_appleIapService.getProduct(productId) == null) {
      await _appleIapService.loadProducts([productId]);
    }
    final success = await _appleIapService.purchaseProduct(
      productId,
      _selectedPlan!['id'].toString(),
    );
    if (!success && mounted) setState(() => _isProcessing = false);
  }

  Future<void> _processGoogleIAP() async {
    final productId = _selectedPlan!['android_product_id'] as String?;
    if (productId == null || productId.isEmpty) {
      _showFailureDialog('Product ID not configured');
      return;
    }
    setState(() => _isProcessing = true);
    if (_googleIapService.getProduct(productId) == null) {
      await _googleIapService.loadProducts([productId]);
    }
    final success = await _googleIapService.purchaseProduct(
      productId,
      _selectedPlan!['id'].toString(),
    );
    if (!success && mounted) setState(() => _isProcessing = false);
  }

  Future<void> _processBankTransfer() async {
    if (_senderNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('please_enter_sender_name')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isProcessing = true);
    try {
      final response = await ApiService.post(
        'subscriptions/purchase',
        body: {
          'plan_id': _selectedPlan!['id'],
          'payment_method': 'bank_transfer',
          'platform': Platform.isIOS ? 'ios' : 'android',
          'status': 'pending_verification',
          'sender_name': _senderNameController.text.trim(),
        },
      );
      if (mounted) {
        if (response.success) {
          final status = response.data?['status'] ?? 'pending_verification';
          if (status == 'pending_verification') {
            await _showPendingDialog();
          } else {
            await _showSuccessDialog();
          }
          _loadData();
        } else {
          await _showFailureDialog(response.message);
        }
      }
    } catch (e) {
      if (mounted) await _showFailureDialog(context.tr('network_error'));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showPendingDialog() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.hourglass_empty, color: Colors.orange, size: 60),
      title: Text(
        context.tr('pending_verification'),
        textAlign: TextAlign.center,
      ),
      content: Text(
        context.tr('transfer_received'),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.tr('ok')),
        ),
      ],
    ),
  );
  Future<void> _showSuccessDialog() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
      title: Text(context.tr('purchase_success'), textAlign: TextAlign.center),
      content: Text(
        context.tr('package_activated'),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.tr('ok')),
        ),
      ],
    ),
  );
  Future<void> _showFailureDialog(String reason) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.error, color: Colors.red, size: 60),
      title: Text(context.tr('purchase_failed'), textAlign: TextAlign.center),
      content: Text(
        reason.isNotEmpty ? reason : context.tr('unknown_error'),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.tr('ok')),
        ),
      ],
    ),
  );

  Color _getBadgeColor(String? badge) {
    switch (badge) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }

  List<Color> _getBadgeGradient(String? badge) {
    switch (badge) {
      case 'gold':
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 'silver':
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)];
      case 'bronze':
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      default:
        return [AppColors.primary, AppColors.primary.withOpacity(0.7)];
    }
  }

  IconData _getBadgeIcon(String? badge) {
    switch (badge) {
      case 'gold':
        return Icons.workspace_premium;
      case 'silver':
        return Icons.military_tech;
      case 'bronze':
        return Icons.emoji_events;
      default:
        return Icons.local_offer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<AppProvider>(context).languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang == 'en'
              ? 'Packages & Pricing'
              : lang == 'he'
              ? 'חבילות ומחירים'
              : 'الباقات والأسعار',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: lang == 'en'
                  ? 'Properties'
                  : lang == 'he'
                  ? 'נכסים'
                  : 'عقارات',
            ),
            Tab(
              text: lang == 'en'
                  ? 'Cars'
                  : lang == 'he'
                  ? 'רכבים'
                  : 'سيارات',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView(lang)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPlansTab(
                  _propertyPlans,
                  _activePropertySubscription,
                  _propertyPageController,
                  _currentPropertyIndex,
                  (i) => setState(() => _currentPropertyIndex = i),
                  isDark,
                  lang,
                ),
                _buildPlansTab(
                  _carPlans,
                  _activeCarSubscription,
                  _carPageController,
                  _currentCarIndex,
                  (i) => setState(() => _currentCarIndex = i),
                  isDark,
                  lang,
                ),
              ],
            ),
    );
  }

  Widget _buildErrorView(String lang) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            lang == 'he' ? 'שגיאה בטעינה' : 'خطأ في التحميل',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(lang == 'he' ? 'נסה שוב' : 'إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );

  Widget _buildPlansTab(
    List<Map<String, dynamic>> plans,
    Map<String, dynamic>? activeSub,
    PageController pageCtrl,
    int currentIdx,
    Function(int) onChanged,
    bool isDark,
    String lang,
  ) {
    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              lang == 'he' ? 'אין חבילות זמינות' : 'لا توجد باقات متاحة',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (activeSub != null) _buildActiveSubBanner(activeSub, isDark, lang),
        const SizedBox(height: 16),
        _buildPlanTabs(plans, currentIdx, pageCtrl, isDark, lang),
        const SizedBox(height: 8),
        Expanded(
          child: PageView.builder(
            controller: pageCtrl,
            itemCount: plans.length,
            onPageChanged: onChanged,
            itemBuilder: (ctx, i) => _buildPlanCard(plans[i], isDark, lang),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                lang == 'he' ? 'החלק לראות עוד' : 'اسحب لرؤية المزيد',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        _buildCheckoutBar(
          plans.isNotEmpty ? plans[currentIdx] : null,
          isDark,
          lang,
        ),
      ],
    );
  }

  Widget _buildActiveSubBanner(
    Map<String, dynamic> sub,
    bool isDark,
    String lang,
  ) {
    final name = lang == 'he'
        ? (sub['plan_name_he'] ?? sub['plan_name_ar'])
        : (sub['plan_name_ar'] ?? sub['name_ar']);
    final used = sub['listings_used'] ?? 0;
    final limit = sub['listings_limit'] ?? 0;
    final isUnlimited = sub['is_unlimited'] == true || sub['is_unlimited'] == 1;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'he' ? 'מנוי פעיל' : 'اشتراك فعال',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isUnlimited ? '∞' : '$used / $limit',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTabs(
    List<Map<String, dynamic>> plans,
    int currentIdx,
    PageController pageCtrl,
    bool isDark,
    String lang,
  ) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: plans.length,
        itemBuilder: (ctx, i) {
          final plan = plans[i];
          final isSelected = currentIdx == i;
          final name = lang == 'he'
              ? (plan['name_he'] ?? plan['name_ar'])
              : plan['name_ar'];
          final badge = plan['badge'];
          return GestureDetector(
            onTap: () => pageCtrl.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: _getBadgeGradient(badge))
                    : null,
                color: isSelected
                    ? null
                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _getBadgeColor(badge).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badge != null) ...[
                    Icon(
                      _getBadgeIcon(badge),
                      size: 18,
                      color: isSelected ? Colors.white : _getBadgeColor(badge),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    name ?? '',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, bool isDark, String lang) {
    final name = lang == 'he'
        ? (plan['name_he'] ?? plan['name_ar'])
        : plan['name_ar'];
    final desc = lang == 'he'
        ? (plan['description_he'] ?? plan['description_ar'])
        : plan['description_ar'];
    final priceRaw = plan['price'];
    final double price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '0') ?? 0;
    final origRaw = plan['original_price'];
    final double? origPrice = origRaw != null
        ? (origRaw is num
              ? origRaw.toDouble()
              : double.tryParse(origRaw.toString()))
        : null;
    final listings = plan['listings_count'];
    final isUnlimited =
        plan['is_unlimited'] == true || plan['is_unlimited'] == 1;
    final days = plan['duration_days'];
    final badge = plan['badge'];
    final isFeatured = plan['is_featured'] == true || plan['is_featured'] == 1;
    final regionNotif =
        plan['allow_region_notifications'] == true ||
        plan['allow_region_notifications'] == 1;
    final cityNotif =
        plan['allow_city_notifications'] == true ||
        plan['allow_city_notifications'] == 1;
    final trusted =
        plan['is_trusted_advertiser'] == true ||
        plan['is_trusted_advertiser'] == 1;
    final discount = plan['discount_percent'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBadgeColor(badge).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBadgeColor(badge).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _getBadgeGradient(badge)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getBadgeIcon(badge),
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (desc != null && desc.isNotEmpty)
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (discount != null && discount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '-$discount%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (origPrice != null && origPrice > price) ...[
                  Text(
                    '₪${origPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  price > 0
                      ? '₪${price.toStringAsFixed(2)}'
                      : (lang == 'he' ? 'חינם' : 'مجاني'),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _getBadgeColor(badge),
                  ),
                ),
                if (days != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '/ $days ${lang == 'he' ? 'ימים' : 'يوم'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildFeature(
                    Icons.list_alt,
                    isUnlimited
                        ? (lang == 'he'
                              ? 'מודעות ללא הגבלה'
                              : 'إعلانات غير محدودة')
                        : '$listings ${lang == 'he' ? 'מודעות' : 'إعلان'}',
                    isDark,
                    true,
                  ),
                  _buildFeature(
                    Icons.timer,
                    '$days ${lang == 'he' ? 'ימים תוקף' : 'يوم صلاحية'}',
                    isDark,
                    true,
                  ),
                  _buildFeature(
                    Icons.star,
                    lang == 'he' ? 'מודעה מובלטת' : 'إعلان مميز',
                    isDark,
                    isFeatured,
                  ),
                  _buildFeature(
                    Icons.notifications_active,
                    lang == 'he' ? 'התראות אזוריות' : 'إشعارات المنطقة',
                    isDark,
                    regionNotif,
                  ),
                  _buildFeature(
                    Icons.location_city,
                    lang == 'he' ? 'התראות עירוניות' : 'إشعارات المدينة',
                    isDark,
                    cityNotif,
                  ),
                  _buildFeature(
                    Icons.verified_user,
                    lang == 'he' ? 'מפרסם מהימן' : 'معلن موثوق',
                    isDark,
                    trusted,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(
    IconData icon,
    String text,
    bool isDark,
    bool ok,
  ) => Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: ok ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: ok ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.2),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ok
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            ok ? icon : Icons.block,
            size: 16,
            color: ok ? Colors.green : Colors.red.shade300,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: ok ? FontWeight.w500 : FontWeight.normal,
              color: ok
                  ? (isDark ? Colors.white : Colors.black87)
                  : Colors.red.shade300,
              decoration: ok ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: ok ? Colors.green : Colors.red.shade300,
        ),
      ],
    ),
  );

  Widget _buildCheckoutBar(
    Map<String, dynamic>? plan,
    bool isDark,
    String lang,
  ) {
    if (plan == null) return const SizedBox.shrink();
    final priceRaw = plan['price'];
    final double price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '0') ?? 0;
    final name = lang == 'he'
        ? (plan['name_he'] ?? plan['name_ar'])
        : plan['name_ar'];
    final badge = plan['badge'];
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price > 0
                      ? '₪${price.toStringAsFixed(2)}'
                      : (lang == 'he' ? 'חינם' : 'مجاني'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _getBadgeColor(badge),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () {
                      _selectedPlan = plan;
                      _showPaymentSheet(isDark, lang);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getBadgeColor(badge),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      lang == 'he' ? 'הרשמה' : 'اشترك الآن',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(bool isDark, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                lang == 'he' ? 'אמצעי תשלום' : 'طريقة الدفع',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (_enabledMethods.contains('bank_transfer'))
                _buildPaymentTile(
                  'bank_transfer',
                  Icons.account_balance,
                  lang == 'he' ? 'העברה בנקאית' : 'حوالة بنكية',
                  lang == 'he' ? 'העבר לחשבון הבנק' : 'حوّل إلى حسابنا البنكي',
                  isDark,
                  () => setSheet(() => _paymentMethod = 'bank_transfer'),
                ),
              if (_paymentMethod == 'bank_transfer' &&
                  _enabledMethods.contains('bank_transfer'))
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${lang == 'he' ? 'שם הבנק' : 'البنك'}: ${_bankDetails['bank_name'] ?? ''}',
                      ),
                      Text(
                        '${lang == 'he' ? 'שם החשבון' : 'الحساب'}: ${_bankDetails['bank_account_name'] ?? ''}',
                      ),
                      Text(
                        '${lang == 'he' ? 'מספר חשבון' : 'رقم الحساب'}: ${_bankDetails['bank_account_number'] ?? ''}',
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _senderNameController,
                        decoration: InputDecoration(
                          labelText: lang == 'he'
                              ? 'שם השולח *'
                              : 'اسم المُحوِّل *',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_enabledMethods.contains('apple_iap') &&
                  Platform.isIOS &&
                  _selectedPlan?['ios_product_id'] != null &&
                  _appleIapService.isAvailable)
                _buildPaymentTile(
                  'apple_iap',
                  Icons.apple,
                  'Apple Pay',
                  lang == 'he' ? 'תשלום מהיר' : 'دفع سريع - تفعيل فوري',
                  isDark,
                  () => setSheet(() => _paymentMethod = 'apple_iap'),
                ),
              if (_enabledMethods.contains('google_iap') &&
                  Platform.isAndroid &&
                  _selectedPlan?['android_product_id'] != null &&
                  _googleIapService.isAvailable)
                _buildPaymentTile(
                  'google_iap',
                  Icons.play_arrow,
                  'Google Play',
                  lang == 'he' ? 'תשלום מהיר' : 'دفع سريع - تفعيل فوري',
                  isDark,
                  () => setSheet(() => _paymentMethod = 'google_iap'),
                ),
              if (_enabledMethods.contains('test'))
                _buildPaymentTile(
                  'test',
                  Icons.bug_report,
                  lang == 'he' ? 'תשלום לבדיקה' : 'دفع تجريبي',
                  lang == 'he' ? 'לבדיקה בלבד' : 'للاختبار فقط',
                  isDark,
                  () => setSheet(() => _paymentMethod = 'test'),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _handlePayment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        lang == 'he' ? 'אשר ושלם' : 'تأكيد والدفع',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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

  Widget _buildPaymentTile(
    String method,
    IconData icon,
    String title,
    String sub,
    bool isDark,
    VoidCallback onTap,
  ) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
