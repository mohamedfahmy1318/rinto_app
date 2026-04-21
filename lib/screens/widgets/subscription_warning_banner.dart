import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../packages/packages_screen.dart';

class SubscriptionWarningBanner extends StatefulWidget {
  const SubscriptionWarningBanner({super.key});

  @override
  State<SubscriptionWarningBanner> createState() =>
      _SubscriptionWarningBannerState();
}

class _SubscriptionWarningBannerState extends State<SubscriptionWarningBanner> {
  List<Map<String, dynamic>> _warnings = [];
  bool _isLoading = true;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _loadWarnings();
  }

  Future<void> _loadWarnings() async {
    try {
      final response = await ApiService.get('subscriptions/warnings');
      if (response.success && response.data != null && mounted) {
        setState(() {
          _warnings = List<Map<String, dynamic>>.from(
            response.data['warnings'] ?? [],
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _warnings.isEmpty || _isDismissed) {
      return const SizedBox.shrink();
    }

    final lang = Provider.of<AppProvider>(context).languageCode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PackagesScreen()),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'en'
                            ? 'Warning!'
                            : (lang == 'he' ? 'שים לב!' : 'تنبيه!'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getWarningText(lang),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        lang == 'en'
                            ? 'Renew'
                            : (lang == 'he' ? 'חדש' : 'تجديد'),
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => setState(() => _isDismissed = true),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getWarningText(String lang) {
    if (_warnings.isEmpty) return '';

    final warning = _warnings.first;
    final planName = lang == 'en'
        ? (warning['plan_name_en'] ?? warning['plan_name_ar'])
        : (lang == 'he'
              ? (warning['plan_name_he'] ?? warning['plan_name_ar'])
              : warning['plan_name_ar']);

    if (warning['type'] == 'expiring_soon') {
      final days = warning['days_remaining'];
      if (lang == 'en') {
        return 'Package "$planName" expires in $days ${days == 1 ? 'day' : 'days'}';
      } else if (lang == 'he') {
        return 'החבילה "$planName" תפוג בעוד $days ימים';
      }
      return 'باقة "$planName" ستنتهي خلال $days ${days == 1 ? 'يوم' : 'أيام'}';
    } else if (warning['type'] == 'low_listings') {
      final remaining = warning['listings_remaining'];
      if (lang == 'en') {
        return '$remaining ${remaining == 1 ? 'listing' : 'listings'} remaining in "$planName"';
      } else if (lang == 'he') {
        return 'נותרו $remaining מודעות בחבילה "$planName"';
      }
      return 'متبقي $remaining ${remaining == 1 ? 'إعلان' : 'إعلانات'} في باقة "$planName"';
    }

    return '';
  }
}
