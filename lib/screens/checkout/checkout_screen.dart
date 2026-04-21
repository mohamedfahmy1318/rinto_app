import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../services/apple_iap_service.dart';
import '../../services/google_iap_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String category; // 'properties' or 'cars'
  final String? propertyType; // apartment, villa_chalet, shop_office, etc.
  final String? carUsageType; // daily, wedding, tourism

  const CheckoutScreen({
    super.key,
    required this.category,
    this.propertyType,
    this.carUsageType,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isProcessing = false;
  List<Map<String, dynamic>> _plans = [];
  Map<String, dynamic>? _selectedPlan;
  String? _error;
  String _paymentMethod = 'bank_transfer';

  // IAP Services
  final AppleIAPService _appleIapService = AppleIAPService();
  final GoogleIAPService _googleIapService = GoogleIAPService();
  final _senderNameController = TextEditingController();
  final _transferRefController = TextEditingController();
  late PageController _pageController;
  int _currentPlanIndex = 0;

  // Enabled payment methods from server
  List<String> _enabledMethods = [];
  Map<String, String> _bankDetails = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _loadPaymentMethods();
    _loadPlans();
    _initializeIAP();
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
        // Set default payment method
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
      _setupAppleCallbacks();
    } else if (Platform.isAndroid) {
      await _googleIapService.initialize();
      _setupGoogleCallbacks();
    }
  }

  void _setupAppleCallbacks() {
    _appleIapService.onPurchaseSuccess = (subscriptionId) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showSuccessDialog().then((_) {
          if (mounted) Navigator.pop(context, true);
        });
      }
    };
    _appleIapService.onError = (message) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showFailureDialog(message);
      }
    };
    _appleIapService.onPurchaseCancelled = () {
      if (mounted) setState(() => _isProcessing = false);
    };
  }

  void _setupGoogleCallbacks() {
    _googleIapService.onPurchaseSuccess = (subscriptionId) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showSuccessDialog().then((_) {
          if (mounted) Navigator.pop(context, true);
        });
      }
    };
    _googleIapService.onError = (message) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showFailureDialog(message);
      }
    };
    _googleIapService.onPurchaseCancelled = () {
      if (mounted) setState(() => _isProcessing = false);
    };
  }

  @override
  void dispose() {
    _pageController.dispose();
    _senderNameController.dispose();
    _transferRefController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Build query params with filters
      final params = <String, String>{'category': widget.category};

      if (widget.propertyType != null) {
        params['property_type'] = widget.propertyType!;
      }
      if (widget.carUsageType != null) {
        params['car_usage_type'] = widget.carUsageType!;
      }

      final response = await ApiService.get('plans', params: params);

      if (response.success && response.data != null) {
        final data = response.data;
        if (data is List) {
          _plans = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          // API returns grouped data: {properties: {specific: [...], general: [...]}, cars: {...}}
          // Or with category filter: {specific: [...], general: [...]}
          final categoryData = data[widget.category] ?? data;
          if (categoryData is Map) {
            // Combine specific and general plans
            final specific = List<Map<String, dynamic>>.from(
              categoryData['specific'] ?? [],
            );
            final general = List<Map<String, dynamic>>.from(
              categoryData['general'] ?? [],
            );
            _plans = [...specific, ...general];
          } else if (categoryData is List) {
            _plans = List<Map<String, dynamic>>.from(categoryData);
          }
        }
        // Auto-select first plan
        if (_plans.isNotEmpty) {
          _selectedPlan = _plans[0];
          _currentPlanIndex = 0;
        }
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'Failed to load packages';
      }
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handle payment based on selected method
  Future<void> _handlePayment() async {
    if (_selectedPlan == null) return;

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

  /// Process test payment (instant activation)
  Future<void> _processTestPayment() async {
    setState(() => _isProcessing = true);

    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final response = await ApiService.post(
        'subscriptions/purchase',
        body: {
          'plan_id': _selectedPlan!['id'],
          'payment_method': 'test',
          'platform': platform,
        },
      );

      if (mounted) {
        if (response.success) {
          await _showSuccessDialog();
          if (mounted) Navigator.pop(context, true);
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

  /// Process Apple In-App Purchase
  Future<void> _processAppleIAP() async {
    final productId = _selectedPlan!['ios_product_id'] as String?;
    if (productId == null || productId.isEmpty) {
      _showFailureDialog('Product ID not configured');
      return;
    }

    setState(() => _isProcessing = true);

    // Load product if not loaded
    if (_appleIapService.getProduct(productId) == null) {
      await _appleIapService.loadProducts([productId]);
    }

    // Start purchase
    final success = await _appleIapService.purchaseProduct(
      productId,
      _selectedPlan!['id'].toString(),
    );

    if (!success && mounted) {
      setState(() => _isProcessing = false);
    }
  }

  /// Process Google Play In-App Purchase
  Future<void> _processGoogleIAP() async {
    final productId = _selectedPlan!['android_product_id'] as String?;
    if (productId == null || productId.isEmpty) {
      _showFailureDialog('Product ID not configured');
      return;
    }

    setState(() => _isProcessing = true);

    // Load product if not loaded
    if (_googleIapService.getProduct(productId) == null) {
      await _googleIapService.loadProducts([productId]);
    }

    // Start purchase
    final success = await _googleIapService.purchaseProduct(
      productId,
      _selectedPlan!['id'].toString(),
    );

    if (!success && mounted) {
      setState(() => _isProcessing = false);
    }
  }

  /// Process bank transfer (requires admin approval)
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
      final platform = Platform.isIOS ? 'ios' : 'android';

      final body = {
        'plan_id': _selectedPlan!['id'],
        'payment_method': 'bank_transfer',
        'platform': platform,
        'status': 'pending_verification',
        'sender_name': _senderNameController.text.trim(),
        'transfer_reference': _transferRefController.text.trim(),
        'transfer_date': DateTime.now().toIso8601String().split('T')[0],
      };

      final response = await ApiService.post(
        'subscriptions/purchase',
        body: body,
      );

      if (mounted) {
        if (response.success) {
          // Check status from response - all real payments need admin approval
          final status = response.data?['status'] ?? 'pending_verification';
          if (status == 'pending_verification') {
            // Show pending verification dialog
            await _showPendingDialog();
          } else {
            // Show success dialog (only for test payments)
            await _showSuccessDialog();
          }
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          // Show failure dialog
          await _showFailureDialog(response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        await _showFailureDialog(context.tr('network_error'));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _showPendingDialog() async {
    return showDialog(
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
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: Text(
          context.tr('purchase_success'),
          textAlign: TextAlign.center,
        ),
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
  }

  Widget _buildPaymentMethodTile(
    String method,
    IconData icon,
    String title,
    String subtitle,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _paymentMethod = method),
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
                    subtitle,
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

  Future<void> _showFailureDialog(String reason) async {
    return showDialog(
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<AppProvider>(context).languageCode;
    final isProperty = widget.category == 'properties';

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('choose_package'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView(lang)
          : _plans.isEmpty
          ? _buildEmptyView(lang)
          : _buildContent(isDark, lang, isProperty),
      bottomNavigationBar: _selectedPlan != null && !_isLoading
          ? _buildCheckoutBar(isDark, lang)
          : null,
    );
  }

  Widget _buildErrorView(String lang) {
    return Center(
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
              onPressed: _loadPlans,
              icon: const Icon(Icons.refresh),
              label: Text(lang == 'he' ? 'נסה שוב' : 'إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(String lang) {
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

  Widget _buildContent(bool isDark, String lang, bool isProperty) {
    return Column(
      children: [
        // Tab indicators
        const SizedBox(height: 16),
        _buildPlanTabs(isDark, lang),
        const SizedBox(height: 8),

        // PageView for plans
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _plans.length,
            onPageChanged: (index) {
              setState(() {
                _currentPlanIndex = index;
                _selectedPlan = _plans[index];
              });
            },
            itemBuilder: (context, index) {
              return _buildPlanDetailCard(_plans[index], isDark, lang, index);
            },
          ),
        ),

        // Swipe hint
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
      ],
    );
  }

  Widget _buildPlanTabs(bool isDark, String lang) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          final plan = _plans[index];
          final isSelected = _currentPlanIndex == index;
          final name = lang == 'he'
              ? (plan['name_he'] ?? plan['name_ar'])
              : plan['name_ar'];
          final badge = plan['badge'];

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: _getBadgeGradient(badge),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
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

  Widget _buildPlanDetailCard(
    Map<String, dynamic> plan,
    bool isDark,
    String lang,
    int index,
  ) {
    final name = lang == 'he'
        ? (plan['name_he'] ?? plan['name_ar'])
        : plan['name_ar'];
    final description = lang == 'he'
        ? (plan['description_he'] ?? plan['description_ar'])
        : plan['description_ar'];
    final priceRaw = plan['price'];
    final double price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '0') ?? 0;
    final originalPriceRaw = plan['original_price'];
    final double? originalPrice = originalPriceRaw != null
        ? (originalPriceRaw is num
              ? originalPriceRaw.toDouble()
              : double.tryParse(originalPriceRaw.toString()))
        : null;
    final listingsCount = plan['listings_count'];
    final isUnlimited =
        plan['is_unlimited'] == true || plan['is_unlimited'] == 1;
    final durationDays = plan['duration_days'];
    final badge = plan['badge'];
    final isFeatured = plan['is_featured'] == true || plan['is_featured'] == 1;
    final allowRegionNotifications =
        plan['allow_region_notifications'] == true ||
        plan['allow_region_notifications'] == 1;
    final allowCityNotifications =
        plan['allow_city_notifications'] == true ||
        plan['allow_city_notifications'] == 1;
    final isTrustedAdvertiser =
        plan['is_trusted_advertiser'] == true ||
        plan['is_trusted_advertiser'] == 1;
    final discountPercent = plan['discount_percent'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBadgeColor(badge).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBadgeColor(badge).withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with badge - compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getBadgeGradient(badge),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                // Badge icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getBadgeIcon(badge),
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                // Plan name & description
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
                      if (description != null && description.isNotEmpty)
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Discount badge
                if (discountPercent != null && discountPercent > 0)
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
                      '-$discountPercent%',
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

          // Price section - compact
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (originalPrice != null && originalPrice > price) ...[
                  Text(
                    '₪${originalPrice.toStringAsFixed(2)}',
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
                if (durationDays != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '/ $durationDays ${lang == 'he' ? 'ימים' : 'يوم'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),

          // Features list - compact
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildFeatureRow(
                    Icons.list_alt,
                    isUnlimited
                        ? (lang == 'he'
                              ? 'מודעות ללא הגבלה'
                              : 'إعلانات غير محدودة')
                        : '$listingsCount ${lang == 'he' ? 'מודעות' : 'إعلان'}',
                    isDark,
                    true,
                  ),
                  _buildFeatureRow(
                    Icons.timer,
                    '$durationDays ${lang == 'he' ? 'ימים תוקף' : 'يوم صلاحية'}',
                    isDark,
                    true,
                  ),
                  _buildFeatureRow(
                    Icons.star,
                    lang == 'he' ? 'מודעה מובלטת' : 'إعلان مميز',
                    isDark,
                    isFeatured,
                  ),
                  _buildFeatureRow(
                    Icons.notifications_active,
                    lang == 'he' ? 'התראות אזוריות' : 'إشعارات المنطقة',
                    isDark,
                    allowRegionNotifications,
                  ),
                  _buildFeatureRow(
                    Icons.location_city,
                    lang == 'he' ? 'התראות עירוניות' : 'إشعارات المدينة',
                    isDark,
                    allowCityNotifications,
                  ),
                  _buildFeatureRow(
                    Icons.verified_user,
                    lang == 'he' ? 'מפרסם מהימן' : 'معلن موثوق',
                    isDark,
                    isTrustedAdvertiser,
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

  Widget _buildFeatureRow(
    IconData icon,
    String text,
    bool isDark,
    bool isIncluded,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isIncluded
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isIncluded
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isIncluded
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncluded ? icon : Icons.block,
              size: 16,
              color: isIncluded ? Colors.green : Colors.red.shade300,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isIncluded ? FontWeight.w500 : FontWeight.normal,
                color: isIncluded
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.red.shade300,
                decoration: isIncluded ? null : TextDecoration.lineThrough,
                decorationColor: Colors.red.shade300,
              ),
            ),
          ),
          Icon(
            isIncluded ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: isIncluded ? Colors.green : Colors.red.shade300,
          ),
        ],
      ),
    );
  }

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

  Widget _buildCheckoutBar(bool isDark, String lang) {
    final priceRaw = _selectedPlan!['price'];
    final double price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '0') ?? 0;
    final planName = lang == 'he'
        ? (_selectedPlan!['name_he'] ?? _selectedPlan!['name_ar'])
        : _selectedPlan!['name_ar'];
    final badge = _selectedPlan!['badge'];

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
          // Plan info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planName ?? '',
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
          // Subscribe button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () => _showPaymentSheet(isDark, lang),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  lang == 'he' ? 'אמצעי תשלום' : 'طريقة الدفع',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Bank Transfer Option
                if (_enabledMethods.contains('bank_transfer'))
                  _buildPaymentMethodTile(
                    'bank_transfer',
                    Icons.account_balance,
                    lang == 'he' ? 'העברה בנקאית' : 'حوالة بنكية',
                    lang == 'he'
                        ? 'העבר לחשבון הבנק שלנו'
                        : 'حوّل إلى حسابنا البنكي',
                    isDark,
                    onTap: () =>
                        setSheetState(() => _paymentMethod = 'bank_transfer'),
                  ),

                // Show bank details if selected
                if (_paymentMethod == 'bank_transfer' &&
                    _enabledMethods.contains('bank_transfer')) ...[
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
                ],

                // Apple Pay Option (iOS only with valid product ID and enabled)
                if (_enabledMethods.contains('apple_iap') &&
                    Platform.isIOS &&
                    _selectedPlan?['ios_product_id'] != null &&
                    _appleIapService.isAvailable)
                  _buildPaymentMethodTile(
                    'apple_iap',
                    Icons.apple,
                    'Apple Pay',
                    lang == 'he'
                        ? 'תשלום מהיר ומאובטח'
                        : 'دفع سريع وآمن - تفعيل فوري',
                    isDark,
                    onTap: () =>
                        setSheetState(() => _paymentMethod = 'apple_iap'),
                  ),

                // Google Pay Option (Android only with valid product ID and enabled)
                if (_enabledMethods.contains('google_iap') &&
                    Platform.isAndroid &&
                    _selectedPlan?['android_product_id'] != null &&
                    _googleIapService.isAvailable)
                  _buildPaymentMethodTile(
                    'google_iap',
                    Icons.play_arrow,
                    'Google Play',
                    lang == 'he'
                        ? 'תשלום מהיר ומאובטח'
                        : 'دفع سريع وآمن - تفعيل فوري',
                    isDark,
                    onTap: () =>
                        setSheetState(() => _paymentMethod = 'google_iap'),
                  ),

                // Test Payment (only if enabled)
                if (_enabledMethods.contains('test'))
                  _buildPaymentMethodTile(
                    'test',
                    Icons.bug_report,
                    lang == 'he' ? 'תשלום לבדיקה' : 'دفع تجريبي',
                    lang == 'he' ? 'לבדיקה בלבד' : 'للاختبار فقط - تفعيل فوري',
                    isDark,
                    onTap: () => setSheetState(() => _paymentMethod = 'test'),
                  ),

                const SizedBox(height: 20),

                // Pay button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
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

                // Test mode notice
                const SizedBox(height: 8),
                Text(
                  lang == 'he'
                      ? '🧪 מצב בדיקה - התשלום לא אמיתי'
                      : '🧪 وضع تجريبي - الدفع غير حقيقي',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
