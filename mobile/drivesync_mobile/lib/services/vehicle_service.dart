import 'package:flutter/material.dart';
import 'package:drivesync_mobile/models/vehicle.dart';

class VehicleService extends ChangeNotifier {
  // Singleton Pattern
  static final VehicleService _instance = VehicleService._internal();
  factory VehicleService() => _instance;
  VehicleService._internal();

  final List<Vehicle> _vehicles = [
    Vehicle(
      id: '1',
      name: 'Mahindra Thar 4x4',
      registrationNumber: 'TN-07-CS-1234',
      type: 'SUV',
      fuelType: 'Diesel',
      status: 'Available',
      insuranceExpiry: '2026-08-15',
      fcExpiry: '2030-10-10',
      permitExpiry: '2028-08-15',
      pollutionExpiry: '2026-12-12',
    ),
    Vehicle(
      id: '2',
      name: 'Honda City i-VTEC',
      registrationNumber: 'TN-07-DB-5678',
      type: 'Sedan',
      fuelType: 'Petrol',
      status: 'Booked',
      insuranceExpiry: '2026-06-15',
      fcExpiry: '2032-04-12',
      permitExpiry: '2028-06-15',
      pollutionExpiry: '2026-07-14',
    ),
    Vehicle(
      id: '3',
      name: 'Hyundai Creta SX',
      registrationNumber: 'TN-09-AB-2468',
      type: 'SUV',
      fuelType: 'Petrol',
      status: 'Maintenance',
      insuranceExpiry: '2026-09-22',
      fcExpiry: '2033-11-11',
      permitExpiry: '2028-09-22',
      pollutionExpiry: '2026-10-10',
    ),
    Vehicle(
      id: '4',
      name: 'Toyota Innova Crysta',
      registrationNumber: 'TN-12-YZ-7890',
      type: 'SUV',
      fuelType: 'Diesel',
      status: 'Available',
      insuranceExpiry: '2027-02-05',
      fcExpiry: '2031-01-01',
      permitExpiry: '2029-02-05',
      pollutionExpiry: '2026-08-20',
    ),
    Vehicle(
      id: '5',
      name: 'Maruti Swift LXI',
      registrationNumber: 'TN-01-XX-9999',
      type: 'Hatchback',
      fuelType: 'Petrol',
      status: 'Available',
      insuranceExpiry: '2026-06-20',
      fcExpiry: '2029-05-18',
      permitExpiry: '2028-06-20',
      pollutionExpiry: '2026-06-20',
    ),
  ];

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  Vehicle? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (_) {
      return null;
    }
  }

  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    notifyListeners();
  }

  void updateVehicle(Vehicle updatedVehicle) {
    final index = _vehicles.indexWhere((v) => v.id == updatedVehicle.id);
    if (index != -1) {
      _vehicles[index] = updatedVehicle;
      notifyListeners();
    }
  }

  void deleteVehicle(String id) {
    _vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
  }
}
