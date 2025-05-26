// lib/features/favorites/presentation/widgets/favorites_sort_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../core/favorites_state.dart';

class FavoritesSortBottomSheet extends StatelessWidget {
  final FavoritesSortOption currentSortOption;
  final Function(FavoritesSortOption) onSortSelected;

  const FavoritesSortBottomSheet({
    super.key,
    required this.currentSortOption,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.sort_rounded,
                  color: colorScheme.onSurface,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Sort Options
          ...FavoritesSortOption.values.map((option) {
            final isSelected = option == currentSortOption;
            return _buildSortOption(
              context,
              option,
              isSelected,
              colorScheme,
            );
          }).toList(),

          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context,
      FavoritesSortOption option,
      bool isSelected,
      ColorScheme colorScheme,
      ) {
    return InkWell(
      onTap: () => onSortSelected(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.1)
                    : colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            // Label
            Expanded(
              child: Text(
                option.displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ),

            // Selected indicator
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}