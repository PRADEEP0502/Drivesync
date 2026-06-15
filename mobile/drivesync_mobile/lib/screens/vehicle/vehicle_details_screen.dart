import 'package:flutter/material.dart';
import 'package:drivesync_mobile/services/vehicle_service.dart';
import 'package:drivesync_mobile/models/vehicle.dart';
import 'package:drivesync_mobile/core/routes/app_routes.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String vehicleId = ModalRoute.of(context)!.settings.arguments as String;
    final vehicleService = VehicleService();

    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vehicle Details',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: ListenableBuilder(
        listenable: vehicleService,
        builder: (context, _) {
          final Vehicle? vehicle = vehicleService.getVehicleById(vehicleId);

          if (vehicle == null) {
            return const Center(
              child: Text('Vehicle not found.', style: TextStyle(fontWeight: FontWeight.bold)),
            );
          }

          Color statusBg;
          Color statusText;
          switch (vehicle.status) {
            case 'Available':
              statusBg = const Color(0xFFD1FAE5);
              statusText = const Color(0xFF065F46);
              break;
            case 'Booked':
              statusBg = const Color(0xFFFEE2E2);
              statusText = const Color(0xFF991B1B);
              break;
            case 'Maintenance':
              statusBg = const Color(0xFFFEF3C7);
              statusText = const Color(0xFF92400E);
              break;
            default:
              statusBg = const Color(0xFFF3F4F6);
              statusText = const Color(0xFF374151);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 40.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Graphic Card
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
                          Icons.directions_car_filled_rounded,
                          color: AppTheme.primaryViolet,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        vehicle.name,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.registrationNumber,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.primaryViolet,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDetailBadge(vehicle.type),
                          const SizedBox(width: 8),
                          _buildDetailBadge(vehicle.fuelType),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vehicle.status,
                              style: TextStyle(
                                color: statusText,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Expiry Alerts Header
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    'Document Expiries',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Document Expiries Card
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildExpiryRow(
                        context,
                        label: 'Insurance Expiry',
                        date: vehicle.insuranceExpiry,
                        icon: Icons.security_rounded,
                      ),
                      const Divider(height: 24),
                      _buildExpiryRow(
                        context,
                        label: 'Fitness Certificate (FC) Expiry',
                        date: vehicle.fcExpiry,
                        icon: Icons.verified_rounded,
                      ),
                      const Divider(height: 24),
                      _buildExpiryRow(
                        context,
                        label: 'Permit Expiry',
                        date: vehicle.permitExpiry,
                        icon: Icons.assignment_rounded,
                      ),
                      const Divider(height: 24),
                      _buildExpiryRow(
                        context,
                        label: 'Pollution (PUCC) Expiry',
                        date: vehicle.pollutionExpiry,
                        icon: Icons.nature_people_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.editVehicle,
                      arguments: vehicle.id,
                    );
                  },
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit Vehicle'),
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
                            AppRoutes.calendar, 
                            arguments: vehicle.id,
                          );
                        },
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: const Text('View Calendar'),
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
                          Navigator.pushNamed(
                            context, 
                            AppRoutes.newBooking, 
                            arguments: vehicle.id,
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
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.borderLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildExpiryRow(BuildContext context, {required String label, required String date, required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentViolet,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryViolet, size: 20),
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
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
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
