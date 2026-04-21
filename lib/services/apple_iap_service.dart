import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'api_service.dart';

/// Apple In-App Purchase Service
/// Handles iOS purchases and receipt verification
class AppleIAPService {
  static final AppleIAPService _instance = AppleIAPService._internal();
  factory AppleIAPService() => _instance;
  AppleIAPService._internal();

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
    if (!Platform.isIOS) {
      debugPrint('AppleIAPService: Not iOS platform, skipping initialization');
      return;
    }

    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      debugPrint('AppleIAPService: Store not available');
      return;
    }

    // Listen to purchase updates
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _onPurchaseDone,
      onError: _onPurchaseError,
    );

    // Enable pending purchases for StoreKit
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
    }

    debugPrint('AppleIAPService: Initialized successfully');
  }

  /// Load products from App Store
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
          'AppleIAPService: Products not found: ${response.notFoundIDs}',
        );
      }

      if (response.error != null) {
        debugPrint(
          'AppleIAPService: Error loading products: ${response.error}',
        );
        return [];
      }

      _products = response.productDetails;
      debugPrint('AppleIAPService: Loaded ${_products.length} products');
      return _products;
    } catch (e) {
      debugPrint('AppleIAPService: Exception loading products: $e');
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
          debugPrint('AppleIAPService: Purchase pending');
          onPurchasePending?.call();
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          debugPrint('AppleIAPService: Purchase completed, verifying...');
          _verifyAndCompletePurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          debugPrint(
            'AppleIAPService: Purchase error: ${purchaseDetails.error}',
          );
          _purchasePending = false;
          onError?.call(purchaseDetails.error?.message ?? 'Purchase failed');
          _completePurchase(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          debugPrint('AppleIAPService: Purchase cancelled');
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
      // Get receipt data
      String? receiptData;
      if (purchaseDetails.verificationData.source == 'app_store') {
        receiptData = purchaseDetails.verificationData.serverVerificationData;
      }

      if (receiptData == null || receiptData.isEmpty) {
        throw Exception('No receipt data available');
      }

      // Send to backend for verification
      final response = await ApiService.post(
        '/subscriptions/verify-apple-purchase',
        body: {
          'receipt_data': receiptData,
          'product_id': purchaseDetails.productID,
          'transaction_id': purchaseDetails.purchaseID,
          'plan_id': _pendingPlanId,
        },
      );

      if (response.success) {
        final subscriptionId =
            response.data?['subscription_id']?.toString() ?? '';
        onPurchaseSuccess?.call(subscriptionId);
      } else {
        throw Exception(
          response.message.isNotEmpty
              ? response.message
              : 'Verification failed',
        );
      }
    } catch (e) {
      debugPrint('AppleIAPService: Verification error: $e');
      onError?.call('Verification failed: $e');
    } finally {
      _purchasePending = false;
      _pendingPlanId = null;
      await _completePurchase(purchaseDetails);
    }
  }

  /// Complete purchase (consume consumable)
  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  void _onPurchaseDone() {
    _subscription?.cancel();
  }

  void _onPurchaseError(dynamic error) {
    debugPrint('AppleIAPService: Stream error: $error');
  }

  /// Restore purchases (for non-consumables)
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _inAppPurchase.restorePurchases();
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

/// Payment Queue Delegate for StoreKit
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
