import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pack/services/service.dart';
 import '../../../provider_state/location_provider.dart';

class AutoDetectionButton extends StatelessWidget {
  const AutoDetectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.location_on, color: Colors.red),
            label:
                locationProvider.isLoading
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Detecting...'),
                      ],
                    )
                    : const Text('Auto Detect My Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 1,
              side: const BorderSide(color: Colors.grey),
              minimumSize: const Size(double.infinity, 44),
            ),
            onPressed:
                locationProvider.isLoading
                    ? null
                    : () async {
                      await locationProvider.detectUserLocation();
                      if (locationProvider.error != null) {
                        if (context.mounted) {
                          NotifyService.toast(
                            context: context,
                            message: locationProvider.error!,
                          );
                        }
                      } else if (context.mounted) {
                        context
                            .pop(); // Go back if location was successfully detected
                      }
                    },
          ),
        );
      },
    );
  }
}
