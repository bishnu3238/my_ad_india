
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider_state/location_provider.dart';

class LocationDetector extends StatelessWidget {
  const LocationDetector({
    super.key,
    required this.theme,
    this.onTap,
    required bool showLocationSelector,
  }) : _showLocationSelector = showLocationSelector;

  final ThemeData theme;
  final VoidCallback? onTap;
  final bool _showLocationSelector;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            'Location',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Consumer<LocationProvider>(
                  builder: (context, locationProvider, child) {
                    return Text(
                      locationProvider.currentLocation,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  }
              ),
              Icon(
                _showLocationSelector
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
