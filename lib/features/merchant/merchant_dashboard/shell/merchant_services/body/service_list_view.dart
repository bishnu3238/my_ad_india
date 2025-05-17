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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
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
    final isActive = service.status == 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 6,
      shadowColor: Colors.blueGrey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service image or placeholder
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: service.servicePhotos.isNotEmpty
                ? ImageView(
                    source: ImageSource.network,
                    path: service.servicePhotos.first,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : _buildPlaceholderImage(),
          ),

          // Service details
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.serviceName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildStatusBadge(service.status),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 22),
                      onSelected: (value) {
                        if (value == 'activate' || value == 'deactivate') {
                          // TODO: Implement activate/inactivate logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value == 'activate'
                                    ? 'Service activated'
                                    : 'Service inactivated',
                              ),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: isActive ? 'deactivate' : 'activate',
                          child: Row(
                            children: [
                              Icon(
                                isActive ? Icons.visibility_off : Icons.visibility,
                                color: isActive ? Colors.red : Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(isActive ? 'Inactivate' : 'Activate'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${service.planRate.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Service metadata
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.location_on, service.cityName),
                    if (service.videoUrl != null && service.videoUrl!.isNotEmpty)
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

                const SizedBox(height: 18),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<MerchantServicesProvider>(
                      builder: (context, provider, _) {
                        return provider.remainingUpdates > 0
                            ? OutlinedButton.icon(
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
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blueAccent,
                                  side: const BorderSide(color: Colors.blueAccent),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        _confirmDelete(context, service);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
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
      height: 170,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image, size: 60, color: Colors.grey),
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    final isActive = status == 1;
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.blueGrey),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MerchantServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
