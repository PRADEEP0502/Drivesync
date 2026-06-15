import 'package:flutter/material.dart';
import 'package:drivesync_mobile/services/customer_service.dart';
import 'package:drivesync_mobile/models/customer.dart';
import 'package:drivesync_mobile/core/routes/app_routes.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class CustomerListScreen extends StatelessWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customerService = CustomerService();

    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Customers',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addCustomer);
        },
        backgroundColor: AppTheme.primaryViolet,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.add_rounded),
      ),
      child: ListenableBuilder(
        listenable: customerService,
        builder: (context, _) {
          final List<Customer> customers = customerService.customers;

          if (customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    size: 64,
                    color: AppTheme.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Registered Customers',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first customer.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 100.0), // Normal padding
            physics: const BouncingScrollPhysics(),
            itemCount: customers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final customer = customers[index];
              return _buildCustomerCard(context, customer);
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, Customer customer) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRoutes.customerDetails, 
          arguments: customer.id,
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryViolet.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppTheme.primaryViolet,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        customer.mobileNumber,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentViolet,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${customer.totalBookings} Bookings',
                      style: const TextStyle(
                        color: AppTheme.primaryViolet,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
