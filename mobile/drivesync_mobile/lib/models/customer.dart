class Customer {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String aadhaarNumber;
  final String drivingLicenseNumber;
  final String address;
  
  // Stats
  final int totalBookings;
  final int activeBookings;
  final int completedBookings;
  final double pendingPayments;

  Customer({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    required this.aadhaarNumber,
    required this.drivingLicenseNumber,
    required this.address,
    this.totalBookings = 0,
    this.activeBookings = 0,
    this.completedBookings = 0,
    this.pendingPayments = 0.0,
  });

  Customer copyWith({
    String? id,
    String? fullName,
    String? mobileNumber,
    String? aadhaarNumber,
    String? drivingLicenseNumber,
    String? address,
    int? totalBookings,
    int? activeBookings,
    int? completedBookings,
    double? pendingPayments,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      drivingLicenseNumber: drivingLicenseNumber ?? this.drivingLicenseNumber,
      address: address ?? this.address,
      totalBookings: totalBookings ?? this.totalBookings,
      activeBookings: activeBookings ?? this.activeBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      pendingPayments: pendingPayments ?? this.pendingPayments,
    );
  }
}
