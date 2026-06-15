import 'package:flutter/material.dart';
import 'package:drivesync_mobile/models/booking.dart';

class BookingService extends ChangeNotifier {
  // Singleton Pattern
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final List<Booking> _bookings = [
    Booking(
      id: '1',
      customerName: 'Ramesh Kumar',
      customerMobile: '9876543210',
      vehicleId: '1', // Thar
      fromDate: DateTime(2026, 6, 12),
      toDate: DateTime(2026, 6, 15),
      advanceAmount: 5000,
      securityDeposit: 10000,
      notes: 'Customer requested clean car.',
    ),
    Booking(
      id: '2',
      customerName: 'Ananya Sen',
      customerMobile: '9123456789',
      vehicleId: '2', // Honda City
      fromDate: DateTime(2026, 6, 13),
      toDate: DateTime(2026, 6, 14),
      advanceAmount: 3000,
      securityDeposit: 5000,
      notes: 'Deliver to railway station.',
    ),
    Booking(
      id: '3',
      customerName: 'John Doe',
      customerMobile: '9000000001',
      vehicleId: '4', // Innova
      fromDate: DateTime(2026, 6, 8),
      toDate: DateTime(2026, 6, 11),
      advanceAmount: 7000,
      securityDeposit: 15000,
      notes: 'Outstation trip.',
    ),
    Booking(
      id: '4',
      customerName: 'Baleno Booking Test',
      customerMobile: '9888877777',
      vehicleId: '5', // Swift (using Swift as mock for Baleno or other)
      fromDate: DateTime(2026, 6, 15),
      toDate: DateTime(2026, 6, 17),
      advanceAmount: 2000,
      securityDeposit: 4000,
      notes: 'Weekend trip.',
    ),
  ];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  List<Booking> getBookingsForVehicle(String vehicleId) {
    return _bookings.where((b) => b.vehicleId == vehicleId).toList()
      ..sort((a, b) => a.fromDate.compareTo(b.fromDate));
  }

  bool isVehicleAvailable(String vehicleId, DateTime fromDate, DateTime toDate, {String? excludeBookingId}) {
    final startNew = DateUtils.dateOnly(fromDate);
    final endNew = DateUtils.dateOnly(toDate);

    for (final booking in _bookings) {
      if (booking.vehicleId != vehicleId) continue;
      if (excludeBookingId != null && booking.id == excludeBookingId) continue;

      final startExisting = DateUtils.dateOnly(booking.fromDate);
      final endExisting = DateUtils.dateOnly(booking.toDate);

      // Overlap check
      if ((startNew.isBefore(endExisting) || startNew.isAtSameMomentAs(endExisting)) &&
          (endNew.isAfter(startExisting) || endNew.isAtSameMomentAs(startExisting))) {
        return false; // Overlap detected
      }
    }
    return true; // No overlaps
  }

  bool addBooking(Booking booking) {
    if (isVehicleAvailable(booking.vehicleId, booking.fromDate, booking.toDate)) {
      _bookings.add(booking);
      notifyListeners();
      return true; // Successful
    }
    return false; // Overlapping
  }

  Booking? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void updateBooking(Booking updated) {
    final index = _bookings.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      _bookings[index] = updated;
      notifyListeners();
    }
  }
}
