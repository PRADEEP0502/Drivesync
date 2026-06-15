import 'package:flutter/material.dart';
import 'package:drivesync_mobile/models/customer.dart';

class CustomerService extends ChangeNotifier {
  // Singleton Pattern
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  final List<Customer> _customers = [
    Customer(
      id: '1',
      fullName: 'Ramesh Kumar',
      mobileNumber: '9876543210',
      aadhaarNumber: '1234-5678-9012',
      drivingLicenseNumber: 'TN-07-20150012345',
      address: 'No. 12, Anna Nagar East, Chennai - 600102',
      totalBookings: 3,
      activeBookings: 1,
      completedBookings: 2,
      pendingPayments: 0.0,
    ),
    Customer(
      id: '2',
      fullName: 'Ananya Sen',
      mobileNumber: '9123456789',
      aadhaarNumber: '9876-5432-1098',
      drivingLicenseNumber: 'WB-01-20180054321',
      address: 'Flat 4B, Greenfield Heights, Rajarhat, Kolkata - 700135',
      totalBookings: 2,
      activeBookings: 1,
      completedBookings: 1,
      pendingPayments: 1500.0,
    ),
    Customer(
      id: '3',
      fullName: 'John Doe',
      mobileNumber: '9000000001',
      aadhaarNumber: '1111-2222-3333',
      drivingLicenseNumber: 'DL-03-20200098765',
      address: 'H-24, Connaught Place, New Delhi - 110001',
      totalBookings: 5,
      activeBookings: 0,
      completedBookings: 5,
      pendingPayments: 0.0,
    ),
  ];

  List<Customer> get customers => List.unmodifiable(_customers);

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (_) {
      return null;
    }
  }

  void addCustomer(Customer customer) {
    _customers.add(customer);
    notifyListeners();
  }

  void updateCustomer(Customer updatedCustomer) {
    final index = _customers.indexWhere((c) => c.id == updatedCustomer.id);
    if (index != -1) {
      // Retain stats if editing only details
      final old = _customers[index];
      _customers[index] = updatedCustomer.copyWith(
        totalBookings: old.totalBookings,
        activeBookings: old.activeBookings,
        completedBookings: old.completedBookings,
        pendingPayments: old.pendingPayments,
      );
      notifyListeners();
    }
  }

  void deleteCustomer(String id) {
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
