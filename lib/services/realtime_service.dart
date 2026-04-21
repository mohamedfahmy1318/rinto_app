import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Real-time Polling Service - بديل WebSocket
/// يجلب الرسائل الجديدة كل 2 ثانية
class RealtimeService {
  static RealtimeService? _instance;
  static RealtimeService get instance => _instance ??= RealtimeService._();

  RealtimeService._();

  Timer? _pollingTimer;
  int _lastId = 0;
  bool _isPolling = false;

  // Callbacks للأحداث المختلفة
  final List<Function(Map<String, dynamic>)> _onNewChatMessage = [];
  final List<Function(Map<String, dynamic>)> _onTyping = [];
  final List<Function(Map<String, dynamic>)> _onNewListing = [];
  final List<VoidCallback> _onAnyMessage = [];

  /// بدء الـ polling
  void startPolling({int intervalMs = 2000}) {
    if (_isPolling) return;
    _isPolling = true;

    _pollingTimer = Timer.periodic(
      Duration(milliseconds: intervalMs),
      (_) => _poll(),
    );

    // Poll فوراً
    _poll();

    debugPrint('🔄 Realtime polling started (every ${intervalMs}ms)');
  }

  /// إيقاف الـ polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    debugPrint('⏹️ Realtime polling stopped');
  }

  /// تسجيل callback لرسائل الشات الجديدة
  void onNewChatMessage(Function(Map<String, dynamic>) callback) {
    _onNewChatMessage.add(callback);
  }

  /// تسجيل callback للكتابة
  void onTyping(Function(Map<String, dynamic>) callback) {
    _onTyping.add(callback);
  }

  /// تسجيل callback للإعلانات الجديدة
  void onNewListing(Function(Map<String, dynamic>) callback) {
    _onNewListing.add(callback);
  }

  /// تسجيل callback لأي رسالة
  void onAnyMessage(VoidCallback callback) {
    _onAnyMessage.add(callback);
  }

  /// إزالة كل الـ callbacks
  void clearCallbacks() {
    _onNewChatMessage.clear();
    _onTyping.clear();
    _onNewListing.clear();
    _onAnyMessage.clear();
  }

  /// جلب الرسائل الجديدة
  Future<void> _poll() async {
    try {
      final response = await ApiService.get(
        'realtime.php?action=poll&last_id=$_lastId',
      );

      if (response.success && response.data != null) {
        final messages = response.data['messages'] as List? ?? [];
        _lastId = response.data['last_id'] ?? _lastId;

        for (var msg in messages) {
          _handleMessage(msg);
        }

        if (messages.isNotEmpty) {
          for (var callback in _onAnyMessage) {
            callback();
          }
        }
      }
    } catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  /// معالجة رسالة واردة
  void _handleMessage(Map<String, dynamic> msg) {
    final type = msg['message_type'] as String?;
    final data = msg['message_data'] as Map<String, dynamic>? ?? {};

    debugPrint('📩 Realtime message: $type');

    switch (type) {
      case 'new_chat_message':
        for (var callback in _onNewChatMessage) {
          callback(data);
        }
        break;

      case 'typing':
        for (var callback in _onTyping) {
          callback(data);
        }
        break;

      case 'new_listing_nearby':
        for (var callback in _onNewListing) {
          callback(data);
        }
        break;
    }
  }

  /// إرسال حدث "يكتب..."
  Future<void> sendTyping(int conversationId) async {
    // يمكن إضافة هذا لاحقاً
  }

  /// إعادة تعيين الـ lastId
  void reset() {
    _lastId = 0;
  }
}
