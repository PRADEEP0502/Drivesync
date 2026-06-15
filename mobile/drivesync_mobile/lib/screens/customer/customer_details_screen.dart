import 'package:flutter/material.dart';
import 'package:drivesync_mobile/services/customer_service.dart';
import 'package:drivesync_mobile/models/customer.dart';
import 'package:drivesync_mobile/core/routes/app_routes.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class CustomerDetailsScreen extends StatelessWidget {
  const CustomerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String customerId = ModalRoute.of(context)!.settings.arguments as String;
    final customerService = CustomerService();

    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Customer Profile',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: ListenableBuilder(
        listenable: customerService,
        builder: (context, _) {
          final Customer? customer = customerService.getCustomerById(customerId);

          if (customer == null) {
            return const Center(
              child: Text('Customer profile not found.', style: TextStyle(fontWeight: FontWeight.bold)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 40.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Profile Header Card
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryViolet.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppTheme.primaryViolet,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        customer.fullName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone_rounded, size: 14, color: AppTheme.primaryViolet),
                          const SizedBox(width: 6),
                          Text(
                            customer.mobileNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Statistics Metrics Title
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'Rental Statistics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Booking Stats Grid
                _buildStatsGrid(context, customer),
                const SizedBox(height: 28),

                // Documents & Address Card
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'Identity & Address',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailsCard(context, customer),
                const SizedBox(height: 36),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.editCustomer,
                      arguments: customer.id,
                    );
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryViolet,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context, 
                            AppRoutes.newBooking,
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                        label: const Text('Create Booking'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryViolet,
                          side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Rental History details are a work in progress.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.history_rounded, size: 16),
                        label: const Text('Rental History'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryViolet,
                          side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Customer customer) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          context,
          title: 'Total Bookings',
          value: '${customer.totalBookings}',
          icon: Icons.book_online_rounded,
          color: AppTheme.primaryViolet,
        ),
        _buildStatCard(
          context,
          title: 'Active Bookings',
          value: '${customer.activeBookings}',
          icon: Icons.directions_car_rounded,
          color: const Color(0xFF0F9F6E),
        ),
        _buildStatCard(
          context,
          title: 'Completed',
          value: '${customer.completedBookings}',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF3F83F8),
        ),
        _buildStatCard(
          context,
          title: 'Pending Payments',
          value: '₹${customer.pendingPayments.toStringAsFixed(0)}',
          icon: Icons.payment_rounded,
          color: customer.pendingPayments > 0 ? const Color(0xFFDC2626) : AppTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(14),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, Customer customer) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            label: 'Aadhaar Card Number',
            value: customer.aadhaarNumber,
            icon: Icons.badge_rounded,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            context,
            label: 'Driving License (DL) Number',
            value: customer.drivingLicenseNumber,
            icon: Icons.card_membership_rounded,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            context,
            label: 'Residential Address',
            value: customer.address,
            icon: Icons.home_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required String label, required String value, required IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentViolet,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryViolet, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
