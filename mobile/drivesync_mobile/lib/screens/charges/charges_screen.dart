import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────

class _TollEntry {
  final TextEditingController amountCtrl;
  _TollEntry() : amountCtrl = TextEditingController();
  void dispose() => amountCtrl.dispose();
  double get amount => double.tryParse(amountCtrl.text.trim()) ?? 0;
}

class _FastagEntry {
  final TextEditingController amountCtrl;
  _FastagEntry() : amountCtrl = TextEditingController();
  void dispose() => amountCtrl.dispose();
  double get amount => double.tryParse(amountCtrl.text.trim()) ?? 0;
}

enum FineType {
  seatBelt('Seat Belt Fine', Icons.airline_seat_recline_normal_rounded),
  speed('Speed Fine', Icons.speed_rounded),
  signal('Signal Fine', Icons.traffic_rounded),
  parking('Parking Fine', Icons.local_parking_rounded),
  other('Other Fine', Icons.gavel_rounded);

  final String label;
  final IconData icon;
  const FineType(this.label, this.icon);
}

class _FineEntry {
  FineType type;
  final TextEditingController amountCtrl;
  final TextEditingController notesCtrl;

  _FineEntry()
      : type = FineType.seatBelt,
        amountCtrl = TextEditingController(),
        notesCtrl = TextEditingController();

  void dispose() {
    amountCtrl.dispose();
    notesCtrl.dispose();
  }

  double get amount => double.tryParse(amountCtrl.text.trim()) ?? 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────

class ChargesScreen extends StatefulWidget {
  const ChargesScreen({super.key});

  @override
  State<ChargesScreen> createState() => _ChargesScreenState();
}

class _ChargesScreenState extends State<ChargesScreen>
    with SingleTickerProviderStateMixin {
  // ── Entry Lists ─────────────────────────────────────────────────────────────
  final List<_TollEntry> _tollEntries = [_TollEntry()];
  final List<_FastagEntry> _fastagEntries = [_FastagEntry()];
  final List<_FineEntry> _fineEntries = [_FineEntry()];

  // ── Animation ───────────────────────────────────────────────────────────────
  late final AnimationController _summaryAnimCtrl;
  late final Animation<double> _summaryAnim;

  // ── Totals ──────────────────────────────────────────────────────────────────
  double get _totalToll =>
      _tollEntries.fold(0, (sum, e) => sum + e.amount);
  double get _totalFastag =>
      _fastagEntries.fold(0, (sum, e) => sum + e.amount);
  double get _totalFine =>
      _fineEntries.fold(0, (sum, e) => sum + e.amount);
  double get _grandTotal => _totalToll + _totalFastag + _totalFine;

  @override
  void initState() {
    super.initState();
    _summaryAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _summaryAnim = CurvedAnimation(
      parent: _summaryAnimCtrl,
      curve: Curves.easeOutCubic,
    );
    // listen on all initial controllers
    _listenAll();
  }

  void _listenAll() {
    for (final e in _tollEntries) {
      e.amountCtrl.addListener(_onChanged);
    }
    for (final e in _fastagEntries) {
      e.amountCtrl.addListener(_onChanged);
    }
    for (final e in _fineEntries) {
      e.amountCtrl.addListener(_onChanged);
    }
  }

  void _onChanged() {
    setState(() {});
    if (_grandTotal > 0) {
      _summaryAnimCtrl.forward();
    } else {
      _summaryAnimCtrl.reverse();
    }
  }

  @override
  void dispose() {
    for (final e in _tollEntries) { e.dispose(); }
    for (final e in _fastagEntries) { e.dispose(); }
    for (final e in _fineEntries) { e.dispose(); }
    _summaryAnimCtrl.dispose();
    super.dispose();
  }

  // ── Add / Remove helpers ────────────────────────────────────────────────────

  void _addToll() {
    final entry = _TollEntry();
    entry.amountCtrl.addListener(_onChanged);
    setState(() => _tollEntries.add(entry));
  }

  void _removeToll(int index) {
    _tollEntries[index].dispose();
    setState(() => _tollEntries.removeAt(index));
    _onChanged();
  }

  void _addFastag() {
    final entry = _FastagEntry();
    entry.amountCtrl.addListener(_onChanged);
    setState(() => _fastagEntries.add(entry));
  }

  void _removeFastag(int index) {
    _fastagEntries[index].dispose();
    setState(() => _fastagEntries.removeAt(index));
    _onChanged();
  }

  void _addFine() {
    final entry = _FineEntry();
    entry.amountCtrl.addListener(_onChanged);
    setState(() => _fineEntries.add(entry));
  }

  void _removeFine(int index) {
    _fineEntries[index].dispose();
    setState(() => _fineEntries.removeAt(index));
    _onChanged();
  }

  void _resetAll() {
    setState(() {
      for (final e in _tollEntries) { e.dispose(); }
      for (final e in _fastagEntries) { e.dispose(); }
      for (final e in _fineEntries) { e.dispose(); }
      _tollEntries
        ..clear()
        ..add(_TollEntry()..amountCtrl.addListener(_onChanged));
      _fastagEntries
        ..clear()
        ..add(_FastagEntry()..amountCtrl.addListener(_onChanged));
      _fineEntries
        ..clear()
        ..add(_FineEntry()..amountCtrl.addListener(_onChanged));
    });
    _summaryAnimCtrl.reverse();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Charges',
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
        padding: const EdgeInsets.fromLTRB(20, 96, 20, 48),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. TOLL CHARGES ─────────────────────────────────────────────
            _buildTollSection(),
            const SizedBox(height: 20),

            // ── 2. FASTAG CHARGES ────────────────────────────────────────────
            _buildFastagSection(),
            const SizedBox(height: 20),

            // ── 3. FINE CHARGES ──────────────────────────────────────────────
            _buildFineSection(),
            const SizedBox(height: 28),

            // ── ANIMATED SUMMARY CARD ────────────────────────────────────────
            FadeTransition(
              opacity: _summaryAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(_summaryAnim),
                child: _buildSummaryCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Section builders
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTollSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row
        _SectionHeader(
          icon: Icons.toll_rounded,
          label: 'TOLL CHARGES',
          color: const Color(0xFF3F83F8),
          totalLabel: 'Total Toll',
          total: _totalToll,
          totalColor: const Color(0xFF3F83F8),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Entry rows
              ...List.generate(_tollEntries.length, (i) {
                final isLast = i == _tollEntries.length - 1;
                return Column(
                  children: [
                    _TollFastagRow(
                      index: i + 1,
                      controller: _tollEntries[i].amountCtrl,
                      icon: Icons.toll_rounded,
                      iconColor: const Color(0xFF3F83F8),
                      hint: 'e.g.  80',
                      canRemove: _tollEntries.length > 1,
                      onRemove: () => _removeToll(i),
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 14),
              // Add button
              _AddEntryButton(
                label: '+ Add Another Toll',
                color: const Color(0xFF3F83F8),
                onTap: _addToll,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFastagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.contactless_rounded,
          label: 'FASTAG CHARGES',
          color: const Color(0xFF0F9F6E),
          totalLabel: 'Total FASTag',
          total: _totalFastag,
          totalColor: const Color(0xFF0F9F6E),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              ...List.generate(_fastagEntries.length, (i) {
                final isLast = i == _fastagEntries.length - 1;
                return Column(
                  children: [
                    _TollFastagRow(
                      index: i + 1,
                      controller: _fastagEntries[i].amountCtrl,
                      icon: Icons.contactless_rounded,
                      iconColor: const Color(0xFF0F9F6E),
                      hint: 'e.g.  150',
                      canRemove: _fastagEntries.length > 1,
                      onRemove: () => _removeFastag(i),
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 14),
              _AddEntryButton(
                label: '+ Add Another FASTag',
                color: const Color(0xFF0F9F6E),
                onTap: _addFastag,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.gavel_rounded,
          label: 'FINE CHARGES',
          color: const Color(0xFFDC2626),
          totalLabel: 'Total Fines',
          total: _totalFine,
          totalColor: const Color(0xFFDC2626),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              ...List.generate(_fineEntries.length, (i) {
                final entry = _fineEntries[i];
                final isLast = i == _fineEntries.length - 1;
                return Column(
                  children: [
                    _FineEntryRow(
                      index: i + 1,
                      entry: entry,
                      canRemove: _fineEntries.length > 1,
                      onRemove: () => _removeFine(i),
                      onTypeChanged: (type) =>
                          setState(() => entry.type = type),
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 14),
              _AddEntryButton(
                label: '+ Add Another Fine',
                color: const Color(0xFFDC2626),
                onTap: _addFine,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Summary card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Gradient header
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
                  child: const Icon(Icons.receipt_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Charges Summary',
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
                    'Auto Total',
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

          // Rows
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SummaryRow(
                  icon: Icons.toll_rounded,
                  iconColor: const Color(0xFF3F83F8),
                  label: 'Total Toll Charges',
                  amount: _totalToll,
                  amountColor: const Color(0xFF3F83F8),
                ),
                _divider(),
                _SummaryRow(
                  icon: Icons.contactless_rounded,
                  iconColor: const Color(0xFF0F9F6E),
                  label: 'Total FASTag Charges',
                  amount: _totalFastag,
                  amountColor: const Color(0xFF0F9F6E),
                ),
                _divider(),
                _SummaryRow(
                  icon: Icons.gavel_rounded,
                  iconColor: const Color(0xFFDC2626),
                  label: 'Total Fine Charges',
                  amount: _totalFine,
                  amountColor: const Color(0xFFDC2626),
                ),
                const SizedBox(height: 16),

                // Grand Total hero
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryViolet.withValues(alpha: 0.08),
                        AppTheme.secondaryViolet.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryViolet.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryViolet.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 22,
                          color: AppTheme.primaryViolet,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grand Total Charges',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Toll + FASTag + Fines',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹ ${_grandTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          color: AppTheme.primaryViolet,
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

// ═══════════════════════════════════════════════════════════════════════════════
// Reusable sub-widgets
// ═══════════════════════════════════════════════════════════════════════════════

// ── Section Header (label + live total chip) ────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String totalLabel;
  final double total;
  final Color totalColor;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
    required this.totalLabel,
    required this.total,
    required this.totalColor,
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
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ),
        // Live total pill
        if (total > 0)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: totalColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: totalColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Text(
              '₹ ${total.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: totalColor,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Toll / FASTag entry row ─────────────────────────────────────────────────

class _TollFastagRow extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final String hint;
  final bool canRemove;
  final VoidCallback onRemove;

  const _TollFastagRow({
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
        // Index badge
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: iconColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                  prefixText: '₹  ',
                  prefixStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Remove button
        if (canRemove)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_rounded,
                  color: Color(0xFFDC2626), size: 22),
              tooltip: 'Remove',
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}

// ── Fine entry row (dropdown + amount + notes) ──────────────────────────────

class _FineEntryRow extends StatelessWidget {
  final int index;
  final _FineEntry entry;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<FineType> onTypeChanged;

  const _FineEntryRow({
    required this.index,
    required this.entry,
    required this.canRemove,
    required this.onRemove,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: index + label + remove
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Fine Entry',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            if (canRemove)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.remove_circle_rounded,
                    color: Color(0xFFDC2626), size: 22),
                tooltip: 'Remove Fine',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Fine Type Dropdown
        const Text(
          'Fine Type',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderLight, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<FineType>(
              value: entry.type,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textSecondary),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              items: FineType.values.map((type) {
                return DropdownMenuItem<FineType>(
                  value: type,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(type.icon,
                            size: 14, color: const Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 10),
                      Text(type.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onTypeChanged(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Amount field
        const Text(
          'Fine Amount',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: entry.amountCtrl,
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
            hintText: 'e.g.  500',
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.gavel_rounded,
                  size: 16, color: Color(0xFFDC2626)),
            ),
            prefixText: '₹  ',
            prefixStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Notes field
        const Text(
          'Notes  (optional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: entry.notesCtrl,
          maxLines: 2,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Add any additional details...',
            prefixIcon: Icon(Icons.notes_rounded,
                size: 20, color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }
}

// ── Add Entry Button ────────────────────────────────────────────────────────

class _AddEntryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AddEntryButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.22),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_rounded, size: 17, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary row ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double amount;
  final Color amountColor;

  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.amountColor,
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          '₹ ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: amount > 0 ? amountColor : AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
