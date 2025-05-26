// lib/features/favorites/presentation/widgets/favorites_empty_state.dart

import 'package:flutter/material.dart';
import 'package:my_ad/features/all_services/core/all_services_route.dart';
import 'package:my_ad/features/ead_products/core/ead_product_navigator.dart';

class FavoritesEmptyState extends StatefulWidget {
  const FavoritesEmptyState({super.key});

  @override
  State<FavoritesEmptyState> createState() => _FavoritesEmptyStateState();
}

class _FavoritesEmptyStateState extends State<FavoritesEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Heart Icon
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_floatAnimation.value),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 60,
                        color: colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'No Favorites Yet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Start exploring our services and tap the heart icon to save your favorites here.',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Action Button
              FilledButton.icon(
                onPressed:
                    () => AllServicesRoute.openPage(
                      context,
                      showServiceBy: ShowServicesBy.all,
                    ),
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Explore Services'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Secondary Action
              TextButton(
                onPressed:
                    () => AllServicesRoute.openPage(
                      context,
                      showServiceBy: ShowServicesBy.all,
                    ),
                child: Text(
                  'View Popular Services',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
