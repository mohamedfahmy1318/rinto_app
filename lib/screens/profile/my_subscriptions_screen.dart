import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/api_service.dart';

class MySubscriptionsScreen extends StatefulWidget {
  const MySubscriptionsScreen({super.key});

  @override
  State<MySubscriptionsScreen> createState() => _MySubscriptionsScreenState();
}

class _MySubscriptionsScreenState extends State<MySubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allSubscriptions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get(
        'subscriptions/me',
        params: {'status': 'all'},
      );

      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _allSubscriptions = List<Map<String, dynamic>>.from(response.data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = response.message;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getSubscriptionsByStatus(String status) {
    if (status == 'active') {
      return _allSubscriptions
          .where((s) => s['status'] == 'active' && !(s['is_expired'] ?? false))
          .toList();
    } else if (status == 'pending') {
      return _allSubscriptions
          .where((s) => s['status'] == 'pending_verification')
          .toList();
    } else {
      // expired or cancelled or rejected
      return _allSubscriptions
          .where(
            (s) =>
                s['status'] == 'expired' ||
                s['status'] == 'cancelled' ||
                s['status'] == 'rejected' ||
                (s['is_expired'] ?? false),
          )
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('my_subscriptions')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          tabs: [
            Tab(
              icon: const Icon(Icons.check_circle, size: 20),
              text: context.tr('active_tab'),
            ),
            Tab(
              icon: const Icon(Icons.hourglass_top, size: 20),
              text: context.tr('pending_tab'),
            ),
            Tab(
              icon: const Icon(Icons.history, size: 20),
              text: context.tr('history_tab'),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSubscriptions,
                    child: Text(context.tr('retry')),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadSubscriptions,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSubscriptionsList(context, 'active', isDark),
                  _buildSubscriptionsList(context, 'pending', isDark),
                  _buildSubscriptionsList(context, 'expired', isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildSubscriptionsList(
    BuildContext context,
    String status,
    bool isDark,
  ) {
    final subscriptions = _getSubscriptionsByStatus(status);

    if (subscriptions.isEmpty) {
      String emptyMessage;
      if (status == 'active') {
        emptyMessage = context.tr('no_active_subscriptions');
      } else if (status == 'pending') {
        emptyMessage = context.tr('no_pending_subscriptions');
      } else {
        emptyMessage = context.tr('no_expired_subscriptions');
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'active'
                  ? Icons.card_membership
                  : status == 'pending'
                  ? Icons.hourglass_empty
                  : Icons.history,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        return _buildSubscriptionCard(context, subscriptions[index], isDark);
      },
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    Map<String, dynamic> sub,
    bool isDark,
  ) {
    final lang = Localizations.localeOf(context).languageCode;
    String planName;
    if (lang == 'he') {
      planName = sub['plan_name_he'] ?? sub['plan_name_ar'] ?? '';
    } else if (lang == 'en') {
      planName = sub['plan_name_en'] ?? sub['plan_name_ar'] ?? '';
    } else {
      planName = sub['plan_name_ar'] ?? '';
    }
    String category;
    if (sub['category'] == 'properties') {
      category = context.tr('real_estate');
    } else if (sub['category'] == 'cars') {
      category = context.tr('vehicles');
    } else {
      category = context.tr('general');
    }
    final status = sub['status'] ?? 'active';
    final isExpired = sub['is_expired'] ?? false;
    final daysRemaining = sub['days_remaining'] ?? 0;
    final remaining = sub['listings_remaining'];

    // Status color and text
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (status == 'pending_verification') {
      statusColor = Colors.orange;
      statusText = context.tr('pending_approval');
      statusIcon = Icons.hourglass_top;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      statusText = context.tr('status_rejected');
      statusIcon = Icons.cancel;
    } else if (isExpired || status == 'expired') {
      statusColor = Colors.grey;
      statusText = context.tr('status_expired');
      statusIcon = Icons.event_busy;
    } else if (status == 'cancelled') {
      statusColor = Colors.grey;
      statusText = context.tr('status_cancelled');
      statusIcon = Icons.block;
    } else {
      statusColor = AppColors.success;
      statusText = context.tr('status_active');
      statusIcon = Icons.check_circle;
    }

    // Badge color
    Color badgeColor = AppColors.primary;
    final badge = sub['badge']?.toString().toLowerCase() ?? '';
    if (badge == 'gold') {
      badgeColor = const Color(0xFFFFD700);
    } else if (badge == 'silver') {
      badgeColor = const Color(0xFFC0C0C0);
    } else if (badge == 'bronze') {
      badgeColor = const Color(0xFFCD7F32);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  badgeColor.withValues(alpha: 0.2),
                  badgeColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    sub['category'] == 'properties'
                        ? Icons.home
                        : Icons.directions_car,
                    color: badgeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              planName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badge.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge.toUpperCase(),
                                style: TextStyle(
                                  color: badge == 'gold'
                                      ? Colors.black87
                                      : Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Listings info
                _buildInfoRow(
                  icon: Icons.list_alt,
                  label: context.tr('listings_label'),
                  value: remaining == 'unlimited'
                      ? context.tr('unlimited')
                      : '${sub['listings_used'] ?? 0} / ${sub['listings_limit'] ?? 0}',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                // Days remaining
                if (status == 'active' && !isExpired)
                  _buildInfoRow(
                    icon: Icons.timer,
                    label: context.tr('days_remaining_label'),
                    value: '$daysRemaining',
                    valueColor: daysRemaining < 7 ? Colors.orange : null,
                    isDark: isDark,
                  ),
                // Expiry date
                if (sub['expires_at'] != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.event,
                    label: context.tr('expiry_date'),
                    value: _formatDate(sub['expires_at']),
                    isDark: isDark,
                  ),
                ],
                // Created date
                if (sub['created_at'] != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: context.tr('subscription_date'),
                    value: _formatDate(sub['created_at']),
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
