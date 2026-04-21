import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'api_service.dart';

/// Google Play In-App Purchase Service
/// Handles Android purchases and receipt verification
class GoogleIAPService {
  static final GoogleIAPService _instance = GoogleIAPService._internal();
  factory GoogleIAPService() => _instance;
  GoogleIAPService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _pendingPlanId;

  // Callbacks
  Function(String message)? onError;
  Function(String subscriptionId)? onPurchaseSuccess;
  Function()? onPurchasePending;
  Function()? onPurchaseCancelled;

  /// Initialize the IAP service
  Future<void> initialize() async {
    if (!Platform.isAndroid) {
      debugPrint(
        'GoogleIAPService: Not Android platform, skipping initialization',
      );
      return;
    }

    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      debugPrint('GoogleIAPService: Store not available');
      return;
    }

    // Listen to purchase updates
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _onPurchaseDone,
      onError: _onPurchaseError,
    );

    debugPrint('GoogleIAPService: Initialized successfully');
  }

  /// Load products from Google Play
  Future<List<ProductDetails>> loadProducts(List<String> productIds) async {
    if (!_isAvailable || productIds.isEmpty) {
      return [];
    }

    final Set<String> ids = productIds.where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty) {
      return [];
    }

    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(ids);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
          'GoogleIAPService: Products not found: ${response.notFoundIDs}',
        );
      }

      if (response.error != null) {
        debugPrint(
          'GoogleIAPService: Error loading products: ${response.error}',
        );
        return [];
      }

      _products = response.productDetails;
      debugPrint('GoogleIAPService: Loaded ${_products.length} products');
      return _products;
    } catch (e) {
      debugPrint('GoogleIAPService: Exception loading products: $e');
      return [];
    }
  }

  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Purchase a product
  Future<bool> purchaseProduct(String productId, String planId) async {
    if (!_isAvailable) {
      onError?.call('Store not available');
      return false;
    }

    if (_purchasePending) {
      onError?.call('A purchase is already in progress');
      return false;
    }

    final product = getProduct(productId);
    if (product == null) {
      onError?.call('Product not found: $productId');
      return false;
    }

    _purchasePending = true;
    _pendingPlanId = planId;

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: false, // We'll consume after verification
      );

      if (!success) {
        _purchasePending = false;
        _pendingPlanId = null;
      }

      return success;
    } catch (e) {
      _purchasePending = false;
      _pendingPlanId = null;
      onError?.call('Purchase failed: $e');
      return false;
    }
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          debugPrint('GoogleIAPService: Purchase pending');
          onPurchasePending?.call();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          debugPrint('GoogleIAPService: Purchase completed, verifying...');
          _verifyAndCompletePurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          debugPrint(
            'GoogleIAPService: Purchase error: ${purchaseDetails.error}',
          );
          _purchasePending = false;
          onError?.call(purchaseDetails.error?.message ?? 'Purchase failed');
          _completePurchase(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          debugPrint('GoogleIAPService: Purchase cancelled');
          _purchasePending = false;
          _pendingPlanId = null;
          onPurchaseCancelled?.call();
          break;
      }
    }
  }

  /// Verify purchase with backend and complete
  Future<void> _verifyAndCompletePurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    try {
      // Get purchase token for Google Play
      String? purchaseToken;
      if (purchaseDetails is GooglePlayPurchaseDetails) {
        purchaseToken = purchaseDetails.billingClientPurchase.purchaseToken;
      }

      if (purchaseToken == null || purchaseToken.isEmpty) {
        throw Exception('No purchase token available');
      }

      // Send to backend for verification
      final response = await ApiService.post(
        '/subscriptions/verify-google-purchase',
        body: {
          'purchase_token': purchaseToken,
          'product_id': purchaseDetails.productID,
          'transaction_id': purchaseDetails.purchaseID,
          'plan_id': _pendingPlanId,
        },
      );

      if (response.success) {
        final subscriptionId =
            response.data?['subscription_id']?.toString() ?? '';

        // Consume the purchase after successful verification
        if (Platform.isAndroid) {
          final androidAddition = _inAppPurchase
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          await androidAddition.consumePurchase(
            purchaseDetails as GooglePlayPurchaseDetails,
          );
        }

        onPurchaseSuccess?.call(subscriptionId);
      } else {
        throw Exception(
          response.message.isNotEmpty
              ? response.message
              : 'Verification failed',
        );
      }
    } catch (e) {
      debugPrint('GoogleIAPService: Verification error: $e');
      onError?.call('Verification failed: $e');
    } finally {
      _purchasePending = false;
      _pendingPlanId = null;
      await _completePurchase(purchaseDetails);
    }
  }

  /// Complete purchase
  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  void _onPurchaseDone() {
    _subscription?.cancel();
  }

  void _onPurchaseError(dynamic error) {
    debugPrint('GoogleIAPService: Stream error: $error');
  }

  /// Check if store is available
  bool get isAvailable => _isAvailable;

  /// Check if purchase is in progress
  bool get isPurchasePending => _purchasePending;

  /// Get loaded products
  List<ProductDetails> get products => _products;

  /// Dispose
  void dispose() {
    _subscription?.cancel();
  }
}
