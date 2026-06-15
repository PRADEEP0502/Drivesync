import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class KmTrackingScreen extends StatefulWidget {
  const KmTrackingScreen({super.key});

  @override
  State<KmTrackingScreen> createState() => _KmTrackingScreenState();
}

class _KmTrackingScreenState extends State<KmTrackingScreen>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────────────────────
  final TextEditingController _startKmController = TextEditingController();
  final TextEditingController _endKmController = TextEditingController();
  final TextEditingController _allowedKmController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();

  // ── Calculated values ───────────────────────────────────────────────────────
  double _travelledKm = 0;
  double _extraKm = 0;
  double _extraCharge = 0;

  // ── Animation controllers ───────────────────────────────────────────────────
  late final AnimationController _summaryAnimCtrl;
  late final Animation<double> _summaryFadeAnim;
  late final AnimationController _chargeAnimCtrl;

  bool _summaryVisible = false;

  @override
  void initState() {
    super.initState();

    _summaryAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _summaryFadeAnim = CurvedAnimation(
      parent: _summaryAnimCtrl,
      curve: Curves.easeOutCubic,
    );

    _chargeAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );

    for (final ctrl in [
      _startKmController,
      _endKmController,
      _allowedKmController,
      _rateController,
    ]) {
      ctrl.addListener(_recalculate);
    }
  }

  @override
  void dispose() {
    _startKmController.dispose();
    _endKmController.dispose();
    _allowedKmController.dispose();
    _rateController.dispose();
    _summaryAnimCtrl.dispose();
    _chargeAnimCtrl.dispose();
    super.dispose();
  }

  // ── Core calculation logic ──────────────────────────────────────────────────
  void _recalculate() {
    final start = double.tryParse(_startKmController.text.trim()) ?? 0;
    final end = double.tryParse(_endKmController.text.trim()) ?? 0;
    final allowed = double.tryParse(_allowedKmController.text.trim()) ?? 0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0;

    final travelled = (end - start).clamp(0.0, double.infinity);
    final extra = (travelled - allowed).clamp(0.0, double.infinity);
    final charge = extra * rate;

    setState(() {
      _travelledKm = travelled;
      _extraKm = extra;
      _extraCharge = charge;

      final hasData = start > 0 || end > 0 || allowed > 0;
      if (hasData && !_summaryVisible) {
        _summaryVisible = true;
        _summaryAnimCtrl.forward();
      } else if (!hasData && _summaryVisible) {
        _summaryVisible = false;
        _summaryAnimCtrl.reverse();
      }
    });

    // Pulse the charge display on every change
    _chargeAnimCtrl.reverse().then((_) => _chargeAnimCtrl.forward());
  }

  void _resetAll() {
    _startKmController.clear();
    _endKmController.clear();
    _allowedKmController.clear();
    _rateController.clear();
    setState(() {
      _travelledKm = 0;
      _extraKm = 0;
      _extraCharge = 0;
      _summaryVisible = false;
    });
    _summaryAnimCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'KM Tracking',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _resetAll,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppTheme.primaryViolet,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 96, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Section: Odometer Readings ─────────────────────────────────
            _SectionHeader(
              icon: Icons.speed_rounded,
              label: 'ODOMETER READINGS',
              color: AppTheme.primaryViolet,
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _KmInputField(
                    controller: _startKmController,
                    label: 'Start KM',
                    hint: 'e.g.  45000',
                    icon: Icons.trip_origin_rounded,
                    iconColor: const Color(0xFF0F9F6E),
                  ),
                  const SizedBox(height: 16),
                  // Divider with arrow
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: AppTheme.borderLight),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentViolet,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.south_rounded,
                          size: 14,
                          color: AppTheme.primaryViolet,
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: AppTheme.borderLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _KmInputField(
                    controller: _endKmController,
                    label: 'End KM',
                    hint: 'e.g.  45350',
                    icon: Icons.flag_rounded,
                    iconColor: const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Live Travelled KM pill ─────────────────────────────────────
            _TravelledKmBadge(travelledKm: _travelledKm),
            const SizedBox(height: 20),

            // ── Section: Allowance & Rate ──────────────────────────────────
            _SectionHeader(
              icon: Icons.tune_rounded,
              label: 'ALLOWANCE & RATE',
              color: const Color(0xFF3F83F8),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _KmInputField(
                    controller: _allowedKmController,
                    label: 'Allowed KM',
                    hint: 'e.g.  300',
                    icon: Icons.route_rounded,
                    iconColor: const Color(0xFF3F83F8),
                  ),
                  const SizedBox(height: 16),
                  _KmInputField(
                    controller: _rateController,
                    label: 'Rate Per Extra KM',
                    hint: 'e.g.  7',
                    icon: Icons.currency_rupee_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    prefix: '₹',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Live Auto-Calc chips ───────────────────────────────────────
            _CalcChipsRow(
              travelledKm: _travelledKm,
              extraKm: _extraKm,
              extraCharge: _extraCharge,
              chargeAnim: _chargeAnimCtrl,
            ),
            const SizedBox(height: 24),

            // ── Animated Summary Card ─────────────────────────────────────
            FadeTransition(
              opacity: _summaryFadeAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(_summaryFadeAnim),
                child: _SummaryCard(
                  startKm: double.tryParse(_startKmController.text) ?? 0,
                  endKm: double.tryParse(_endKmController.text) ?? 0,
                  allowedKm: double.tryParse(_allowedKmController.text) ?? 0,
                  travelledKm: _travelledKm,
                  extraKm: _extraKm,
                  rate: double.tryParse(_rateController.text) ?? 0,
                  extraCharge: _extraCharge,
                ),
              ),
            ),

            if (_summaryVisible) const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ════════════════════════════════════════════════════════════════════════════════

// ── Section Header ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ── Input Field ────────────────────────────────────────────────────────────────
class _KmInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final String? prefix;

  const _KmInputField({
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Travelled KM Badge ─────────────────────────────────────────────────────────
class _TravelledKmBadge extends StatelessWidget {
  final double travelledKm;

  const _TravelledKmBadge({required this.travelledKm});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.straighten_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Travelled Distance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '= End KM − Start KM',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${travelledKm.toStringAsFixed(0)} KM',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Calculation Chips Row ──────────────────────────────────────────────────────
class _CalcChipsRow extends StatelessWidget {
  final double travelledKm;
  final double extraKm;
  final double extraCharge;
  final AnimationController chargeAnim;

  const _CalcChipsRow({
    required this.travelledKm,
    required this.extraKm,
    required this.extraCharge,
    required this.chargeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CalcChip(
            label: 'Extra KM',
            value: '${extraKm.toStringAsFixed(0)} km',
            icon: Icons.add_road_rounded,
            iconBgColor: extraKm > 0
                ? const Color(0xFFDC2626).withValues(alpha: 0.1)
                : AppTheme.accentViolet,
            iconColor: extraKm > 0
                ? const Color(0xFFDC2626)
                : AppTheme.textMuted,
            valueColor: extraKm > 0
                ? const Color(0xFFDC2626)
                : AppTheme.textSecondary,
            formula: 'Travelled − Allowed',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ScaleTransition(
            scale: chargeAnim,
            child: _CalcChip(
              label: 'Extra Charge',
              value: '₹ ${extraCharge.toStringAsFixed(0)}',
              icon: Icons.receipt_long_rounded,
              iconBgColor: extraCharge > 0
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                  : AppTheme.accentViolet,
              iconColor: extraCharge > 0
                  ? const Color(0xFFF59E0B)
                  : AppTheme.textMuted,
              valueColor: extraCharge > 0
                  ? const Color(0xFFF59E0B)
                  : AppTheme.textSecondary,
              formula: 'Extra KM × Rate',
            ),
          ),
        ),
      ],
    );
  }
}

class _CalcChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color valueColor;
  final String formula;

  const _CalcChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.valueColor,
    required this.formula,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formula,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textMuted.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Card ───────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final double startKm;
  final double endKm;
  final double allowedKm;
  final double travelledKm;
  final double extraKm;
  final double rate;
  final double extraCharge;

  const _SummaryCard({
    required this.startKm,
    required this.endKm,
    required this.allowedKm,
    required this.travelledKm,
    required this.extraKm,
    required this.rate,
    required this.extraCharge,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.summarize_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Trip Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Auto Calculated',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Rows ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Start KM',
                  value: startKm > 0 ? '${startKm.toStringAsFixed(0)} km' : '—',
                  icon: Icons.trip_origin_rounded,
                  iconColor: const Color(0xFF0F9F6E),
                ),
                _divider(),
                _SummaryRow(
                  label: 'End KM',
                  value: endKm > 0 ? '${endKm.toStringAsFixed(0)} km' : '—',
                  icon: Icons.flag_rounded,
                  iconColor: const Color(0xFFDC2626),
                ),
                _divider(),
                _SummaryRow(
                  label: 'Travelled KM',
                  value: '${travelledKm.toStringAsFixed(0)} km',
                  icon: Icons.straighten_rounded,
                  iconColor: AppTheme.primaryViolet,
                  highlight: true,
                ),
                _divider(),
                _SummaryRow(
                  label: 'Allowed KM',
                  value: allowedKm > 0 ? '${allowedKm.toStringAsFixed(0)} km' : '—',
                  icon: Icons.route_rounded,
                  iconColor: const Color(0xFF3F83F8),
                ),
                _divider(),
                _SummaryRow(
                  label: 'Extra KM',
                  value: '${extraKm.toStringAsFixed(0)} km',
                  icon: Icons.add_road_rounded,
                  iconColor: extraKm > 0
                      ? const Color(0xFFDC2626)
                      : AppTheme.textMuted,
                  valueColor: extraKm > 0
                      ? const Color(0xFFDC2626)
                      : AppTheme.textSecondary,
                ),
                _divider(),
                _SummaryRow(
                  label: 'Rate / Extra KM',
                  value: rate > 0 ? '₹ ${rate.toStringAsFixed(0)}' : '—',
                  icon: Icons.currency_rupee_rounded,
                  iconColor: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 16),

                // ── Extra Charge Hero ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: extraCharge > 0
                        ? const Color(0xFFFFF7ED)
                        : AppTheme.accentViolet,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: extraCharge > 0
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.3)
                          : AppTheme.primaryViolet.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: extraCharge > 0
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                              : AppTheme.primaryViolet.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 22,
                          color: extraCharge > 0
                              ? const Color(0xFFF59E0B)
                              : AppTheme.primaryViolet,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Extra Charge',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Extra KM × Rate Per KM',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹ ${extraCharge.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: extraCharge > 0
                              ? const Color(0xFFF59E0B)
                              : AppTheme.primaryViolet,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: AppTheme.borderLight),
      );
}

// ── Summary Row ────────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              color: highlight ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: valueColor ??
                (highlight ? AppTheme.primaryViolet : AppTheme.textPrimary),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
