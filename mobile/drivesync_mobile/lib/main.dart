import 'package:flutter/material.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/core/routes/app_routes.dart';

void main() {
  runApp(const DriveSyncApp());
}

class DriveSyncApp extends StatelessWidget {
  const DriveSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveSync',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
