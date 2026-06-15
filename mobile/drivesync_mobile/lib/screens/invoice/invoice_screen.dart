import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/models/booking.dart';
import 'package:drivesync_mobile/models/vehicle.dart';
import 'package:drivesync_mobile/services/booking_service.dart';
import 'package:drivesync_mobile/services/vehicle_service.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Invoice Screen
// ═════════════════════════════════════════════════════════════════════════════

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  late String _bookingId;
  bool _isInit = true;
  bool _isGenerating = false;

  final _bookingService = BookingService();
  final _vehicleService = VehicleService();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _bookingId =
          ModalRoute.of(context)!.settings.arguments as String;
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Booking? get _booking => _bookingService.getBookingById(_bookingId);
  Vehicle? get _vehicle {
    final b = _booking;
    if (b == null) return null;
    return _vehicleService.getVehicleById(b.vehicleId);
  }

  // ── Date formatting ────────────────────────────────────────────────────────
  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

  String _invoiceNo(Booking b) =>
      'INV-${b.id.padLeft(4, '0')}-2026';

  // ── Live settlement values ─────────────────────────────────────────────────
  double _rentAmount(Booking b) => b.rentAmount ?? 0;
  double _extraKmCharge(Booking b) => b.extraKmCharge;
  double _toll(Booking b) => b.totalToll;
  double _fastag(Booking b) => b.totalFastag;
  double _fine(Booking b) => b.totalFine;
  double _damage(Booking b) => b.damageCharge ?? 0;
  double _grandTotal(Booking b) => b.grandTotal;
  double _advance(Booking b) => b.advanceAmount;
  double _balance(Booking b) =>
      (b.grandTotal - b.advanceAmount).clamp(0.0, double.infinity);

  // ═══════════════════════════════════════════════════════════════════════════
  // PDF BUILDER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<Uint8List> _buildPdf(Booking b, Vehicle? v) async {
    final doc = pw.Document();

    // Color palette
    final violet = PdfColor.fromHex('#6D5DF6');
    final violetLight = PdfColor.fromHex('#EDE9FE');
    final textDark = PdfColor.fromHex('#0F172A');
    final textGray = PdfColor.fromHex('#475569');
    final textMuted = PdfColor.fromHex('#94A3B8');
    final borderColor = PdfColor.fromHex('#E2E8F0');
    const white = PdfColors.white;

    // Load font
    final ttf = await PdfGoogleFonts.interRegular();
    final ttfBold = await PdfGoogleFonts.interBold();
    final ttfExtraBold = await PdfGoogleFonts.interExtraBold();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (ctx) => [
          // ── HEADER ─────────────────────────────────────────────────────────
          pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [violet, PdfColor.fromHex('#8B80F9')],
                begin: pw.Alignment.centerLeft,
                end: pw.Alignment.centerRight,
              ),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
            ),
            padding: const pw.EdgeInsets.all(24),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DriveSync',
                      style: pw.TextStyle(
                        font: ttfExtraBold,
                        fontSize: 28,
                        color: white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Book. Drive. Repeat.',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 11,
                        color: PdfColor(1, 1, 1, 0.7),
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'TAX INVOICE',
                      style: pw.TextStyle(
                        font: ttfExtraBold,
                        fontSize: 13,
                        color: white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: pw.BoxDecoration(
                        color: PdfColor(1, 1, 1, 0.3),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Text(
                        _invoiceNo(b),
                        style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 11,
                          color: white,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Date: ${_fmtDate(DateTime.now())}',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 9,
                        color: PdfColor(1, 1, 1, 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // ── CUSTOMER + VEHICLE INFO ────────────────────────────────────────
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Customer
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderColor, width: 1),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            decoration: pw.BoxDecoration(
                              color: violetLight,
                              borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(6)),
                            ),
                            child: pw.Text('👤',
                                style: const pw.TextStyle(fontSize: 10)),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Text('BILLED TO',
                              style: pw.TextStyle(
                                font: ttfExtraBold,
                                fontSize: 9,
                                color: violet,
                                letterSpacing: 1.2,
                              )),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(b.customerName,
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 13,
                            color: textDark,
                          )),
                      pw.SizedBox(height: 3),
                      pw.Text(b.customerMobile,
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 10,
                            color: textGray,
                          )),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              // Vehicle
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderColor, width: 1),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            decoration: pw.BoxDecoration(
                              color: violetLight,
                              borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(6)),
                            ),
                            child: pw.Text('🚗',
                                style: const pw.TextStyle(fontSize: 10)),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Text('VEHICLE',
                              style: pw.TextStyle(
                                font: ttfExtraBold,
                                fontSize: 9,
                                color: violet,
                                letterSpacing: 1.2,
                              )),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(v?.name ?? '—',
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 13,
                            color: textDark,
                          )),
                      pw.SizedBox(height: 3),
                      pw.Text(v?.registrationNumber ?? '—',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 10,
                            color: textGray,
                          )),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              // Booking dates
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderColor, width: 1),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(5),
                            decoration: pw.BoxDecoration(
                              color: violetLight,
                              borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(6)),
                            ),
                            child: pw.Text('📅',
                                style: const pw.TextStyle(fontSize: 10)),
                          ),
                          pw.SizedBox(width: 6),
                          pw.Text('RENTAL PERIOD',
                              style: pw.TextStyle(
                                font: ttfExtraBold,
                                fontSize: 9,
                                color: violet,
                                letterSpacing: 1.2,
                              )),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(_fmtDate(b.fromDate),
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 12,
                            color: textDark,
                          )),
                      pw.SizedBox(height: 2),
                      pw.Text('to',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 9,
                            color: textMuted,
                          )),
                      pw.SizedBox(height: 2),
                      pw.Text(_fmtDate(b.toDate),
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 12,
                            color: textDark,
                          )),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: violetLight,
                          borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(6)),
                        ),
                        child: pw.Text(
                          '${b.toDate.difference(b.fromDate).inDays + 1} Days',
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 10,
                            color: violet,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // ── CHARGES TABLE ──────────────────────────────────────────────────
          pw.Text('CHARGE DETAILS',
              style: pw.TextStyle(
                font: ttfExtraBold,
                fontSize: 10,
                color: violet,
                letterSpacing: 1.2,
              )),
          pw.SizedBox(height: 10),

          // Table header
          pw.Container(
            decoration: pw.BoxDecoration(
              color: violet,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(10),
                topRight: pw.Radius.circular(10),
              ),
            ),
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text('Description',
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 10,
                        color: white,
                      )),
                ),
                pw.Text('Amount',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 10,
                      color: white,
                    )),
              ],
            ),
          ),

          // Table rows
          ..._buildTableRows(b, ttf, ttfBold, textDark, textGray,
              borderColor, violetLight, violet),

          pw.SizedBox(height: 20),

          // ── SUMMARY BOX ────────────────────────────────────────────────────
          pw.Container(
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [violet, PdfColor.fromHex('#8B80F9')],
                begin: pw.Alignment.centerLeft,
                end: pw.Alignment.centerRight,
              ),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(14)),
            ),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              children: [
                _summaryLine(
                    'Sub-Total (All Charges)',
                    _grandTotal(b),
                    ttf,
                    ttfBold,
                    white,
                    PdfColor(1, 1, 1, 0.7)),
                pw.Divider(color: PdfColor(1, 1, 1, 0.3), height: 16),
                _summaryLine(
                    'Advance Deduction',
                    -_advance(b),
                    ttf,
                    ttfBold,
                    white,
                    PdfColor(1, 1, 1, 0.7),
                    isDeduction: true),
                pw.Divider(color: PdfColor(1, 1, 1, 0.3), height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('BALANCE DUE',
                        style: pw.TextStyle(
                          font: ttfExtraBold,
                          fontSize: 14,
                          color: white,
                        )),
                    pw.Text('₹ ${_balance(b).toStringAsFixed(0)}',
                        style: pw.TextStyle(
                          font: ttfExtraBold,
                          fontSize: 20,
                          color: white,
                          letterSpacing: -0.5,
                        )),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // ── FOOTER ─────────────────────────────────────────────────────────
          pw.Divider(color: borderColor),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Thank you for choosing DriveSync!',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 10,
                    color: violet,
                  )),
              pw.Text('Generated by DriveSync • ${_fmtDate(DateTime.now())}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 9,
                    color: textMuted,
                  )),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }

  List<pw.Widget> _buildTableRows(
    Booking b,
    pw.Font ttf,
    pw.Font ttfBold,
    PdfColor textDark,
    PdfColor textGray,
    PdfColor borderColor,
    PdfColor violetLight,
    PdfColor violet,
  ) {
    final rows = <_ChargeRow>[
      _ChargeRow('Rent Amount', _rentAmount(b), isMain: true),
      _ChargeRow('Extra KM Charges', _extraKmCharge(b)),
      _ChargeRow('Toll Charges', _toll(b)),
      _ChargeRow('FASTag Charges', _fastag(b)),
      _ChargeRow('Fine Charges', _fine(b)),
      _ChargeRow('Damage Charges', _damage(b)),
    ];

    return rows.asMap().entries.map((entry) {
      final i = entry.key;
      final row = entry.value;
      final isLast = i == rows.length - 1;
      final isEven = i % 2 == 0;

      return pw.Container(
        decoration: pw.BoxDecoration(
          color: isEven ? const PdfColor(0.98, 0.98, 1.0) : PdfColors.white,
          border: pw.Border(
            left: pw.BorderSide(color: borderColor, width: 1),
            right: pw.BorderSide(color: borderColor, width: 1),
            bottom: pw.BorderSide(color: borderColor, width: isLast ? 1 : 0.5),
          ),
          borderRadius: isLast
              ? const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(10),
                  bottomRight: pw.Radius.circular(10),
                )
              : null,
        ),
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                row.label,
                style: pw.TextStyle(
                  font: row.isMain ? ttfBold : ttf,
                  fontSize: 10,
                  color: row.isMain ? textDark : textGray,
                ),
              ),
            ),
            pw.Text(
              row.amount > 0 ? '₹ ${row.amount.toStringAsFixed(0)}' : '—',
              style: pw.TextStyle(
                font: row.isMain ? ttfBold : ttf,
                fontSize: 10,
                color: row.amount > 0 ? textDark : PdfColor.fromHex('#94A3B8'),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  pw.Widget _summaryLine(
    String label,
    double amount,
    pw.Font ttf,
    pw.Font ttfBold,
    PdfColor white,
    PdfColor whiteMuted, {
    bool isDeduction = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(font: ttf, fontSize: 11, color: whiteMuted)),
        pw.Text(
          isDeduction
              ? '- ₹ ${amount.abs().toStringAsFixed(0)}'
              : '₹ ${amount.toStringAsFixed(0)}',
          style: pw.TextStyle(font: ttfBold, fontSize: 11, color: white),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UI BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    final vehicle = _vehicle;

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Booking not found.',
              style: TextStyle(
                  color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Invoice',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Invoice preview card ──────────────────────────────────────
              _buildInvoicePreview(booking, vehicle),
              const SizedBox(height: 28),

              // ── Action buttons ────────────────────────────────────────────
              _buildActionButtons(booking, vehicle),
            ],
          ),
        ),
      ),
    );
  }

  // ── Invoice preview (Flutter UI mirror of the PDF) ────────────────────────

  Widget _buildInvoicePreview(Booking b, Vehicle? v) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DF6).withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _previewHeader(b),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Info row
                _previewInfoRow(b, v),
                const SizedBox(height: 20),
                // Divider + charges label
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            height: 1, color: AppTheme.borderLight)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('CHARGE DETAILS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryViolet,
                            letterSpacing: 1.0,
                          )),
                    ),
                    Expanded(
                        child: Container(
                            height: 1, color: AppTheme.borderLight)),
                  ],
                ),
                const SizedBox(height: 14),
                // Charges table
                _previewChargesTable(b),
                const SizedBox(height: 20),
                // Summary
                _previewSummaryCard(b),
                const SizedBox(height: 20),
                // Footer
                _previewFooter(b),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewHeader(Booking b) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF8B80F9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DriveSync',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 2),
                Text('Book. Drive. Repeat.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('TAX INVOICE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(_invoiceNo(b),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11)),
              ),
              const SizedBox(height: 4),
              Text(_fmtDate(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewInfoRow(Booking b, Vehicle? v) {
    final int days = b.toDate.difference(b.fromDate).inDays + 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: _InfoCard(
          icon: Icons.person_rounded,
          label: 'BILLED TO',
          line1: b.customerName,
          line2: b.customerMobile,
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _InfoCard(
          icon: Icons.directions_car_rounded,
          label: 'VEHICLE',
          line1: v?.name ?? '—',
          line2: v?.registrationNumber ?? '—',
        )),
        const SizedBox(width: 10),
        Expanded(
            child: _InfoCard(
          icon: Icons.date_range_rounded,
          label: 'PERIOD',
          line1: _fmtDate(b.fromDate),
          line2: _fmtDate(b.toDate),
          badge: '$days Days',
        )),
      ],
    );
  }

  Widget _previewChargesTable(Booking b) {
    final rows = [
      _ChargeRow('Rent Amount', _rentAmount(b), isMain: true),
      _ChargeRow('Extra KM Charges', _extraKmCharge(b)),
      _ChargeRow('Toll Charges', _toll(b)),
      _ChargeRow('FASTag Charges', _fastag(b)),
      _ChargeRow('Fine Charges', _fine(b)),
      _ChargeRow('Damage Charges', _damage(b)),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderLight, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppTheme.primaryViolet,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Text('Description',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ))),
                Text('Amount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
          // Rows
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            final isEven = i % 2 == 0;
            return Container(
              color: isEven
                  ? const Color(0xFFF5F3FF)
                  : Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: row.isMain
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: row.isMain
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    row.amount > 0
                        ? '₹ ${row.amount.toStringAsFixed(0)}'
                        : '—',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: row.amount > 0
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _previewSummaryCard(Booking b) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF8B80F9)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DF6).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryPreviewRow(
              'Sub-Total (All Charges)',
              '₹ ${_grandTotal(b).toStringAsFixed(0)}'),
          const Divider(
              height: 16, color: Colors.white30),
          _summaryPreviewRow(
              'Advance Deduction',
              '- ₹ ${_advance(b).toStringAsFixed(0)}',
              isDeduction: true),
          const Divider(
              height: 16, color: Colors.white30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BALANCE DUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  )),
              Text(
                '₹ ${_balance(b).toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryPreviewRow(String label, String value,
      {bool isDeduction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            )),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            )),
      ],
    );
  }

  Widget _previewFooter(Booking b) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Thank you for choosing DriveSync!',
            style: TextStyle(
              color: AppTheme.primaryViolet,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            )),
        Text(_invoiceNo(b),
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────

  Widget _buildActionButtons(Booking b, Vehicle? v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preview
        _ActionBtn(
          icon: Icons.visibility_rounded,
          label: 'Preview Invoice',
          sublabel: 'Full-screen PDF preview',
          gradient: const [Color(0xFF6D5DF6), Color(0xFF8B80F9)],
          isLoading: _isGenerating,
          onTap: () async {
            setState(() => _isGenerating = true);
            try {
              final bytes = await _buildPdf(b, v);
              if (!mounted) return;
              await Printing.layoutPdf(
                onLayout: (_) async => bytes,
                name: '${_invoiceNo(b)}.pdf',
              );
            } finally {
              if (mounted) setState(() => _isGenerating = false);
            }
          },
        ),
        const SizedBox(height: 12),

        // Download
        _ActionBtn(
          icon: Icons.download_rounded,
          label: 'Download PDF',
          sublabel: 'Save to device storage',
          gradient: const [Color(0xFF0F9F6E), Color(0xFF34D399)],
          isLoading: false,
          onTap: () async {
            setState(() => _isGenerating = true);
            try {
              final bytes = await _buildPdf(b, v);
              if (!mounted) return;
              await Printing.sharePdf(
                bytes: bytes,
                filename: '${_invoiceNo(b)}.pdf',
              );
            } finally {
              if (mounted) setState(() => _isGenerating = false);
            }
          },
        ),
        const SizedBox(height: 12),

        // Share
        _ActionBtn(
          icon: Icons.share_rounded,
          label: 'Share PDF',
          sublabel: 'Send via WhatsApp, Email, etc.',
          gradient: const [Color(0xFF3F83F8), Color(0xFF60A5FA)],
          isLoading: false,
          onTap: () async {
            setState(() => _isGenerating = true);
            try {
              final bytes = await _buildPdf(b, v);
              if (!mounted) return;
              await Printing.sharePdf(
                bytes: bytes,
                filename: '${_invoiceNo(b)}.pdf',
              );
            } finally {
              if (mounted) setState(() => _isGenerating = false);
            }
          },
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Local data model
// ═════════════════════════════════════════════════════════════════════════════

class _ChargeRow {
  final String label;
  final double amount;
  final bool isMain;
  const _ChargeRow(this.label, this.amount, {this.isMain = false});
}

// ═════════════════════════════════════════════════════════════════════════════
// Reusable sub-widgets
// ═════════════════════════════════════════════════════════════════════════════

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String line1;
  final String line2;
  final String? badge;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.line1,
    required this.line2,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: AppTheme.accentViolet,
                    borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, size: 12, color: AppTheme.primaryViolet),
              ),
              const SizedBox(width: 5),
              Text(label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryViolet,
                    letterSpacing: 0.8,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text(line1,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(line2,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (badge != null) ...[
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: AppTheme.accentViolet,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(badge!,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryViolet,
                  )),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final List<Color> gradient;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.gradient,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 2),
                  Text(sublabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }
}
