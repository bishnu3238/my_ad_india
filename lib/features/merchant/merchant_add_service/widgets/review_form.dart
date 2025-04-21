import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/features/merchant/merchant_add_service/core/merchant_add_service_provider.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/core/merchant_dashboard_route.dart';
import 'package:pack/services/snack_bar_service/notify_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReviewForm extends StatelessWidget {
  const ReviewForm({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    final provider = Provider.of<MerchantAddServiceProvider>(context);
    final canAddMoreServices = provider.canAddMoreServices;
    final planAccess = provider.planAccess;
    final isLoading = provider.isLoading;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review & Submit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              semanticsLabel: 'Review Form',
            ),
            const SizedBox(height: 16),

            // Plan Information
            _buildPlanInfoCard(context, planAccess),
            const SizedBox(height: 16),

            // Basic Info Summary
            _buildSummarySection(
              title: 'Basic Information',
              items: [
                {
                  'label': 'Category',
                  'value': provider.selectedCategory ?? 'Not selected',
                },
                {
                  'label': 'Subcategory',
                  'value': provider.selectedSubCategory ?? 'Not selected',
                },
                {
                  'label': 'Service Type',
                  'value': provider.selectedService ?? 'Not selected',
                },
                {
                  'label': 'Service Name',
                  'value': provider.serviceNameController.text,
                },
                {'label': 'Rate', 'value': '₹${provider.rateController.text}'},
              ],
            ),
            const SizedBox(height: 16),

            // Details Summary
            _buildSummarySection(
              title: 'Service Details',
              items: [
                {
                  'label': 'Description',
                  'value':
                      provider.descriptionController.text.isEmpty
                          ? 'Not provided'
                          : provider.descriptionController.text,
                },
                {
                  'label': 'Offers',
                  'value':
                      provider.offersController.text.isEmpty
                          ? 'Not provided'
                          : provider.offersController.text,
                },
                {
                  'label': 'Address',
                  'value':
                      provider.addressController.text.isEmpty
                          ? 'Not provided'
                          : provider.addressController.text,
                },
                {
                  'label': 'Show Phone Number',
                  'value': provider.showPhoneNumber ? 'Yes' : 'No',
                },
                {
                  'label': 'Enable Chat',
                  'value': provider.enableChat ? 'Yes' : 'No',
                },
              ],
            ),
            const SizedBox(height: 16),

            // Media Summary
            _buildMediaSummary(context, provider),
            const SizedBox(height: 24),

            // Submit Warning
            if (!canAddMoreServices)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      color: CupertinoColors.systemRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have reached the maximum number of services allowed by your plan. Please upgrade to add more services.',
                        style: TextStyle(color: CupertinoColors.systemRed),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(8),
                    onPressed: isLoading ? null : () => provider.previousStep(),
                    child: const Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(8),
                    onPressed:
                        isLoading
                            ? null
                            : (canAddMoreServices
                                ? () => submitService(context, provider)
                                : null),
                    child:
                        isLoading
                            ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white,
                            )
                            : Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.surface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitService(
    BuildContext context,
    MerchantAddServiceProvider provider,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    await provider.submitService(context).then((value) {
      value.fold(
        (failure) => scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: CupertinoColors.systemRed,
          ),
        ),
        (result) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(result),
              backgroundColor: CupertinoColors.activeGreen,
            ),
          );
          provider.resetForm();
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              router.go(MerchantDashboardRoute.dashboard);
            }
            router.go(MerchantDashboardRoute.dashboard);
          });
        },
      );
    });
  }

  Widget _buildPlanInfoCard(BuildContext context, planAccess) {
    if (planAccess == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CupertinoColors.systemGrey4),
        ),
        child: const Text(
          'Plan information not available',
          style: TextStyle(color: CupertinoColors.systemGrey),
        ),
      );
    }

    final validUntil =
        planAccess.validUntil != null
            ? DateFormat('dd MMM yyyy').format(planAccess.validUntil!)
            : 'Not available';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.activeBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.star_fill,
                  color: CupertinoColors.activeBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planAccess.planModel.planName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Valid until: $validUntil',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPlanMetric(
            'Services',
            '${planAccess.remainingServices} of ${planAccess.numberOfServices} remaining',
            planAccess.remainingServices / planAccess.numberOfServices,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanMetric(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: CupertinoColors.systemGrey5,
            valueColor: const AlwaysStoppedAnimation<Color>(
              CupertinoColors.activeBlue,
            ),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => _buildSummaryItem(item['label']!, item['value']!),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSummary(
    BuildContext context,
    MerchantAddServiceProvider provider,
  ) {
    final servicePhotos = provider.servicePhotos;
    final videoPath = provider.videoPath;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Media',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Photos
          _buildSummaryItem('Photos', '${servicePhotos.length} photo(s)'),
          if (servicePhotos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: servicePhotos.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(servicePhotos[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Video
          const SizedBox(height: 12),
          _buildSummaryItem(
            'Video',
            videoPath != null ? 'Video uploaded' : 'No video',
          ),
          if (videoPath != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.video_camera_solid,
                    color: CupertinoColors.activeBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      videoPath,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.activeBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
