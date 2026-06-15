import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drivesync_mobile/core/routes/app_routes.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/models/booking.dart';
import 'package:drivesync_mobile/models/vehicle.dart';
import 'package:drivesync_mobile/services/booking_service.dart';
import 'package:drivesync_mobile/services/vehicle_service.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Booking Details Screen — 5-tab workflow
// ═════════════════════════════════════════════════════════════════════════════

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _bookingService = BookingService();
  final _vehicleService = VehicleService();
  late String _bookingId;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    _tabController.dispose();
    super.dispose();
  }

  Booking? get _booking => _bookingService.getBookingById(_bookingId);

  void _save(Booking updated) {
    _bookingService.updateBooking(updated);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    if (booking == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: const Center(
            child: Text('Booking not found.',
                style: TextStyle(fontWeight: FontWeight.bold))),
      );
    }
    final vehicle = _vehicleService.getVehicleById(booking.vehicleId);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppTheme.backgroundLight,
            elevation: 0,
            pinned: true,
            expandedHeight: 120,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 56, right: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.customerName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    vehicle?.name ?? 'Vehicle #${booking.vehicleId}',
                    style: const TextStyle(
                      color: AppTheme.primaryViolet,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _buildTabBar(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(booking: booking, vehicle: vehicle),
            _InspectionTab(booking: booking, onSave: _save),
            _TripTab(booking: booking, onSave: _save),
            _ChargesTab(booking: booking, onSave: _save),
            _SettlementTab(booking: booking),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = [
      _TabItem(Icons.info_outline_rounded, 'Overview'),
      _TabItem(Icons.camera_alt_outlined, 'Inspection'),
      _TabItem(Icons.route_rounded, 'Trip'),
      _TabItem(Icons.receipt_long_rounded, 'Charges'),
      _TabItem(Icons.account_balance_wallet_outlined, 'Settlement'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight, width: 1.5),
        boxShadow: AppTheme.softShadow,
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFF8B80F9)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
            fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.1),
        unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 11),
        tabs: tabs
            .map((t) => Tab(
                  height: 36,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(t.icon, size: 14),
                      const SizedBox(width: 5),
                      Text(t.label),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem(this.icon, this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} '
    '${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month - 1]} '
    '${d.year}';

Widget _tabScroll({required List<Widget> children}) {
  return SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
    physics: const BouncingScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

Widget _sectionLabel(String text, {Color color = AppTheme.primaryViolet}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 1.0,
      ),
    ),
  );
}

Widget _infoRow(String label, String value,
    {IconData? icon, Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.accentViolet,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppTheme.primaryViolet),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: valueColor ?? AppTheme.textPrimary)),
      ],
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — Overview
// ═════════════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final Booking booking;
  final Vehicle? vehicle;

  const _OverviewTab({required this.booking, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final int days =
        booking.toDate.difference(booking.fromDate).inDays + 1;

    return _tabScroll(children: [
      // ── Booking Dates banner ─────────────────────────────────────────────
      Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFF8B80F9)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D5DF6).withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('From',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(_fmtDate(booking.fromDate),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$days Days',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('To',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(_fmtDate(booking.toDate),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // ── Customer card ────────────────────────────────────────────────────
      _sectionLabel('CUSTOMER'),
      GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.accentViolet,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppTheme.primaryViolet, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.customerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone_rounded,
                              size: 12, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(booking.customerMobile,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _infoRow('Advance Paid', '₹ ${booking.advanceAmount.toStringAsFixed(0)}',
                icon: Icons.payments_rounded,
                valueColor: const Color(0xFF0F9F6E)),
            _infoRow('Security Deposit',
                '₹ ${booking.securityDeposit.toStringAsFixed(0)}',
                icon: Icons.lock_rounded),
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const Divider(height: 16),
              _infoRow('Notes', booking.notes!, icon: Icons.notes_rounded),
            ],
          ],
        ),
      ),
      const SizedBox(height: 20),

      // ── Vehicle card ─────────────────────────────────────────────────────
      _sectionLabel('VEHICLE'),
      GlassCard(
        padding: const EdgeInsets.all(16),
        child: vehicle == null
            ? const Center(
                child: Text('Vehicle data not found.',
                    style: TextStyle(color: AppTheme.textMuted)))
            : Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3F83F8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.directions_car_rounded,
                            color: Color(0xFF3F83F8), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vehicle?.name ?? '—',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Text(vehicle?.registrationNumber ?? '—',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryViolet)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _infoRow('Type', vehicle?.type ?? '—',
                      icon: Icons.category_rounded),
                  _infoRow('Fuel', vehicle?.fuelType ?? '—',
                      icon: Icons.local_gas_station_rounded),
                ],
              ),
      ),
    ]);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — Inspection
// ═════════════════════════════════════════════════════════════════════════════

class _InspectionTab extends StatefulWidget {
  final Booking booking;
  final void Function(Booking) onSave;

  const _InspectionTab({required this.booking, required this.onSave});

  @override
  State<_InspectionTab> createState() => _InspectionTabState();
}

class _InspectionTabState extends State<_InspectionTab> {
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl =
        TextEditingController(text: widget.booking.inspectionNotes ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveNotes() {
    widget.onSave(widget.booking.copyWith(inspectionNotes: _notesCtrl.text.trim()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Inspection notes saved.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primaryViolet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tabScroll(children: [
      _sectionLabel('BEFORE RENT'),
      Row(
        children: [
          Expanded(
              child: _MediaPlaceholder(
                  icon: Icons.add_photo_alternate_rounded,
                  label: 'Before Rent\nPhotos',
                  color: const Color(0xFF3F83F8))),
          const SizedBox(width: 12),
          Expanded(
              child: _MediaPlaceholder(
                  icon: Icons.videocam_rounded,
                  label: 'Before Rent\nVideo',
                  color: const Color(0xFF3F83F8))),
        ],
      ),
      const SizedBox(height: 20),

      _sectionLabel('AFTER RENT', color: const Color(0xFFDC2626)),
      Row(
        children: [
          Expanded(
              child: _MediaPlaceholder(
                  icon: Icons.add_photo_alternate_rounded,
                  label: 'After Rent\nPhotos',
                  color: const Color(0xFFDC2626))),
          const SizedBox(width: 12),
          Expanded(
              child: _MediaPlaceholder(
                  icon: Icons.videocam_rounded,
                  label: 'After Rent\nVideo',
                  color: const Color(0xFFDC2626))),
        ],
      ),
      const SizedBox(height: 20),

      _sectionLabel('INSPECTION NOTES'),
      GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText:
                    'Record vehicle condition, scratches, damages before and after rent...',
                prefixIcon: Icon(Icons.notes_rounded,
                    size: 20, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _saveNotes,
              icon: const Icon(Icons.save_rounded, size: 16),
              label: const Text('Save Notes'),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _MediaPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MediaPlaceholder({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$label upload coming soon.'),
              behavior: SnackBarBehavior.floating),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.4),
            ),
            const SizedBox(height: 6),
            Text('Tap to Upload',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3 — Trip (KM Tracking)
// ═════════════════════════════════════════════════════════════════════════════

class _TripTab extends StatefulWidget {
  final Booking booking;
  final void Function(Booking) onSave;

  const _TripTab({required this.booking, required this.onSave});

  @override
  State<_TripTab> createState() => _TripTabState();
}

class _TripTabState extends State<_TripTab> {
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _allowedCtrl;
  late final TextEditingController _rateCtrl;

  double _travelled = 0;
  double _extraKm = 0;
  double _extraCharge = 0;

  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    _startCtrl = TextEditingController(
        text: b.startKm != null ? b.startKm!.toStringAsFixed(0) : '');
    _endCtrl = TextEditingController(
        text: b.endKm != null ? b.endKm!.toStringAsFixed(0) : '');
    _allowedCtrl = TextEditingController(
        text: b.allowedKm != null ? b.allowedKm!.toStringAsFixed(0) : '');
    _rateCtrl = TextEditingController(
        text: b.ratePerExtraKm != null
            ? b.ratePerExtraKm!.toStringAsFixed(0)
            : '');

    for (final c in [_startCtrl, _endCtrl, _allowedCtrl, _rateCtrl]) {
      c.addListener(_recalc);
    }
    _recalc();
  }

  @override
  void dispose() {
    for (final c in [_startCtrl, _endCtrl, _allowedCtrl, _rateCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _recalc() {
    final start = double.tryParse(_startCtrl.text) ?? 0;
    final end = double.tryParse(_endCtrl.text) ?? 0;
    final allowed = double.tryParse(_allowedCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    setState(() {
      _travelled = (end - start).clamp(0.0, double.infinity);
      _extraKm = (_travelled - allowed).clamp(0.0, double.infinity);
      _extraCharge = _extraKm * rate;
    });
  }

  void _saveTrip() {
    widget.onSave(widget.booking.copyWith(
      startKm: double.tryParse(_startCtrl.text),
      endKm: double.tryParse(_endCtrl.text),
      allowedKm: double.tryParse(_allowedCtrl.text),
      ratePerExtraKm: double.tryParse(_rateCtrl.text),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Trip data saved.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primaryViolet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tabScroll(children: [
      // ── Odometer inputs ──────────────────────────────────────────────────
      _sectionLabel('ODOMETER READINGS'),
      GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _KmField(
              controller: _startCtrl,
              label: 'Start KM',
              hint: 'e.g.  45000',
              icon: Icons.trip_origin_rounded,
              iconColor: const Color(0xFF0F9F6E),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child:
                        Container(height: 1, color: AppTheme.borderLight)),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: AppTheme.accentViolet,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.south_rounded,
                      size: 14, color: AppTheme.primaryViolet),
                ),
                Expanded(
                    child:
                        Container(height: 1, color: AppTheme.borderLight)),
              ],
            ),
            const SizedBox(height: 10),
            _KmField(
              controller: _endCtrl,
              label: 'End KM',
              hint: 'e.g.  45350',
              icon: Icons.flag_rounded,
              iconColor: const Color(0xFFDC2626),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // ── Travelled KM banner ──────────────────────────────────────────────
      _TravelledBanner(travelledKm: _travelled),
      const SizedBox(height: 16),

      // ── Allowance & Rate ─────────────────────────────────────────────────
      _sectionLabel('ALLOWANCE & RATE', color: const Color(0xFF3F83F8)),
      GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _KmField(
              controller: _allowedCtrl,
              label: 'Allowed KM',
              hint: 'e.g.  300',
              icon: Icons.route_rounded,
              iconColor: const Color(0xFF3F83F8),
            ),
            const SizedBox(height: 16),
            _KmField(
              controller: _rateCtrl,
              label: 'Rate Per Extra KM',
              hint: 'e.g.  7',
              icon: Icons.currency_rupee_rounded,
              iconColor: const Color(0xFFF59E0B),
              prefix: '₹',
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // ── Calc chips ───────────────────────────────────────────────────────
      Row(
        children: [
          Expanded(
            child: _CalcChip(
              label: 'Extra KM',
              value: '${_extraKm.toStringAsFixed(0)} km',
              icon: Icons.add_road_rounded,
              color: _extraKm > 0
                  ? const Color(0xFFDC2626)
                  : AppTheme.textMuted,
              formula: 'Travelled − Allowed',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CalcChip(
              label: 'Extra Charge',
              value: '₹ ${_extraCharge.toStringAsFixed(0)}',
              icon: Icons.receipt_long_rounded,
              color: _extraCharge > 0
                  ? const Color(0xFFF59E0B)
                  : AppTheme.textMuted,
              formula: 'Extra KM × Rate',
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),

      ElevatedButton.icon(
        onPressed: _saveTrip,
        icon: const Icon(Icons.save_rounded, size: 16),
        label: const Text('Save Trip Data'),
      ),
    ]);
  }
}

class _KmField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final String? prefix;

  const _KmField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
          ],
          style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _TravelledBanner extends StatelessWidget {
  final double travelledKm;
  const _TravelledBanner({required this.travelledKm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF6D5DF6), Color(0xFF8B80F9)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DF6).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.straighten_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Travelled Distance',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          Text('${travelledKm.toStringAsFixed(0)} KM',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6)),
        ],
      ),
    );
  }
}

class _CalcChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String formula;

  const _CalcChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.formula,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.4)),
          Text(formula,
              style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 4 — Charges
// ═════════════════════════════════════════════════════════════════════════════

class _ChargesTab extends StatefulWidget {
  final Booking booking;
  final void Function(Booking) onSave;

  const _ChargesTab({required this.booking, required this.onSave});

  @override
  State<_ChargesTab> createState() => _ChargesTabState();
}

class _ChargesTabState extends State<_ChargesTab> {
  // Toll
  late List<TextEditingController> _tollCtrls;
  // FASTag
  late List<TextEditingController> _fastagCtrls;
  // Fine
  late List<FineType> _fineTypes;
  late List<TextEditingController> _fineAmtCtrls;
  late List<TextEditingController> _fineNoteCtrls;

  @override
  void initState() {
    super.initState();
    final b = widget.booking;

    _tollCtrls = b.tollEntries.isNotEmpty
        ? b.tollEntries
            .map((v) => TextEditingController(
                text: v > 0 ? v.toStringAsFixed(0) : ''))
            .toList()
        : [TextEditingController()];

    _fastagCtrls = b.fastagEntries.isNotEmpty
        ? b.fastagEntries
            .map((v) => TextEditingController(
                text: v > 0 ? v.toStringAsFixed(0) : ''))
            .toList()
        : [TextEditingController()];

    if (b.fineEntries.isNotEmpty) {
      _fineTypes = b.fineEntries.map((f) => f.type).toList();
      _fineAmtCtrls = b.fineEntries
          .map((f) => TextEditingController(
              text: f.amount > 0 ? f.amount.toStringAsFixed(0) : ''))
          .toList();
      _fineNoteCtrls = b.fineEntries
          .map((f) => TextEditingController(text: f.notes))
          .toList();
    } else {
      _fineTypes = [FineType.seatBelt];
      _fineAmtCtrls = [TextEditingController()];
      _fineNoteCtrls = [TextEditingController()];
    }

    for (final c in [..._tollCtrls, ..._fastagCtrls, ..._fineAmtCtrls]) {
      c.addListener(_rebuild);
    }
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    for (final c in [..._tollCtrls, ..._fastagCtrls, ..._fineAmtCtrls, ..._fineNoteCtrls]) {
      c.dispose();
    }
    super.dispose();
  }

  double get _totalToll =>
      _tollCtrls.fold(0.0, (s, c) => s + (double.tryParse(c.text) ?? 0));
  double get _totalFastag =>
      _fastagCtrls.fold(0.0, (s, c) => s + (double.tryParse(c.text) ?? 0));
  double get _totalFine =>
      _fineAmtCtrls.fold(0.0, (s, c) => s + (double.tryParse(c.text) ?? 0));

  void _saveCharges() {
    final tolls = _tollCtrls.map((c) => double.tryParse(c.text) ?? 0.0).toList();
    final fastags = _fastagCtrls.map((c) => double.tryParse(c.text) ?? 0.0).toList();
    final fines = List.generate(
      _fineTypes.length,
      (i) => BookingFine(
        type: _fineTypes[i],
        amount: double.tryParse(_fineAmtCtrls[i].text) ?? 0,
        notes: _fineNoteCtrls[i].text.trim(),
      ),
    );
    widget.onSave(widget.booking.copyWith(
      tollEntries: tolls,
      fastagEntries: fastags,
      fineEntries: fines,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Charges saved.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primaryViolet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _tabScroll(children: [
      // ── TOLL ──────────────────────────────────────────────────────────────
      _ChargesSectionHeader(
        icon: Icons.toll_rounded,
        label: 'TOLL CHARGES',
        color: const Color(0xFF3F83F8),
        total: _totalToll,
      ),
      const SizedBox(height: 10),
      GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._tollCtrls.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < _tollCtrls.length - 1 ? 12 : 0),
                child: _AmountRow(
                  index: i + 1,
                  controller: _tollCtrls[i],
                  icon: Icons.toll_rounded,
                  iconColor: const Color(0xFF3F83F8),
                  hint: 'e.g.  80',
                  canRemove: _tollCtrls.length > 1,
                  onRemove: () => setState(() {
                    _tollCtrls[i].dispose();
                    _tollCtrls.removeAt(i);
                  }),
                ),
              );
            }),
            const SizedBox(height: 10),
            _AddBtn(
              label: '+ Add Toll',
              color: const Color(0xFF3F83F8),
              onTap: () {
                final c = TextEditingController();
                c.addListener(_rebuild);
                setState(() => _tollCtrls.add(c));
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // ── FASTAG ────────────────────────────────────────────────────────────
      _ChargesSectionHeader(
        icon: Icons.contactless_rounded,
        label: 'FASTAG CHARGES',
        color: const Color(0xFF0F9F6E),
        total: _totalFastag,
      ),
      const SizedBox(height: 10),
      GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._fastagCtrls.asMap().entries.map((entry) {
              final i = entry.key;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < _fastagCtrls.length - 1 ? 12 : 0),
                child: _AmountRow(
                  index: i + 1,
                  controller: _fastagCtrls[i],
                  icon: Icons.contactless_rounded,
                  iconColor: const Color(0xFF0F9F6E),
                  hint: 'e.g.  150',
                  canRemove: _fastagCtrls.length > 1,
                  onRemove: () => setState(() {
                    _fastagCtrls[i].dispose();
                    _fastagCtrls.removeAt(i);
                  }),
                ),
              );
            }),
            const SizedBox(height: 10),
            _AddBtn(
              label: '+ Add FASTag',
              color: const Color(0xFF0F9F6E),
              onTap: () {
                final c = TextEditingController();
                c.addListener(_rebuild);
                setState(() => _fastagCtrls.add(c));
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // ── FINES ─────────────────────────────────────────────────────────────
      _ChargesSectionHeader(
        icon: Icons.gavel_rounded,
        label: 'FINE CHARGES',
        color: const Color(0xFFDC2626),
        total: _totalFine,
      ),
      const SizedBox(height: 10),
      GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._fineTypes.asMap().entries.map((entry) {
              final i = entry.key;
              return Column(
                children: [
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
                  _FineRow(
                    index: i + 1,
                    type: _fineTypes[i],
                    amtCtrl: _fineAmtCtrls[i],
                    noteCtrl: _fineNoteCtrls[i],
                    canRemove: _fineTypes.length > 1,
                    onRemove: () => setState(() {
                      _fineAmtCtrls[i].dispose();
                      _fineNoteCtrls[i].dispose();
                      _fineTypes.removeAt(i);
                      _fineAmtCtrls.removeAt(i);
                      _fineNoteCtrls.removeAt(i);
                    }),
                    onTypeChanged: (t) => setState(() => _fineTypes[i] = t),
                  ),
                ],
              );
            }),
            const SizedBox(height: 10),
            _AddBtn(
              label: '+ Add Fine',
              color: const Color(0xFFDC2626),
              onTap: () {
                final ac = TextEditingController();
                final nc = TextEditingController();
                ac.addListener(_rebuild);
                setState(() {
                  _fineTypes.add(FineType.seatBelt);
                  _fineAmtCtrls.add(ac);
                  _fineNoteCtrls.add(nc);
                });
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      ElevatedButton.icon(
        onPressed: _saveCharges,
        icon: const Icon(Icons.save_rounded, size: 16),
        label: const Text('Save Charges'),
      ),
    ]);
  }
}

// Charges sub-widgets ─────────────────────────────────────────────────────────

class _ChargesSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double total;

  const _ChargesSectionHeader(
      {required this.icon,
      required this.label,
      required this.color,
      required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 1.0)),
        ),
        if (total > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: color.withValues(alpha: 0.25), width: 1)),
            child: Text('₹ ${total.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: color)),
          ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final String hint;
  final bool canRemove;
  final VoidCallback onRemove;

  const _AmountRow({
    required this.index,
    required this.controller,
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle),
          child: Center(
            child: Text('$index',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: iconColor)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
            ],
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              prefixText: '₹  ',
              prefixStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppTheme.textPrimary),
            ),
          ),
        ),
        if (canRemove)
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_rounded,
                color: Color(0xFFDC2626), size: 20),
            constraints:
                const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: const EdgeInsets.only(left: 4),
          ),
      ],
    );
  }
}

class _FineRow extends StatelessWidget {
  final int index;
  final FineType type;
  final TextEditingController amtCtrl;
  final TextEditingController noteCtrl;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<FineType> onTypeChanged;

  const _FineRow({
    required this.index,
    required this.type,
    required this.amtCtrl,
    required this.noteCtrl,
    required this.canRemove,
    required this.onRemove,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Center(
                child: Text('$index',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDC2626))),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Fine Entry',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const Spacer(),
            if (canRemove)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_rounded,
                    color: Color(0xFFDC2626), size: 20),
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight, width: 1.5)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<FineType>(
              value: type,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textSecondary),
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
              items: FineType.values
                  .map((t) => DropdownMenuItem(
                      value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onTypeChanged(v);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: amtCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
          ],
          style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Fine Amount  e.g.  500',
            prefixText: '₹  ',
            prefixStyle: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppTheme.textPrimary),
            prefixIcon: Icon(Icons.gavel_rounded,
                size: 18, color: Color(0xFFDC2626)),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: noteCtrl,
          maxLines: 2,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Notes (optional)',
            prefixIcon: Icon(Icons.notes_rounded,
                size: 18, color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }
}

class _AddBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: 0.22), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_rounded, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 5 — Settlement
// ═════════════════════════════════════════════════════════════════════════════

class _SettlementTab extends StatefulWidget {
  final Booking booking;
  const _SettlementTab({required this.booking});

  @override
  State<_SettlementTab> createState() => _SettlementTabState();
}

class _SettlementTabState extends State<_SettlementTab> {
  late final TextEditingController _rentCtrl;
  late final TextEditingController _damageCtrl;
  late final BookingService _svc;

  @override
  void initState() {
    super.initState();
    _svc = BookingService();
    final b = widget.booking;
    _rentCtrl = TextEditingController(
        text: b.rentAmount != null ? b.rentAmount!.toStringAsFixed(0) : '');
    _damageCtrl = TextEditingController(
        text: b.damageCharge != null
            ? b.damageCharge!.toStringAsFixed(0)
            : '');
    _rentCtrl.addListener(_rebuild);
    _damageCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _rentCtrl.dispose();
    _damageCtrl.dispose();
    super.dispose();
  }

  // Use live controller values for grand total computation
  double get _liveRent => double.tryParse(_rentCtrl.text) ?? 0;
  double get _liveDamage => double.tryParse(_damageCtrl.text) ?? 0;

  double get _grandTotal {
    final b = widget.booking;
    return _liveRent +
        b.extraKmCharge +
        b.totalToll +
        b.totalFastag +
        b.totalFine +
        _liveDamage;
  }

  double get _balance =>
      (_grandTotal - widget.booking.advanceAmount).clamp(0.0, double.infinity);

  void _saveSettlement() {
    _svc.updateBooking(widget.booking.copyWith(
      rentAmount: _liveRent,
      damageCharge: _liveDamage,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Settlement saved.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primaryViolet),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return _tabScroll(children: [
      _sectionLabel('SETTLEMENT BREAKDOWN'),
      GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Rent Amount (editable)
            _EditableSettlementRow(
              label: 'Rent Amount',
              controller: _rentCtrl,
              icon: Icons.home_rounded,
              iconColor: AppTheme.primaryViolet,
            ),
            _div(),
            // Advance (read-only)
            _SettlRow(
              icon: Icons.payments_rounded,
              iconColor: const Color(0xFF0F9F6E),
              label: 'Advance Paid',
              value: '₹ ${b.advanceAmount.toStringAsFixed(0)}',
              valueColor: const Color(0xFF0F9F6E),
            ),
            _div(),
            // Extra KM Charge (computed)
            _SettlRow(
              icon: Icons.add_road_rounded,
              iconColor: const Color(0xFFDC2626),
              label: 'Extra KM Charge',
              value: '₹ ${b.extraKmCharge.toStringAsFixed(0)}',
              valueColor:
                  b.extraKmCharge > 0 ? const Color(0xFFDC2626) : null,
            ),
            _div(),
            // Toll
            _SettlRow(
              icon: Icons.toll_rounded,
              iconColor: const Color(0xFF3F83F8),
              label: 'Total Toll',
              value: '₹ ${b.totalToll.toStringAsFixed(0)}',
              valueColor:
                  b.totalToll > 0 ? const Color(0xFF3F83F8) : null,
            ),
            _div(),
            // FASTag
            _SettlRow(
              icon: Icons.contactless_rounded,
              iconColor: const Color(0xFF0F9F6E),
              label: 'Total FASTag',
              value: '₹ ${b.totalFastag.toStringAsFixed(0)}',
              valueColor:
                  b.totalFastag > 0 ? const Color(0xFF0F9F6E) : null,
            ),
            _div(),
            // Fine
            _SettlRow(
              icon: Icons.gavel_rounded,
              iconColor: const Color(0xFFDC2626),
              label: 'Total Fine',
              value: '₹ ${b.totalFine.toStringAsFixed(0)}',
              valueColor:
                  b.totalFine > 0 ? const Color(0xFFDC2626) : null,
            ),
            _div(),
            // Damage (editable)
            _EditableSettlementRow(
              label: 'Damage Charge',
              controller: _damageCtrl,
              icon: Icons.car_crash_rounded,
              iconColor: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // ── Grand Total hero ─────────────────────────────────────────────────
      Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF6D5DF6), Color(0xFF8B80F9)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D5DF6).withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grand Total',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  Text('₹ ${_grandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          letterSpacing: -0.8)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Balance Due',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('₹ ${_balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        letterSpacing: -0.5)),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      ElevatedButton.icon(
        onPressed: _saveSettlement,
        icon: const Icon(Icons.save_rounded, size: 16),
        label: const Text('Save Settlement'),
      ),
      const SizedBox(height: 12),

      // ── Generate Invoice ─────────────────────────────────────────────────
      GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.invoice,
          arguments: widget.booking.id,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6D5DF6), Color(0xFF8B80F9)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6D5DF6).withValues(alpha: 0.3),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generate Invoice',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Preview, Download or Share PDF',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 14),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _div() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: AppTheme.borderLight));
}

class _SettlRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _SettlRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary))),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: valueColor ?? AppTheme.textPrimary)),
      ],
    );
  }
}

class _EditableSettlementRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;

  const _EditableSettlementRow({
    required this.label,
    required this.controller,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary))),
        SizedBox(
          width: 120,
          child: TextFormField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
            ],
            textAlign: TextAlign.right,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: iconColor),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide:
                    BorderSide(color: AppTheme.borderLight, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide:
                    BorderSide(color: AppTheme.borderLight, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(
                    color: AppTheme.primaryViolet, width: 1.8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
