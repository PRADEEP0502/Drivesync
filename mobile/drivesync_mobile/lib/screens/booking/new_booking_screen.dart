import 'package:flutter/material.dart';
import 'package:drivesync_mobile/services/vehicle_service.dart';
import 'package:drivesync_mobile/services/booking_service.dart';
import 'package:drivesync_mobile/models/booking.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class NewBookingScreen extends StatefulWidget {
  const NewBookingScreen({super.key});

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleService = VehicleService();
  final _bookingService = BookingService();

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late TextEditingController _advanceController;
  late TextEditingController _depositController;
  late TextEditingController _notesController;

  late String _selectedVehicleId;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _fromController = TextEditingController();
    _toController = TextEditingController();
    _advanceController = TextEditingController();
    _depositController = TextEditingController();
    _notesController = TextEditingController();
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

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _advanceController.dispose();
    _depositController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryViolet,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryViolet),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
        _fromController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        
        if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
          _toDate = null;
          _toController.text = '';
        }
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    if (_fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select From Date first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate!,
      firstDate: _fromDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryViolet,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryViolet),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
        _toController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_fromDate == null || _toDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select date range.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final isAvailable = _bookingService.isVehicleAvailable(
        _selectedVehicleId, 
        _fromDate!, 
        _toDate!,
      );

      if (!isAvailable) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
                SizedBox(width: 8),
                Text('Booking Conflict', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: const Text(
              'Vehicle not available for selected dates.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: AppTheme.primaryViolet, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        return;
      }

      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _nameController.text.trim(),
        customerMobile: _mobileController.text.trim(),
        vehicleId: _selectedVehicleId,
        fromDate: _fromDate!,
        toDate: _toDate!,
        advanceAmount: double.parse(_advanceController.text),
        securityDeposit: double.parse(_depositController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      final success = _bookingService.addBooking(booking);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF065F46),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = _vehicleService.vehicles;

    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'New Booking',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SECTION 1: CUSTOMER DETAILS
                _buildCardHeader('CUSTOMER INFORMATION'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Customer Name'),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Enter customer full name',
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the customer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Mobile Number'),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Enter 10-digit mobile number',
                          prefixIcon: Icon(Icons.phone_iphone_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the mobile number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION 2: RENTAL INFORMATION
                _buildCardHeader('RENTAL PARAMETERS'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Select Vehicle'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedVehicleId,
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          prefixIcon: Icon(Icons.directions_car_filled_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        items: vehicles.map((v) {
                          return DropdownMenuItem(
                            value: v.id,
                            child: Text(
                              '${v.name} (${v.registrationNumber})',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedVehicleId = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('From Date'),
                                TextFormField(
                                  controller: _fromController,
                                  readOnly: true,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                                  decoration: const InputDecoration(
                                    hintText: 'Select Date',
                                    suffixIcon: Icon(Icons.date_range_rounded, size: 18, color: AppTheme.textSecondary),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                  onTap: () => _selectFromDate(context),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('To Date'),
                                TextFormField(
                                  controller: _toController,
                                  readOnly: true,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                                  decoration: const InputDecoration(
                                    hintText: 'Select Date',
                                    suffixIcon: Icon(Icons.date_range_rounded, size: 18, color: AppTheme.textSecondary),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                  onTap: () => _selectToDate(context),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION 3: FINANCIALS & NOTES
                _buildCardHeader('FINANCIALS & COLLATERAL'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Advance Paid'),
                                TextFormField(
                                  controller: _advanceController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                                  decoration: const InputDecoration(
                                    hintText: '₹ Amount',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Sec. Deposit'),
                                TextFormField(
                                  controller: _depositController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                                  decoration: const InputDecoration(
                                    hintText: '₹ Security',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Notes / Comments'),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Enter specific rental requirements or comments',
                          prefixIcon: Icon(Icons.rate_review_outlined, size: 20, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Create Booking Button
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Create Reservation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCardHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.primaryViolet,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
