class Vehicle {
  final String id;
  final String name;
  final String registrationNumber;
  final String type; // SUV, Sedan, Hatchback, etc.
  final String fuelType; // Petrol, Diesel, EV, Hybrid
  final String status; // Available, Booked, Maintenance
  final String insuranceExpiry;
  final String fcExpiry;
  final String permitExpiry;
  final String pollutionExpiry;
  final String? imageUrl;

  Vehicle({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.type,
    required this.fuelType,
    required this.status,
    required this.insuranceExpiry,
    required this.fcExpiry,
    required this.permitExpiry,
    required this.pollutionExpiry,
    this.imageUrl,
  });

  Vehicle copyWith({
    String? id,
    String? name,
    String? registrationNumber,
    String? type,
    String? fuelType,
    String? status,
    String? insuranceExpiry,
    String? fcExpiry,
    String? permitExpiry,
    String? pollutionExpiry,
    String? imageUrl,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      type: type ?? this.type,
      fuelType: fuelType ?? this.fuelType,
      status: status ?? this.status,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      fcExpiry: fcExpiry ?? this.fcExpiry,
      permitExpiry: permitExpiry ?? this.permitExpiry,
      pollutionExpiry: pollutionExpiry ?? this.pollutionExpiry,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
