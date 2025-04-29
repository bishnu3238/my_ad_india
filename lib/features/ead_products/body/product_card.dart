import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/responsive_service/responsive_utils_advance.dart';
import '../../../core/data/model/model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onChat;
  final String distanceFromUser;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onCall,
    required this.onChat,
    required this.distanceFromUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Hero(
      tag: 'product-${product.id}',
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
        color: theme.colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with merchant icon and product image
                Stack(
                  children: [
                    // Product image background
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: 12.circularTop,
                          child: ImageView(
                            source: ImageSource.network,
                            path: product.fullImgUrl,
                            colorFilter: ColorFilter.mode(
                              Colors.black12,
                              BlendMode.srcOver,
                            ),
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Merchant info badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              child: Icon(
                                Icons.business_rounded,
                                color: theme.colorScheme.primary,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.merchant.companyName.length > 10
                                  ? '${product.merchant.companyName.substring(0, 10)}...'
                                  : product.merchant.companyName,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Verified icon
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.9,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.verified,
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                      ),
                    ),
                    // Distance tag
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distanceFromUser,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Product information section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // Service name
                      Text(
                        product.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenUtils().getFontSize(15),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Description
                      if (product.description.isNotEmpty)
                        Text(
                          product.description.length > 60
                              ? '${product.description.substring(0, 60)}...'
                              : product.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Price section
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          Text(
                            product.planRate.toStringAsFixed(0),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtils().getFontSize(13),
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Spacer(),
                          // Rating indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '4.5', // This would come from the product model in a real implementation
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.call, size: 16),
                              label: const Text('Call'),
                              onPressed: onCall,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                minimumSize: const Size(0, 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.chat, size: 16),
                              label: const Text('Chat'),
                              onPressed: onChat,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                                minimumSize: const Size(0, 28),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
