import 'package:flutter/material.dart';
import 'package:pack/pack.dart';
import '../core/ead_product_navigator.dart';
import '../core/ead_product_view_model.dart';
import 'package:provider/provider.dart';

class ProductTitle extends StatelessWidget {
  const ProductTitle({super.key, });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: Consumer<EadProductsViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      viewModel.title,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (viewModel.products.isNotEmpty)
                    Text(
                      '${viewModel.products.length} ${viewModel.products.length == 1 ? 'product' : 'products'}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.secondary,
                      ),
                    ),
                ],
              ),
              if (viewModel.type == ProductSearchBy.search) ...[
                const SizedBox(height: 4),
                Text(
                  'Showing results for "${viewModel.searchQuery}"',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
