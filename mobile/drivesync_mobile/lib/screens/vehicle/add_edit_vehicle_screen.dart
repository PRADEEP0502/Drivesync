import 'package:flutter/material.dart';
import 'package:drivesync_mobile/services/vehicle_service.dart';
import 'package:drivesync_mobile/models/vehicle.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class AddEditVehicleScreen extends StatefulWidget {
  const AddEditVehicleScreen({super.key});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _regController;
  late TextEditingController _insuranceController;
  late TextEditingController _fcController;
  late TextEditingController _permitController;
  late TextEditingController _pollutionController;

  String _selectedType = 'SUV';
  String _selectedFuel = 'Petrol';
  String _selectedStatus = 'Available';
  
  String? _editingVehicleId;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _regController = TextEditingController();
    _insuranceController = TextEditingController();
    _fcController = TextEditingController();
    _permitController = TextEditingController();
    _pollutionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments is String) {
        _editingVehicleId = arguments;
        final vehicle = VehicleService().getVehicleById(_editingVehicleId!);
        if (vehicle != null) {
          _nameController.text = vehicle.name;
          _regController.text = vehicle.registrationNumber;
          _insuranceController.text = vehicle.insuranceExpiry;
          _fcController.text = vehicle.fcExpiry;
          _permitController.text = vehicle.permitExpiry;
          _pollutionController.text = vehicle.pollutionExpiry;
          _selectedType = vehicle.type;
          _selectedFuel = vehicle.fuelType;
          _selectedStatus = vehicle.status;
        }
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regController.dispose();
    _insuranceController.dispose();
    _fcController.dispose();
    _permitController.dispose();
    _pollutionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2045),
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
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final vehicleService = VehicleService();
      
      final vehicle = Vehicle(
        id: _editingVehicleId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        registrationNumber: _regController.text.trim().toUpperCase(),
        type: _selectedType,
        fuelType: _selectedFuel,
        status: _selectedStatus,
        insuranceExpiry: _insuranceController.text,
        fcExpiry: _fcController.text,
        permitExpiry: _permitController.text,
        pollutionExpiry: _pollutionController.text,
      );

      if (_editingVehicleId == null) {
        vehicleService.addVehicle(vehicle);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        vehicleService.updateVehicle(vehicle);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle updated successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editingVehicleId != null;

    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Vehicle' : 'Add Vehicle',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary),
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
                // SECTION 1: IDENTITY
                _buildCardHeader('BASIC INFORMATION'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Vehicle Name'),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Enter vehicle name (e.g. Honda City)',
                          prefixIcon: Icon(Icons.directions_car_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the vehicle name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Registration Number'),
                      TextFormField(
                        controller: _regController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Enter registration number (e.g. TN-07-CS-1234)',
                          prefixIcon: Icon(Icons.pin_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the registration number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION 2: SPECIFICATIONS
                _buildCardHeader('VEHICLE SPECIFICATIONS'),
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
                                _buildLabel('Vehicle Type'),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedType,
                                  dropdownColor: Colors.white,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  ),
                                  items: ['SUV', 'Sedan', 'Hatchback', 'MUV', 'Luxury']
                                      .map((type) => DropdownMenuItem(
                                            value: type, 
                                            child: Text(type, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedType = val);
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
                                _buildLabel('Fuel Type'),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedFuel,
                                  dropdownColor: Colors.white,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  ),
                                  items: ['Petrol', 'Diesel', 'EV', 'Hybrid']
                                      .map((fuel) => DropdownMenuItem(
                                            value: fuel, 
                                            child: Text(fuel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedFuel = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Vehicle Status'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          prefixIcon: Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        items: ['Available', 'Booked', 'Maintenance']
                            .map((status) => DropdownMenuItem(
                                  value: status, 
                                  child: Text(status, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION 3: COMPLIANCE DOCUMENTS
                _buildCardHeader('DOCUMENT EXPIRY PARAMETERS'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Insurance Expiry Date'),
                      TextFormField(
                        controller: _insuranceController,
                        readOnly: true,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Select Date',
                          suffixIcon: Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.textSecondary),
                        ),
                        onTap: () => _selectDate(context, _insuranceController),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insurance expiry date is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Fitness Certificate (FC) Expiry Date'),
                      TextFormField(
                        controller: _fcController,
                        readOnly: true,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Select Date',
                          suffixIcon: Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.textSecondary),
                        ),
                        onTap: () => _selectDate(context, _fcController),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'FC expiry date is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('National Permit Expiry Date'),
                      TextFormField(
                        controller: _permitController,
                        readOnly: true,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Select Date',
                          suffixIcon: Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.textSecondary),
                        ),
                        onTap: () => _selectDate(context, _permitController),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Permit expiry date is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Pollution (PUCC) Expiry Date'),
                      TextFormField(
                        controller: _pollutionController,
                        readOnly: true,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Select Date',
                          suffixIcon: Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.textSecondary),
                        ),
                        onTap: () => _selectDate(context, _pollutionController),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pollution expiry date is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(isEdit ? 'Save Changes' : 'Add Vehicle'),
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
