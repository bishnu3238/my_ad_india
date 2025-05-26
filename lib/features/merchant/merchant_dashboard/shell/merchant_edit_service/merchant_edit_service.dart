import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:pack/constant/currency.dart';
import 'package:provider/provider.dart';
import '../../../../../core/data/model/merchant/merchant_service_model.dart';
import '../../../../../core/services/merchant_dashboard_service.dart';
import 'core/merchant_service_edit_controller.dart';
import 'core/merchant_service_edit_state.dart';

class MerchantServiceEditPage extends StatelessWidget {
  final MerchantServiceModel service;
  final String merchantId;

  const MerchantServiceEditPage({
    super.key,
    required this.service,
    required this.merchantId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MerchantServiceEditState(service: service),
      child: Builder(
        builder: (context) {
          final state = Provider.of<MerchantServiceEditState>(context);
          final dashboardService =
              DependencyInjector.get<MerchantDashboardService>();
          final controller = MerchantServiceEditController(
            state: state,
            dashboardService: dashboardService,
          );

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _buildModernAppBar(context, state),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.errorMessage != null)
                              _buildErrorSnackCard(state.errorMessage!)
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideY(begin: -0.3, end: 0.0),

                            const SizedBox(height: 8),

                            // Service Photo Section
                            _buildPhotoSection(context, state, controller)
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.2, end: 0.0),

                            const SizedBox(height: 32),

                            // Service Details Form
                            _buildServiceDetailsCard(state)
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideX(begin: 0.2, end: 0.0),

                            const SizedBox(height: 32),

                            // Pricing & Inventory Section
                            _buildPricingCard(state)
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.2, end: 0.0),

                            const SizedBox(height: 100), // Space for FAB
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.isLoading) _buildLoadingOverlay(),
              ],
            ),
            floatingActionButton: _buildSaveButton(context, state, controller),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }

  Widget _buildModernAppBar(
    BuildContext context,
    MerchantServiceEditState state,
  ) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A73E8),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF5F6368)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Text(
          service.id == null ? 'Add New Service' : 'Edit Service',
          style: const TextStyle(
            color: Color(0xFF202124),
            fontSize: 24,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE8EAED), width: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(
    BuildContext context,
    MerchantServiceEditState state,
    MerchantServiceEditController controller,
  ) {
    final hasPhoto = state.tempServicePhotos.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF1A73E8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Service Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (hasPhoto)
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(state.tempServicePhotos.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap:
                          () => state.removeServicePhoto(
                            state.tempServicePhotos.first,
                          ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFEA4335),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().scale(duration: 300.ms, curve: Curves.easeOut)
          else
            _buildPhotoUploadArea(context, state, controller),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadArea(
    BuildContext context,
    MerchantServiceEditState state,
    MerchantServiceEditController controller,
  ) {
    return GestureDetector(
      onTap: () => _pickImage(context, state, controller),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE8EAED),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Color(0xFF1A73E8),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Service Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Upload a high-quality image of your service',
              style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildServiceDetailsCard(MerchantServiceEditState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF34A853).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF34A853),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Service Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildModernTextField(
            label: 'Service Name',
            hint: 'Enter your service name',
            initialValue: state.service.serviceName,
            onChanged:
                (value) => state.updateService(
                  state.service.copyWith(serviceName: value),
                ),
          ),
          const SizedBox(height: 20),
          _buildModernTextField(
            label: 'Description',
            hint: 'Describe your service in detail',
            initialValue: state.service.description,
            maxLines: 4,
            onChanged:
                (value) => state.updateService(
                  state.service.copyWith(description: value),
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildModernTextField(
                  label: 'City',
                  hint: 'Service city',
                  initialValue: state.service.cityName,
                  onChanged:
                      (value) => state.updateService(
                        state.service.copyWith(cityName: value),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildModernTextField(
            label: 'Address',
            hint: 'Complete service address',
            initialValue: state.service.address,
            onChanged:
                (value) =>
                    state.updateService(state.service.copyWith(address: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(MerchantServiceEditState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBC04).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: Color(0xFFF9AB00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pricing & Inventory',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildModernNumberField(
                  label: 'Plan Rate',
                  hint: '0.00 ',
                  prefix: Currency.rupeeSymbol,
                  initialValue: state.service.planRate.toStringAsFixed(2),
                  onChanged:
                      (value) => state.updateService(
                        state.service.copyWith(
                          planRate: double.tryParse(value) ?? 0.0,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernNumberField(
                  label: 'Quantity',
                  hint: '0',
                  initialValue: state.service.quantity.toString(),
                  onChanged:
                      (value) => state.updateService(
                        state.service.copyWith(
                          quantity: int.tryParse(value) ?? 0,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required String hint,
    required String initialValue,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5F6368),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16, color: Color(0xFF202124)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9AA0A6), fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE8EAED)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE8EAED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildModernNumberField({
    required String label,
    required String hint,
    String? prefix,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5F6368),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16, color: Color(0xFF202124)),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: Color(0xFF5F6368),
              fontSize: 16,
            ),
            hintStyle: const TextStyle(color: Color(0xFF9AA0A6), fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE8EAED)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE8EAED)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildErrorSnackCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE8E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFEA4335).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEA4335), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFEA4335),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
                ),
                SizedBox(height: 16),
                Text(
                  'Updating service...',
                  style: TextStyle(fontSize: 16, color: Color(0xFF5F6368)),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildSaveButton(
    BuildContext context,
    MerchantServiceEditState state,
    MerchantServiceEditController controller,
  ) {
    if (!state.isFormValid) return const SizedBox.shrink();

    return Container(
      width: MediaQuery.of(context).size.width - 48,
      height: 56,
      child: ElevatedButton(
        onPressed:
            state.isLoading
                ? null
                : () async {
                  final result = await controller.submitService(
                    merchantId,
                    service.id == null ? 'add' : 'update',
                  );
                  result.fold((failure) => state.setError(failure.message), (
                    success,
                  ) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              service.id == null
                                  ? 'Service added successfully'
                                  : 'Service updated successfully',
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF34A853),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  });
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save_outlined, size: 20),
            const SizedBox(width: 8),
            Text(
              service.id == null ? 'Add Service' : 'Save Changes',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOut);
  }

  Future<void> _pickImage(
    BuildContext context,
    MerchantServiceEditState state,
    MerchantServiceEditController controller,
  ) async {
    if (state.tempServicePhotos.isNotEmpty) {
      // Show dialog to replace existing photo
      final shouldReplace = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Replace Photo'),
              content: const Text(
                'You can only have one service photo. Replace the existing photo?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Replace'),
                ),
              ],
            ),
      );

      if (shouldReplace != true) return;

      // Remove existing photo
      state.removeServicePhoto(state.tempServicePhotos.first);
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      final result = await controller.uploadServiceImage(
        merchantId,
        File(pickedFile.path),
      );
      result.fold(
        (failure) => state.setError(failure.message),
        (photoUrl) => state.addServicePhoto(photoUrl),
      );
    }
  }
}
