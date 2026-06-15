import 'package:flutter/material.dart';
import 'package:drivesync_mobile/screens/splash/splash_screen.dart';
import 'package:drivesync_mobile/screens/auth/login_screen.dart';
import 'package:drivesync_mobile/screens/dashboard/dashboard_screen.dart';
import 'package:drivesync_mobile/screens/vehicle/vehicle_list_screen.dart';
import 'package:drivesync_mobile/screens/vehicle/vehicle_details_screen.dart';
import 'package:drivesync_mobile/screens/vehicle/add_edit_vehicle_screen.dart';
import 'package:drivesync_mobile/screens/booking/vehicle_calendar_screen.dart';
import 'package:drivesync_mobile/screens/booking/new_booking_screen.dart';
import 'package:drivesync_mobile/screens/customer/customer_list_screen.dart';
import 'package:drivesync_mobile/screens/customer/customer_details_screen.dart';
import 'package:drivesync_mobile/screens/customer/add_edit_customer_screen.dart';
import 'package:drivesync_mobile/screens/km_tracking/km_tracking_screen.dart';
import 'package:drivesync_mobile/screens/charges/charges_screen.dart';
import 'package:drivesync_mobile/screens/booking/booking_details_screen.dart';
import 'package:drivesync_mobile/screens/invoice/invoice_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String vehicleList = '/vehicles';
  static const String addVehicle = '/add-vehicle';
  static const String editVehicle = '/edit-vehicle';
  static const String vehicleDetails = '/vehicle-details';
  static const String calendar = '/calendar';
  static const String newBooking = '/new-booking';
  static const String customerList = '/customers';
  static const String addCustomer = '/add-customer';
  static const String editCustomer = '/edit-customer';
  static const String customerDetails = '/customer-details';
  static const String kmTracking = '/km-tracking';
  static const String charges = '/charges';
  static const String bookingDetails = '/booking-details';
  static const String invoice = '/invoice';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    auth: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    vehicleList: (context) => const VehicleListScreen(),
    addVehicle: (context) => const AddEditVehicleScreen(),
    editVehicle: (context) => const AddEditVehicleScreen(),
    vehicleDetails: (context) => const VehicleDetailsScreen(),
    calendar: (context) => const VehicleCalendarScreen(),
    newBooking: (context) => const NewBookingScreen(),
    customerList: (context) => const CustomerListScreen(),
    addCustomer: (context) => const AddEditCustomerScreen(),
    editCustomer: (context) => const AddEditCustomerScreen(),
    customerDetails: (context) => const CustomerDetailsScreen(),
    kmTracking: (context) => const KmTrackingScreen(),
    charges: (context) => const ChargesScreen(),
    bookingDetails: (context) => const BookingDetailsScreen(),
    invoice: (context) => const InvoiceScreen(),
  };
}
