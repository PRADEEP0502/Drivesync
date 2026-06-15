// ─────────────────────────────────────────────────────────────────────────────
// Fine Types
// ─────────────────────────────────────────────────────────────────────────────

enum FineType {
  seatBelt('Seat Belt Fine'),
  speed('Speed Fine'),
  signal('Signal Fine'),
  parking('Parking Fine'),
  other('Other Fine');

  final String label;
  const FineType(this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// BookingFine value class
// ─────────────────────────────────────────────────────────────────────────────

class BookingFine {
  final FineType type;
  final double amount;
  final String notes;

  const BookingFine({
    required this.type,
    required this.amount,
    this.notes = '',
  });

  BookingFine copyWith({FineType? type, double? amount, String? notes}) {
    return BookingFine(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking model
// ─────────────────────────────────────────────────────────────────────────────

class Booking {
  // ── Core booking fields ────────────────────────────────────────────────────
  final String id;
  final String customerName;
  final String customerMobile;
  final String vehicleId;
  final DateTime fromDate;
  final DateTime toDate;
  final double advanceAmount;
  final double securityDeposit;
  final String? notes;

  // ── Trip fields (KM Tracking) ──────────────────────────────────────────────
  final double? startKm;
  final double? endKm;
  final double? allowedKm;
  final double? ratePerExtraKm;

  // ── Charges fields ─────────────────────────────────────────────────────────
  final List<double> tollEntries;
  final List<double> fastagEntries;
  final List<BookingFine> fineEntries;

  // ── Settlement fields ──────────────────────────────────────────────────────
  final double? rentAmount;
  final double? damageCharge;

  // ── Inspection notes ───────────────────────────────────────────────────────
  final String? inspectionNotes;

  Booking({
    required this.id,
    required this.customerName,
    required this.customerMobile,
    required this.vehicleId,
    required this.fromDate,
    required this.toDate,
    required this.advanceAmount,
    required this.securityDeposit,
    this.notes,
    // Trip
    this.startKm,
    this.endKm,
    this.allowedKm,
    this.ratePerExtraKm,
    // Charges
    List<double>? tollEntries,
    List<double>? fastagEntries,
    List<BookingFine>? fineEntries,
    // Settlement
    this.rentAmount,
    this.damageCharge,
    // Inspection
    this.inspectionNotes,
  })  : tollEntries = tollEntries ?? [],
        fastagEntries = fastagEntries ?? [],
        fineEntries = fineEntries ?? [];

  // ── Computed helpers ───────────────────────────────────────────────────────

  double get travelledKm {
    if (startKm == null || endKm == null) return 0;
    return (endKm! - startKm!).clamp(0.0, double.infinity);
  }

  double get extraKm {
    if (allowedKm == null) return travelledKm;
    return (travelledKm - allowedKm!).clamp(0.0, double.infinity);
  }

  double get extraKmCharge {
    if (ratePerExtraKm == null) return 0;
    return extraKm * ratePerExtraKm!;
  }

  double get totalToll =>
      tollEntries.fold(0.0, (sum, e) => sum + e);

  double get totalFastag =>
      fastagEntries.fold(0.0, (sum, e) => sum + e);

  double get totalFine =>
      fineEntries.fold(0.0, (sum, e) => sum + e.amount);

  double get grandTotal =>
      (rentAmount ?? 0) +
      extraKmCharge +
      totalToll +
      totalFastag +
      totalFine +
      (damageCharge ?? 0);

  double get balanceDue => (grandTotal - advanceAmount).clamp(0.0, double.infinity);

  // ── copyWith ───────────────────────────────────────────────────────────────

  Booking copyWith({
    String? id,
    String? customerName,
    String? customerMobile,
    String? vehicleId,
    DateTime? fromDate,
    DateTime? toDate,
    double? advanceAmount,
    double? securityDeposit,
    String? notes,
    double? startKm,
    double? endKm,
    double? allowedKm,
    double? ratePerExtraKm,
    List<double>? tollEntries,
    List<double>? fastagEntries,
    List<BookingFine>? fineEntries,
    double? rentAmount,
    double? damageCharge,
    String? inspectionNotes,
  }) {
    return Booking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      vehicleId: vehicleId ?? this.vehicleId,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      notes: notes ?? this.notes,
      startKm: startKm ?? this.startKm,
      endKm: endKm ?? this.endKm,
      allowedKm: allowedKm ?? this.allowedKm,
      ratePerExtraKm: ratePerExtraKm ?? this.ratePerExtraKm,
      tollEntries: tollEntries ?? this.tollEntries,
      fastagEntries: fastagEntries ?? this.fastagEntries,
      fineEntries: fineEntries ?? this.fineEntries,
      rentAmount: rentAmount ?? this.rentAmount,
      damageCharge: damageCharge ?? this.damageCharge,
      inspectionNotes: inspectionNotes ?? this.inspectionNotes,
    );
  }
}
