import 'package:flutter/material.dart';
import 'package:drivesync_mobile/services/vehicle_service.dart';
import 'package:drivesync_mobile/models/vehicle.dart';
import 'package:drivesync_mobile/core/routes/app_routes.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicleService = VehicleService();

    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vehicles',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Padding to clear floating bottom nav bar
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.addVehicle);
          },
          backgroundColor: AppTheme.primaryViolet,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.add_rounded),
        ),
      ),
      child: ListenableBuilder(
        listenable: vehicleService,
        builder: (context, _) {
          final List<Vehicle> vehicles = vehicleService.vehicles;

          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_filled_rounded,
                    size: 64,
                    color: AppTheme.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Vehicles Registered',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first vehicle.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 160.0), // Extra bottom padding for FAB and nav bar
            physics: const BouncingScrollPhysics(),
            itemCount: vehicles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return _buildVehicleCard(context, vehicle);
            },
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
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

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          AppRoutes.vehicleDetails, 
          arguments: vehicle.id,
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryViolet.withValues(alpha: 0.08),
                    AppTheme.primaryViolet.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: AppTheme.primaryViolet,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.registrationNumber,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentViolet,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'SUV',
                          style: TextStyle(
                            color: AppTheme.primaryViolet,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vehicle.status,
                          style: TextStyle(
                            color: statusText,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
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
