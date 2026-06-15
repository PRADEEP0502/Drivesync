import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:drivesync_mobile/core/routes/app_routes.dart';
import 'package:drivesync_mobile/services/booking_service.dart';
import 'package:drivesync_mobile/services/vehicle_service.dart';
import 'package:drivesync_mobile/screens/vehicle/vehicle_list_screen.dart';
import 'package:drivesync_mobile/screens/booking/vehicle_calendar_screen.dart';
import 'package:drivesync_mobile/screens/dashboard/more_menu_screen.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassBackground(
      appBar: (_currentTabIndex == 1 || _currentTabIndex == 2 || _currentTabIndex == 3) 
        ? null 
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryViolet.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: AppTheme.primaryViolet,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'DriveSync',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Badge(
                  backgroundColor: AppTheme.primaryViolet,
                  label: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppTheme.textPrimary,
                    size: 24,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications opened.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
      bottomNavigationBar: FloatingGlassBottomNavBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
      child: _currentTabIndex == 0 
        ? const DashboardHomeView() 
        : _currentTabIndex == 1
            ? const VehicleCalendarScreen()
            : _currentTabIndex == 2
                ? const VehicleListScreen()
                : const MoreMenuScreen(),
    );
  }
}

class FloatingGlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingGlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': Icons.grid_view_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_month_rounded, 'label': 'Bookings'},
      {'icon': Icons.directions_car_rounded, 'label': 'Vehicles'},
      {'icon': Icons.menu_rounded, 'label': 'More'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88), // Higher contrast frosted white
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6), // Clearer border highlight
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DF6).withValues(alpha: 0.06), // Soft primary glow
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02), // slate drop-shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (index) {
                final tab = tabs[index];
                final isSelected = currentIndex == index;
                
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryViolet.withValues(alpha: 0.08) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          color: isSelected ? AppTheme.primaryViolet : const Color(0xFF9CA3AF),
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            color: isSelected ? AppTheme.primaryViolet : const Color(0xFF6B7280),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 120.0), // Extra bottom pad for floating nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fleet Overview Header
          Text(
            'FLEET STATUS',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryViolet,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'System Overview',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          // Hero Weekly Revenue Card
          _buildHeroRevenueCard(context),
          const SizedBox(height: 18),

          // Grid View of Cards (Active Bookings, Available Cars, Booked Cars, Total Vehicles)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            children: [
              _buildMetricCard(
                context,
                title: "Active Bookings",
                value: '8',
                trend: '80% utilization rate',
                isPositiveTrend: true,
                icon: Icons.bookmark_added_rounded,
                iconColor: const Color(0xFF0F9F6E),
                bgColor: const Color(0xFFD1FAE5),
              ),
              _buildMetricCard(
                context,
                title: "Available Cars",
                value: '12',
                trend: 'Ready for booking',
                isPositiveTrend: true,
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF3F83F8),
                bgColor: const Color(0xFFEBF5FF),
              ),
              _buildMetricCard(
                context,
                title: "Booked Cars",
                value: '8',
                trend: 'In transit',
                isPositiveTrend: true,
                icon: Icons.directions_run_rounded,
                iconColor: const Color(0xFFF2994A),
                bgColor: const Color(0xFFFEF3E6),
              ),
              _buildMetricCard(
                context,
                title: "Total Fleet",
                value: '20',
                trend: 'Active Vehicles',
                isPositiveTrend: true,
                icon: Icons.garage_rounded,
                iconColor: AppTheme.primaryViolet,
                bgColor: AppTheme.accentViolet,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Quick Actions Section
          _buildSectionHeader(context, title: "Quick Actions"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickActionButton(
                context,
                label: 'New Booking',
                icon: Icons.add_circle_outline_rounded,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.newBooking);
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Add Vehicle',
                icon: Icons.add_road_rounded,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.addVehicle);
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'View Vehicles',
                icon: Icons.directions_car_rounded,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.vehicleList);
                },
              ),
              _buildQuickActionButton(
                context,
                label: 'Reports',
                icon: Icons.bar_chart_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reports module is a work in progress.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 32),

          // Expiry Alerts Section
          _buildSectionHeader(context, title: "Expiry Alerts", actionLabel: "View All"),
          const SizedBox(height: 16),
          _buildExpiryAlertsList(context),

          const SizedBox(height: 32),

          // Recent Bookings Section
          _buildSectionHeader(context, title: "Recent Bookings", actionLabel: "View All"),
          const SizedBox(height: 16),
          _buildRecentBookingsList(context),
        ],
      ),
    );
  }

  Widget _buildHeroRevenueCard(BuildContext context) {
    final theme = Theme.of(context);
    final revenueData = [12000.0, 15000.0, 13800.0, 18000.0, 15500.0, 17900.0, 15500.0];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY REVENUE',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹1,08,400',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFF065F46)),
                    SizedBox(width: 4),
                    Text(
                      '+14.2%',
                      style: TextStyle(
                        color: Color(0xFF065F46),
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Modern Sparkline Chart
          SizedBox(
            height: 80,
            width: double.infinity,
            child: RevenueSparkline(
              data: revenueData,
              lineColor: AppTheme.primaryViolet,
              gradientColors: [
                AppTheme.primaryViolet.withValues(alpha: 0.25),
                AppTheme.primaryViolet.withValues(alpha: 0.0),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mon', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Tue', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Wed', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Thu', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Fri', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Sat', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('Sun', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, String? actionLabel}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryViolet,
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel),
          ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String trend,
    required bool isPositiveTrend,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 18,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trend,
                style: TextStyle(
                  color: isPositiveTrend ? const Color(0xFF047857) : AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Icon(
                icon,
                color: AppTheme.primaryViolet,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryAlertsList(BuildContext context) {
    final alerts = [
      {'title': 'Insurance Expiry', 'vehicle': 'Honda City (TN-07-CS-1234)', 'date': 'Expires in 3 Days', 'urgency': 'high'},
      {'title': 'Pollution Certificate', 'vehicle': 'Hyundai i20 (TN-09-AB-5678)', 'date': 'Expires in 5 Days', 'urgency': 'high'},
      {'title': 'Fitness Certificate (FC)', 'vehicle': 'Maruti Swift (TN-01-XX-9999)', 'date': 'Expires in 8 Days', 'urgency': 'medium'},
      {'title': 'National Permit', 'vehicle': 'Toyota Innova (TN-12-YZ-7890)', 'date': 'Expires in 12 Days', 'urgency': 'low'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        Color badgeColor;
        Color textColor;
        switch (alert['urgency']) {
          case 'high':
            badgeColor = const Color(0xFFFEE2E2);
            textColor = const Color(0xFF991B1B);
            break;
          case 'medium':
            badgeColor = const Color(0xFFFEF3C7);
            textColor = const Color(0xFF92400E);
            break;
          default:
            badgeColor = const Color(0xFFF3F4F6);
            textColor = const Color(0xFF374151);
        }

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: textColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title']!,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert['vehicle']!,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert['date']!,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentBookingsList(BuildContext context) {
    final theme = Theme.of(context);
    final bookingService = BookingService();
    final vehicleService = VehicleService();
    final allBookings = bookingService.bookings.toList().reversed.take(4).toList();

    if (allBookings.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: const Center(
          child: Text('No bookings yet.',
              style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
        ),
      );
    }

    final now = DateTime.now();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allBookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = allBookings[index];
        final vehicle = vehicleService.getVehicleById(booking.vehicleId);
        final vehicleName = vehicle?.name ?? 'Vehicle #${booking.vehicleId}';

        // Derive status
        final today = DateUtils.dateOnly(now);
        final from = DateUtils.dateOnly(booking.fromDate);
        final to = DateUtils.dateOnly(booking.toDate);
        String status;
        Color statusBg;
        Color statusText;
        if (today.isAfter(to)) {
          status = 'Completed';
          statusBg = const Color(0xFFF3F4F6);
          statusText = const Color(0xFF374151);
        } else if (!today.isBefore(from)) {
          status = 'Active';
          statusBg = const Color(0xFFD1FAE5);
          statusText = const Color(0xFF065F46);
        } else {
          status = 'Upcoming';
          statusBg = const Color(0xFFFEF3C7);
          statusText = const Color(0xFF92400E);
        }

        final fromStr =
            '${booking.fromDate.day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][booking.fromDate.month - 1]}';
        final toStr =
            '${booking.toDate.day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][booking.toDate.month - 1]}';

        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.bookingDetails,
            arguments: booking.id,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicleName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryViolet,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.date_range_rounded, size: 12, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '$fromStr - $toStr',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusText,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMuted),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RevenueSparkline extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final List<Color> gradientColors;

  const RevenueSparkline({
    super.key,
    required this.data,
    required this.lineColor,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SparklinePainter(
        data: data,
        lineColor: lineColor,
        gradientColors: gradientColors,
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final List<Color> gradientColors;

  SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double width = size.width;
    final double height = size.height;

    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final double stepX = width / (data.length - 1);

    final Path path = Path();
    final Path fillPath = Path();

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double normalizedY = (data[i] - minVal) / range;
      final double y = height - (normalizedY * (height - 24) + 12);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPointX = p0.dx + (p1.dx - p0.dx) / 2;
      
      path.cubicTo(controlPointX, p0.dy, controlPointX, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(controlPointX, p0.dy, controlPointX, p1.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(points.last.dx, height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
