import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/model.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductModel product;
  
  const ProductInfoSection({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating and reviews
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '4.6',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '12 Ratings',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                const Icon(Icons.verified, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${product.address}, ${product.cityName}, ${product.stateName}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Merchant info
            Row(
              children: [
                const Icon(Icons.business, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Dealer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  product.merchant.username,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Inquiries answered
            Row(
              children: [
                const Icon(Icons.question_answer, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(
                  '18 enquiries answered',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Business hours
            // Row(
            //   children: [
            //     const Icon(Icons.access_time, color: Colors.grey, size: 18),
            //     const SizedBox(width: 8),
            //     Text(
            //       'Open Now: until 9:00 pm',
            //       style: theme.textTheme.bodyMedium?.copyWith(
            //         color: Colors.grey.shade700,
            //       ),
            //     ),
            //     const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
            //   ],
            // ),
            
            // const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Category info
            Text(
              'Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.category,
                  size: 18,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  product.categoryTitle,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.subdirectory_arrow_right,
                  size: 18,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  product.serviceFullName,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
