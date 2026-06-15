import 'package:flutter/material.dart';
import 'package:drivesync_mobile/services/vehicle_service.dart';
import 'package:drivesync_mobile/services/booking_service.dart';
import 'package:drivesync_mobile/models/vehicle.dart';
import 'package:drivesync_mobile/models/booking.dart';
import 'package:drivesync_mobile/core/routes/app_routes.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class VehicleCalendarScreen extends StatefulWidget {
  const VehicleCalendarScreen({super.key});

  @override
  State<VehicleCalendarScreen> createState() => _VehicleCalendarScreenState();
}

class _VehicleCalendarScreenState extends State<VehicleCalendarScreen> {
  final _vehicleService = VehicleService();
  final _bookingService = BookingService();

  late String _selectedVehicleId;
  late DateTime _focusedMonth;
  DateTime? _selectedDate;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(2026, 6, 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments is String) {
        _selectedVehicleId = arguments;
      } else {
        final vehicles = _vehicleService.vehicles;
        _selectedVehicleId = vehicles.isNotEmpty ? vehicles.first.id : '';
      }
      _isInit = false;
    }
  }

  int _daysInMonth(DateTime date) {
    var firstDayOfNextMonth = DateTime(date.year, date.month + 1, 1);
    var lastDayOfMonth = firstDayOfNextMonth.subtract(const Duration(days: 1));
    return lastDayOfMonth.day;
  }

  bool _isDayBooked(DateTime date, List<Booking> bookings) {
    final dateOnly = DateUtils.dateOnly(date);
    for (final booking in bookings) {
      final start = DateUtils.dateOnly(booking.fromDate);
      final end = DateUtils.dateOnly(booking.toDate);
      if ((dateOnly.isAfter(start) || dateOnly.isAtSameMomentAs(start)) &&
          (dateOnly.isBefore(end) || dateOnly.isAtSameMomentAs(end))) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicles = _vehicleService.vehicles;
    final selectedVehicle = _vehicleService.getVehicleById(_selectedVehicleId);

    // If inside Dashboard bottom navigation tab, it shouldn't show an independent AppBar or extendBody
    // Wait, did we check if this screen has its own Scaffold? Yes, original screen returns Scaffold.
    // Since it can be navigated to as a separate route or in a tab, returning GlassBackground with scaffold parameters is perfect.
    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Booking Calendar',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Padding to clear the floating bottom navigation bar
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.pushNamed(
              context, 
              AppRoutes.newBooking,
              arguments: _selectedVehicleId,
            );
            setState(() {});
          },
          backgroundColor: AppTheme.primaryViolet,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          label: const Text('New Booking', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      child: selectedVehicle == null
          ? const Center(child: Text('No vehicles available.'))
          : ListenableBuilder(
              listenable: _bookingService,
              builder: (context, _) {
                final bookings = _bookingService.getBookingsForVehicle(_selectedVehicleId);
                
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 160.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Vehicle Dropdown Selector
                      _buildVehicleSelector(vehicles),
                      const SizedBox(height: 20),

                      // Calendar Month Controller
                      _buildMonthController(),
                      const SizedBox(height: 12),

                      // Month View Grid Card
                      _buildCalendarGrid(bookings),
                      const SizedBox(height: 28),

                      // Booking List Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Schedule List',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryViolet.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${bookings.length} Bookings',
                              style: const TextStyle(
                                color: AppTheme.primaryViolet,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Booking Details List
                      _buildBookingDetailsList(bookings),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildVehicleSelector(List<Vehicle> vehicles) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVehicleId,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryViolet),
          items: vehicles.map((v) {
            return DropdownMenuItem(
              value: v.id,
              child: Text(
                '${v.name} (${v.registrationNumber})',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textPrimary),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedVehicleId = val;
                _selectedDate = null;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMonthController() {
    final theme = Theme.of(context);
    final monthName = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][_focusedMonth.month - 1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textSecondary, size: 26),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
            });
          },
        ),
        Text(
          '$monthName ${_focusedMonth.year}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 26),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(List<Booking> bookings) {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    final int firstWeekdayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;
    final int totalDays = _daysInMonth(_focusedMonth);
    
    final List<Widget> dayCells = [];
    
    // 1. Weekday Header cells
    for (var day in weekdays) {
      dayCells.add(
        Center(
          child: Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    
    // 2. Empty spacer cells
    for (int i = 0; i < firstWeekdayOfMonth; i++) {
      dayCells.add(const SizedBox.shrink());
    }
    
    // 3. Actual days of the month cells
    for (int day = 1; day <= totalDays; day++) {
      final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _selectedDate != null && DateUtils.isSameDay(_selectedDate!, cellDate);
      final isBooked = _isDayBooked(cellDate, bookings);
      
      Color cellBgColor;
      Color cellTextColor;
      List<BoxShadow>? boxShadows;
      
      if (isSelected) {
        cellBgColor = AppTheme.primaryViolet;
        cellTextColor = Colors.white;
        boxShadows = [
          BoxShadow(
            color: AppTheme.primaryViolet.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
      } else if (isBooked) {
        cellBgColor = const Color(0xFFFEE2E2);
        cellTextColor = const Color(0xFF991B1B);
      } else {
        cellBgColor = const Color(0xFFD1FAE5);
        cellTextColor = const Color(0xFF065F46);
      }
      
      dayCells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = cellDate;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: cellBgColor,
              shape: BoxShape.circle,
              boxShadow: boxShadows,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cellTextColor,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dayCells.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) => dayCells[index],
      ),
    );
  }

  Widget _buildBookingDetailsList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: const Center(
          child: Text(
            'No reservations scheduled for this vehicle.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final fromStr = "${booking.fromDate.day} ${_getMonthAbbr(booking.fromDate.month)}";
        final toStr = "${booking.toDate.day} ${_getMonthAbbr(booking.toDate.month)}";

        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.bookingDetails,
            arguments: booking.id,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.customerName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.date_range_rounded, size: 12, color: AppTheme.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            '$fromStr - $toStr, 2026',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${booking.advanceAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.primaryViolet,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Advance Paid',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppTheme.textMuted),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMonthAbbr(int month) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
  }
}
