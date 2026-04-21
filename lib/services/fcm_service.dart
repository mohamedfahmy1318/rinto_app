import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static String? _fcmToken;

  static String? get fcmToken => _fcmToken;

  /// Initialize FCM and request permissions
  static Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initLocalNotifications();

      // Request permission for iOS (Android doesn't need this but it's safe to call)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM: Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        await _getToken();

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('FCM: Token refreshed: $newToken');
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background/terminated message taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        // Check if app was opened from a terminated state via notification
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageOpenedApp(initialMessage);
        }
      }
    } catch (e) {
      debugPrint('FCM: Error initializing: $e');
    }
  }

  /// Initialize local notifications for foreground display
  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Create notification channel for Android
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'إشعارات مهمة',
      description: 'إشعارات التطبيق المهمة',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Get FCM token
  static Future<String?> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM: Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      debugPrint('FCM: Error getting token: $e');
      return null;
    }
  }

  /// Get current token (public method)
  static Future<String?> getToken() async {
    if (_fcmToken == null) {
      return await _getToken();
    }
    return _fcmToken;
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('FCM: Foreground message received');
    debugPrint('FCM: Title: ${message.notification?.title}');
    debugPrint('FCM: Body: ${message.notification?.body}');
    debugPrint('FCM: Data: ${message.data}');

    // Check if notifications are enabled
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled =
        prefs.getBool(StorageKeys.notificationsEnabled) ?? true;

    if (!notificationsEnabled) {
      debugPrint('FCM: Notifications disabled by user');
      return;
    }

    // Show local notification when app is in foreground
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'إشعارات مهمة',
            channelDescription: 'إشعارات التطبيق المهمة',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  /// Handle when user taps on notification
  static void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('FCM: Message opened app');
    debugPrint('FCM: Data: ${message.data}');

    // Navigate based on notification data if needed
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('FCM: Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('FCM: Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('FCM: Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('FCM: Error unsubscribing from topic: $e');
    }
  }
}
