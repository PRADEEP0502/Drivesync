import 'package:flutter/material.dart';
import 'package:drivesync_mobile/core/routes/app_routes.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Tools — live modules
    final toolItems = [
      {
        'label': 'KM Tracking',
        'icon': Icons.speed_rounded,
        'color': AppTheme.primaryViolet,
        'action': () => Navigator.pushNamed(context, AppRoutes.kmTracking),
      },
      {
        'label': 'Customers',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF0F9F6E),
        'action': () => Navigator.pushNamed(context, AppRoutes.customerList),
      },
      {
        'label': 'Charges',
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF3F83F8),
        'action': () => Navigator.pushNamed(context, AppRoutes.charges),
      },
    ];

    // 12 Requested Menu Options
    final menuItems = [
      {
        'label': 'Reports',
        'icon': Icons.bar_chart_rounded,
        'action': () => _showProgressSnackbar(context, 'Reports'),
      },
      {
        'label': 'Invoices',
        'icon': Icons.receipt_long_rounded,
        'action': () => _showProgressSnackbar(context, 'Invoices'),
      },
      {
        'label': 'Payments',
        'icon': Icons.account_balance_wallet_rounded,
        'action': () => _showProgressSnackbar(context, 'Payments'),
      },
      {
        'label': 'Expenses',
        'icon': Icons.monetization_on_rounded,
        'action': () => _showProgressSnackbar(context, 'Expenses'),
      },
      {
        'label': 'Fine Manager',
        'icon': Icons.gavel_rounded,
        'action': () => _showProgressSnackbar(context, 'Fine Manager'),
      },
      {
        'label': 'Damage Manager',
        'icon': Icons.build_circle_rounded,
        'action': () => _showProgressSnackbar(context, 'Damage Manager'),
      },
      {
        'label': 'Reminders',
        'icon': Icons.notifications_active_rounded,
        'action': () => _showProgressSnackbar(context, 'Reminders'),
      },
      {
        'label': 'Backup',
        'icon': Icons.cloud_upload_rounded,
        'action': () => _showProgressSnackbar(context, 'Backup'),
      },
      {
        'label': 'Settings',
        'icon': Icons.settings_rounded,
        'action': () => _showProgressSnackbar(context, 'Settings'),
      },
      {
        'label': 'Profile',
        'icon': Icons.person_pin_rounded,
        'action': () => _showProgressSnackbar(context, 'Profile'),
      },
      {
        'label': 'Help & Support',
        'icon': Icons.help_center_rounded,
        'action': () => _showProgressSnackbar(context, 'Help & Support'),
      },
    ];

    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'More Options',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 120.0), // Padding for floating nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User profile card at top
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryViolet.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded, 
                      color: AppTheme.primaryViolet, 
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DriveSync Administrator',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'admin@drivesync.com',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Header — Active Modules
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Text(
                'ACTIVE MODULES',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F9F6E),
                  letterSpacing: 1.0,
                  fontSize: 11,
                ),
              ),
            ),

            // Active Module tiles (horizontal row)
            Row(
              children: toolItems.map((item) {
                final color = item['color'] as Color;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: toolItems.indexOf(item) == 0 ? 0 : 5,
                      right: toolItems.indexOf(item) == toolItems.length - 1 ? 0 : 5,
                    ),
                    child: InkWell(
                      onTap: item['action'] as VoidCallback,
                      borderRadius: BorderRadius.circular(20),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: color.withValues(alpha: 0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: color,
                                    size: 18,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Live',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Section Header
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Text(
                'SYSTEM DIRECTORY',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryViolet,
                  letterSpacing: 1.0,
                  fontSize: 11,
                ),
              ),
            ),


            // 2-Column Grid of SaaS actions
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return InkWell(
                  onTap: item['action'] as VoidCallback,
                  borderRadius: BorderRadius.circular(20),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryViolet.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: AppTheme.primaryViolet,
                            size: 20,
                          ),
                        ),
                        Text(
                          item['label'] as String,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  AppRoutes.auth, 
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressSnackbar(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$moduleName module is a work in progress.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryViolet,
      ),
    );
  }
}
