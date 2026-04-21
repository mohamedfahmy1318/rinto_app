import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../models/listing_model.dart';
import '../listing_details/listing_details_screen.dart';
import '../edit_listing/edit_listing_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('notifications');

      if (response.success && response.data != null) {
        _notifications = List<Map<String, dynamic>>.from(response.data);
        _unreadCount = _notifications.where((n) => n['is_read'] == 0).length;
      } else {
        _error = response.message;
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

  Future<void> _markAsRead(int notificationId) async {
    await ApiService.post('notifications/$notificationId/read');
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['is_read'] = 1;
        _unreadCount = _notifications.where((n) => n['is_read'] == 0).length;
      }
    });
  }

  Future<void> _markAllAsRead() async {
    await ApiService.post('notifications/all/read');
    setState(() {
      for (var n in _notifications) {
        n['is_read'] = 1;
      }
      _unreadCount = 0;
    });
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    // Mark as read
    if (notification['is_read'] == 0) {
      _markAsRead(notification['id']);
    }

    // Navigate based on notification type
    final type = notification['type'] as String?;
    final data = notification['data'];

    if (data != null) {
      Map<String, dynamic>? parsedData;
      if (data is String && data.isNotEmpty) {
        try {
          parsedData = _simpleJsonParse(data);
        } catch (_) {}
      } else if (data is Map) {
        parsedData = Map<String, dynamic>.from(data);
      }

      if (parsedData != null && parsedData['listing_id'] != null) {
        final listingId = parsedData['listing_id'];
        final listingType = parsedData['listing_type'] ?? 'property';

        // Fetch listing details from API
        final endpoint = listingType == 'car'
            ? 'cars/$listingId'
            : 'properties/$listingId';
        final response = await ApiService.get(endpoint);

        if (response.success && response.data != null && mounted) {
          final listing = ListingModel.fromJson(response.data);

          // If rejected, navigate to edit screen instead of details
          if (type == 'listing_rejected' || listing.isRejected) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditListingScreen(listing: listing),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListingDetailsScreen(listing: listing),
              ),
            );
          }
        }
      }
    }
  }

  Map<String, dynamic> _simpleJsonParse(String json) {
    // Simple JSON parser for basic cases
    final result = <String, dynamic>{};
    final content = json.replaceAll('{', '').replaceAll('}', '');
    final pairs = content.split(',');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0].replaceAll('"', '').trim();
        var value = parts[1].replaceAll('"', '').trim();
        // Try to parse as int
        final intVal = int.tryParse(value);
        result[key] = intVal ?? value;
      }
    }
    return result;
  }

  String _getLocalizedTitle(Map<String, dynamic> notification, String lang) {
    if (lang == 'en') {
      return notification['title_en'] ?? notification['title_ar'] ?? '';
    }
    if (lang == 'he') {
      return notification['title_he'] ?? notification['title_ar'] ?? '';
    }
    return notification['title_ar'] ?? '';
  }

  String _getLocalizedBody(Map<String, dynamic> notification, String lang) {
    if (lang == 'en') {
      return notification['body_en'] ?? notification['body_ar'] ?? '';
    }
    if (lang == 'he') {
      return notification['body_he'] ?? notification['body_ar'] ?? '';
    }
    return notification['body_ar'] ?? '';
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'listing_approved':
        return Icons.check_circle;
      case 'listing_rejected':
        return Icons.cancel;
      case 'new_listing':
        return Icons.home;
      case 'listing_favorited':
        return Icons.favorite;
      case 'subscription_approved':
        return Icons.card_membership;
      case 'subscription_expiring':
      case 'subscription_expired':
        return Icons.warning;
      case 'admin_message':
        return Icons.admin_panel_settings;
      case 'broadcast':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'listing_approved':
        return Colors.green;
      case 'listing_rejected':
        return Colors.red;
      case 'new_listing':
        return AppColors.primary;
      case 'listing_favorited':
        return Colors.pink;
      case 'subscription_approved':
        return Colors.blue;
      case 'subscription_expiring':
      case 'subscription_expired':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String? createdAt, String lang) {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (lang == 'en') {
        if (diff.inMinutes < 1) return 'now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m';
        if (diff.inHours < 24) return '${diff.inHours}h';
        if (diff.inDays < 7) return '${diff.inDays}d';
      } else if (lang == 'he') {
        if (diff.inMinutes < 1) return 'עכשיו';
        if (diff.inMinutes < 60) return '${diff.inMinutes} ד\'';
        if (diff.inHours < 24) return '${diff.inHours} ש\'';
        if (diff.inDays < 7) return '${diff.inDays} י\'';
      } else {
        if (diff.inMinutes < 1) return 'الآن';
        if (diff.inMinutes < 60) return '${diff.inMinutes} د';
        if (diff.inHours < 24) return '${diff.inHours} س';
        if (diff.inDays < 7) return '${diff.inDays} ي';
      }
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<AppProvider>(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'he' ? 'התראות' : 'الإشعارات'),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(
                lang == 'he' ? 'סמן הכל כנקרא' : 'قراءة الكل',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorView(lang)
            : _notifications.isEmpty
            ? _buildEmptyView(lang)
            : _buildNotificationsList(isDark, lang),
      ),
    );
  }

  Widget _buildErrorView(String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(lang == 'he' ? 'שגיאה בטעינה' : 'خطأ في التحميل'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: Text(lang == 'he' ? 'נסה שוב' : 'إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            lang == 'he' ? 'אין התראות' : 'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lang == 'he' ? 'ההתראות שלך יופיעו כאן' : 'ستظهر إشعاراتك هنا',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(bool isDark, String lang) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final isRead = notification['is_read'] == 1;
        final type = notification['type'] as String?;

        return ListTile(
          onTap: () => _handleNotificationTap(notification),
          tileColor: isRead
              ? null
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : AppColors.primary.withOpacity(0.05)),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getNotificationColor(type).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(type),
              color: _getNotificationColor(type),
              size: 22,
            ),
          ),
          title: Text(
            _getLocalizedTitle(notification, lang),
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                _getLocalizedBody(notification, lang),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(notification['created_at'], lang),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          trailing: !isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        );
      },
    );
  }
}
