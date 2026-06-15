import 'package:flutter/material.dart';
import 'package:drivesync_mobile/services/customer_service.dart';
import 'package:drivesync_mobile/models/customer.dart';
import 'package:drivesync_mobile/core/theme/app_theme.dart';
import 'package:drivesync_mobile/widgets/glass_background.dart';
import 'package:drivesync_mobile/widgets/glass_card.dart';

class AddEditCustomerScreen extends StatefulWidget {
  const AddEditCustomerScreen({super.key});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _aadhaarController;
  late TextEditingController _dlController;
  late TextEditingController _addressController;

  String? _editingCustomerId;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _aadhaarController = TextEditingController();
    _dlController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments is String) {
        _editingCustomerId = arguments;
        final customer = CustomerService().getCustomerById(_editingCustomerId!);
        if (customer != null) {
          _nameController.text = customer.fullName;
          _mobileController.text = customer.mobileNumber;
          _aadhaarController.text = customer.aadhaarNumber;
          _dlController.text = customer.drivingLicenseNumber;
          _addressController.text = customer.address;
        }
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _aadhaarController.dispose();
    _dlController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final customerService = CustomerService();

      final customer = Customer(
        id: _editingCustomerId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _nameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim(),
        drivingLicenseNumber: _dlController.text.trim().toUpperCase(),
        address: _addressController.text.trim(),
      );

      if (_editingCustomerId == null) {
        customerService.addCustomer(customer);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer added successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        customerService.updateCustomer(customer);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer profile updated successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editingCustomerId != null;

    return GlassBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Customer' : 'Add Customer',
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
                _buildCardHeader('CONTACT INFORMATION'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Full Name'),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Enter full name (e.g. Ramesh Kumar)',
                          prefixIcon: Icon(Icons.person_rounded, size: 20, color: AppTheme.textSecondary),
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

                // SECTION 2: IDENTITY DOCUMENTS
                _buildCardHeader('IDENTITY DOCUMENTS'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Aadhaar Card Number'),
                      TextFormField(
                        controller: _aadhaarController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Enter 12-digit Aadhaar number',
                          prefixIcon: Icon(Icons.badge_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the Aadhaar number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Driving License (DL) Number'),
                      TextFormField(
                        controller: _dlController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Enter driving license number',
                          prefixIcon: Icon(Icons.card_membership_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the driving license number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SECTION 3: ADDRESS
                _buildCardHeader('RESIDENTIAL ADDRESS'),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Address Details'),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Enter residential address details',
                          prefixIcon: Icon(Icons.home_rounded, size: 20, color: AppTheme.textSecondary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the residential address';
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
                  child: Text(isEdit ? 'Save Changes' : 'Add Customer'),
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
