import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:my_ad/core/services/merchant_dashboard_service.dart';
import 'package:my_ad/features/chat_feature/widgets/loading_indicator.dart';

import 'package:pack/constant/enums.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../../core/data/model/merchant/merchant_model.dart';
import 'core/edit_profile_provider.dart';
import 'core/edit_profile_state.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileProvider(DependencyInjector.get<MerchantDashboardService>()),
      child: const _EditProfileContent(),
    );
  }
}

class _EditProfileContent extends StatefulWidget {
  const _EditProfileContent();

  @override
  State<_EditProfileContent> createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<_EditProfileContent> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _gstinController;
  late final TextEditingController _panController;
  late final TextEditingController _addressController;
  late final TextEditingController _businessLocationController;
  late final TextEditingController _pincodeController;

  bool _showBusinessInfo = false;
  bool _showAddressInfo = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _companyNameController = TextEditingController();
    _gstinController = TextEditingController();
    _panController = TextEditingController();
    _addressController = TextEditingController();
    _businessLocationController = TextEditingController();
    _pincodeController = TextEditingController();

    // Initialize controllers once merchant data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initControllers();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _companyNameController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _addressController.dispose();
    _businessLocationController.dispose();
    _pincodeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initControllers() {
    final provider = context.read<EditProfileProvider>();
    final merchant = provider.state.merchant;

    _usernameController.text = merchant.username;
    _emailController.text = merchant.email;
    _mobileController.text = merchant.mobile;
    _companyNameController.text = merchant.companyName;
    _gstinController.text = merchant.gstin ?? '';
    _panController.text = merchant.pan ?? '';
    _addressController.text = merchant.address;
    _businessLocationController.text = merchant.businessLocation;
    _pincodeController.text = merchant.pincode;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileProvider>(
      builder: (context, provider, _) {
        final state = provider.state;

        if (state.status == EditProfileStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == EditProfileStatus.error &&
            state.merchant.username.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Profile')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage ?? 'Failed to load profile',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FilledButton(
                  onPressed: state.isDirty || state.isImageChanged
                      ? () => _saveProfile(context)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: (state.isDirty || state.isImageChanged)
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      children: [
                        _buildProfileImagePicker(context, provider),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Personal Information',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _buildTextField(
                                    controller: _usernameController,
                                    label: 'Username',
                                    prefixIcon: Icons.person,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Username is required';
                                      }
                                      return null;
                                    },
                                    onChanged: provider.updateUsername,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    prefixIcon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return null;
                                      }
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(value)) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                    onChanged: provider.updateEmail,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _mobileController,
                                    label: 'Mobile Number',
                                    prefixIcon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Mobile number is required';
                                      }
                                      return null;
                                    },
                                    onChanged: provider.updateMobile,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDropdownField(
                                    label: 'Gender',
                                    value: provider.state.merchant.gender,
                                    items: Gender.values
                                        .map(
                                          (gender) => DropdownMenuItem(
                                            value: gender,
                                            child: Text(
                                              gender.name.substring(0, 1).toUpperCase() +
                                                  gender.name.substring(1),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (Gender? value) {
                                      if (value != null) {
                                        provider.updateGender(value);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDropdownField(
                                    label: 'Mobile Status',
                                    value: provider.state.merchant.mobileStatus,
                                    items: MobileStatus.values
                                        .map(
                                          (status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(
                                              status.name.substring(0, 1).toUpperCase() +
                                                  status.name.substring(1),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (MobileStatus? value) {
                                      if (value != null) {
                                        provider.updateMobileStatus(value);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  ExpansionPanelList(
                                    elevation: 0,
                                    expandedHeaderPadding: EdgeInsets.zero,
                                    expansionCallback: (panelIndex, isExpanded) {
                                      setState(() {
                                        if (panelIndex == 0) {
                                          _showBusinessInfo = !_showBusinessInfo;
                                        } else if (panelIndex == 1) {
                                          _showAddressInfo = !_showAddressInfo;
                                        }
                                      });
                                    },
                                    children: [
                                      ExpansionPanel(
                                        canTapOnHeader: true,
                                        isExpanded: _showBusinessInfo,
                                        headerBuilder: (context, isExpanded) => ListTile(
                                          title: Text(
                                            'Business Information',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        body: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                          child: Column(
                                            children: [
                                              _buildTextField(
                                                controller: _companyNameController,
                                                label: 'Company Name',
                                                prefixIcon: Icons.business,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Company name is required';
                                                  }
                                                  return null;
                                                },
                                                onChanged: provider.updateCompanyName,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildTextField(
                                                controller: _gstinController,
                                                label: 'GSTIN (Optional)',
                                                prefixIcon: Icons.receipt,
                                                onChanged: provider.updateGstin,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildTextField(
                                                controller: _panController,
                                                label: 'PAN (Optional)',
                                                prefixIcon: Icons.credit_card,
                                                onChanged: provider.updatePan,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildYearPicker(
                                                context: context,
                                                label: 'Business Start Year',
                                                selectedYear: provider.state.merchant.businessStartYear,
                                                onYearSelected: provider.updateBusinessStartYear,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ExpansionPanel(
                                        canTapOnHeader: true,
                                        isExpanded: _showAddressInfo,
                                        headerBuilder: (context, isExpanded) => ListTile(
                                          title: Text(
                                            'Address Information',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        body: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                          child: Column(
                                            children: [
                                              _buildTextField(
                                                controller: _addressController,
                                                label: 'Address',
                                                prefixIcon: Icons.location_on,
                                                maxLines: 3,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Address is required';
                                                  }
                                                  return null;
                                                },
                                                onChanged: provider.updateAddress,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildTextField(
                                                controller: _businessLocationController,
                                                label: 'Business Location',
                                                prefixIcon: Icons.business_center,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Business location is required';
                                                  }
                                                  return null;
                                                },
                                                onChanged: provider.updateBusinessLocation,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildTextField(
                                                controller: _pincodeController,
                                                label: 'Pincode',
                                                prefixIcon: Icons.pin_drop,
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly,
                                                  LengthLimitingTextInputFormatter(6),
                                                ],
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Pincode is required';
                                                  }
                                                  if (value.length != 6) {
                                                    return 'Enter a valid 6-digit pincode';
                                                  }
                                                  return null;
                                                },
                                                onChanged: provider.updatePincode,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: provider.state.isDirty || provider.state.isImageChanged
                                              ? () => _saveProfile(context)
                                              : null,
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size.fromHeight(48),
                                            backgroundColor: (provider.state.isDirty || provider.state.isImageChanged)
                                                ? Theme.of(context).colorScheme.primary
                                                : Colors.grey.shade300,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Save Changes'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _cancelEdit(context),
                                          style: OutlinedButton.styleFrom(
                                            minimumSize: const Size.fromHeight(48),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state.isSubmitting)
                const LoadingIndicator(message: 'Saving profile...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImagePicker(
    BuildContext context,
    EditProfileProvider provider,
  ) {
    final imageProvider = provider.getProfileImage();

    return Center(
      child: Stack(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              image:
                  imageProvider != null
                      ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                      : null,
            ),
            child:
                imageProvider == null
                    ? const Icon(Icons.person, size: 60, color: Colors.blueGrey)
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: provider.pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        prefixIcon: Icon(prefixIcon),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      isExpanded: true,
    );
  }

  Widget _buildYearPicker({
    required BuildContext context,
    required String label,
    required int selectedYear,
    required Function(int) onYearSelected,
  }) {
    final currentYear = DateTime.now().year;
    final startYear = currentYear - 100;

    return InkWell(
      onTap: () async {
        final initialDate = DateTime(selectedYear);
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(startYear),
          lastDate: DateTime(currentYear),
          initialDatePickerMode: DatePickerMode.year,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          helpText: 'Select Business Start Year',
        );

        if (pickedDate != null) {
          onYearSelected(pickedDate.year);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        child: Text(
          selectedYear.toString(),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _saveProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      // Show error if form is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix errors before saving.')),
      );
      return;
    }
    final provider = context.read<EditProfileProvider>();
    await provider.saveProfile();
    if (provider.state.status == EditProfileStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.of(context).pop(true);
    } else if (provider.state.status == EditProfileStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.state.errorMessage ?? 'Failed to update profile',
          ),
        ),
      );
    }
  }

  void _cancelEdit(BuildContext context) {
    final provider = context.read<EditProfileProvider>();
    provider.resetForm();
    Navigator.of(context).pop(false);
  }
}
