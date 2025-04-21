import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/shell/merchant_services/core/merchant_services_provider.dart';
import 'package:pack/pack.dart';
import 'package:provider/provider.dart';

class ServiceListView extends StatelessWidget {
  final List<MerchantServiceModel> services;

  const ServiceListView({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(service: service);
          },
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  final MerchantServiceModel service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    dev.log("Service Image = ${service.servicePhotos.first}");
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service image or placeholder
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child:
                service.servicePhotos.isNotEmpty
                    ? ImageView(
                      source: ImageSource.network,
                      path: service.servicePhotos.first,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                    )
                    : _buildPlaceholderImage(),
          ),

          // Service details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusBadge(service.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${service.planRate.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Service metadata
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.location_on, service.cityName),
                    if (service.videoUrl != null &&
                        service.videoUrl!.isNotEmpty)
                      _buildInfoChip(Icons.videocam, 'Video'),
                    _buildInfoChip(
                      Icons.photo_library,
                      '${service.servicePhotos.length} Photos',
                    ),
                    _buildInfoChip(
                      Icons.update,
                      'Updates: ${service.updateLimits}',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<MerchantServicesProvider>(
                      builder: (context, provider, _) {
                        return provider.remainingUpdates > 0
                            ? TextButton.icon(
                              onPressed: () {
                                // TODO: Navigate to update service screen
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Update service functionality coming soon',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            )
                            : const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        _confirmDelete(context, service);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    final isActive = status == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MerchantServiceModel service) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Service'),
            content: Text(
              'Are you sure you want to delete "${service.serviceName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteService(context, service.id!);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteService(BuildContext context, int serviceId) async {
    final provider = context.read<MerchantServicesProvider>();
    final success = await provider.deleteService(serviceId);

    // if (context.mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         success
    //             ? 'Service deleted successfully'
    //             : 'Failed to delete service: ${provider.error?.message ?? "Unknown error"}',
    //       ),
    //       backgroundColor: success ? Colors.green : Colors.red,
    //     ),
    //   );
    // }
  }
}
