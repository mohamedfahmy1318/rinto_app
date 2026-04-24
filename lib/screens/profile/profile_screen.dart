import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../presentation/auth/auth_routes.dart';
import 'my_subscriptions_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _activeSubscriptions = [];
  bool _loadingSubscriptions = false;

  @override
  void initState() {
    super.initState();
    _loadActiveSubscriptions();
  }

  Future<void> _loadActiveSubscriptions() async {
    setState(() => _loadingSubscriptions = true);

    final response = await ApiService.get(
      'subscriptions/me',
      params: {'status': 'active'},
    );

    if (mounted && response.success && response.data != null) {
      setState(() {
        _activeSubscriptions = List<Map<String, dynamic>>.from(response.data);
        _loadingSubscriptions = false;
      });
    } else {
      setState(() => _loadingSubscriptions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);
    final app = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('profile'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (auth.isLoggedIn) ...[
              _buildUserCard(context, auth, isDark),
              const SizedBox(height: 24),
              _buildActiveSubscriptionsSection(context, isDark),
              const SizedBox(height: 24),
            ] else ...[
              _buildLoginCard(context, isDark),
              const SizedBox(height: 24),
            ],
            _buildSettingsSection(context, app, isDark),
            const SizedBox(height: 24),
            _buildLegalSection(context, isDark),
            if (auth.isLoggedIn) ...[
              const SizedBox(height: 24),
              _buildLogoutButton(context, auth),
              const SizedBox(height: 8),
              _buildDeleteAccountButton(context, auth),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AuthProvider auth, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkCardBorder) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(
              auth.user?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      auth.user?.name ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (auth.user?.isTrusted ?? false) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.verified, color: AppColors.success, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  auth.user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionsSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkCardBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_membership, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('my_active_subscriptions'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MySubscriptionsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(
                  context.tr('view_all'),
                  style: const TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_loadingSubscriptions)
            const Center(child: CircularProgressIndicator())
          else if (_activeSubscriptions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('no_active_subscriptions'),
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._activeSubscriptions.map(
              (sub) => _buildSubscriptionCard(context, sub, isDark),
            ),
        ],
      ),
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
    final category = sub['category'] == 'properties'
        ? context.tr('real_estate')
        : context.tr('vehicles');
    final remaining = sub['listings_remaining'];
    final daysRemaining = sub['days_remaining'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              sub['category'] == 'properties'
                  ? Icons.home
                  : Icons.directions_car,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      planName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (sub['badge'] != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          sub['badge'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$category • ${context.tr('listings_remaining')} $remaining ${context.tr('listing_unit')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                Text(
                  '${context.tr('days_remaining')} $daysRemaining ${context.tr('day_unit')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: daysRemaining < 7
                        ? Colors.orange
                        : (isDark ? Colors.white54 : Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkCardBorder) : null,
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('login'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, loginRoute());
              },
              child: Text(context.tr('login')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AppProvider app,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkCardBorder) : null,
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.language_rounded,
            title: context.tr('language'),
            trailing: DropdownButton<String>(
              value: app.languageCode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
                DropdownMenuItem(value: 'he', child: Text('עברית')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) {
                if (value != null) app.setLanguage(value);
              },
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkCardBorder
                : AppColors.lightCardBorder,
          ),
          _buildSettingsTile(
            context,
            icon: app.isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            title: context.tr('dark_mode'),
            trailing: Switch(
              value: app.isDarkMode,
              onChanged: (_) => app.toggleTheme(),
              activeThumbColor: AppColors.primary,
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkCardBorder
                : AppColors.lightCardBorder,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_rounded,
            title: context.tr('notifications'),
            trailing: Switch(
              value: app.notificationsEnabled,
              onChanged: (value) => app.setNotificationsEnabled(value),
              activeThumbColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkCardBorder) : null,
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_rounded,
            title: context.tr('privacy_policy'),
            onTap: () => _openUrl('https://rento-go.com/privacy.php'),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkCardBorder
                : AppColors.lightCardBorder,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_rounded,
            title: context.tr('terms'),
            onTap: () => _openUrl('https://rento-go.com/terms.php'),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkCardBorder
                : AppColors.lightCardBorder,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_rounded,
            title: context.tr('about'),
            onTap: () => _openUrl('https://rento-go.com/about.php'),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.darkCardBorder
                : AppColors.lightCardBorder,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.support_agent_rounded,
            title: context.tr('contact_us'),
            onTap: () => _openWhatsApp('+972501234567'),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => auth.logout(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: Text(context.tr('logout')),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showDeleteAccountDialog(context, auth),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Icon(Icons.delete_forever_rounded, size: 20),
        label: Text(
          context.tr('delete_account'),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth) {
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Text(context.tr('delete_account')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('delete_account_confirm'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.tr('enter_password_to_confirm'),
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) return;

                      setState(() => isLoading = true);

                      final response = await ApiService.post(
                        'auth/delete-account',
                        body: {'password': passwordController.text},
                      );

                      if (response.success) {
                        Navigator.pop(ctx);
                        auth.logout();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('account_deleted')),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.tr('delete'),
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
