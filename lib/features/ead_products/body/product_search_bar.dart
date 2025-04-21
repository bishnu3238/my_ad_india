import 'package:flutter/material.dart';
import '../core/ead_product_view_model.dart';
import 'package:provider/provider.dart';

import 'ead_product_appbar.dart';
class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({
    super.key,
    required bool showSearchBar,
   }) : _showSearchBar = showSearchBar;

  final bool _showSearchBar;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EadProductsViewModel>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showSearchBar ? null : 0,
      child:
      _showSearchBar
          ? AnimatedSearchBar(
        onSearch: viewModel.searchServices,
        searchQuery: viewModel.searchQuery,
        onClear: viewModel.clearSearch,
      )
          : const SizedBox.shrink(),
    );
  }
}
