import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/all_category_view_modal.dart';

class CategorySearchBar extends StatelessWidget {
  const CategorySearchBar({
    super.key,
    required this.viewModel,
  });

  final AllCategoriesScreenProvider viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CupertinoSearchTextField(
        placeholder: 'Search Categories',
        onChanged: (value) => viewModel.searchServices(value),
        onSubmitted: (value) => viewModel.searchServices(value),
        onSuffixTap: () => viewModel.clearSearch(),
        backgroundColor: Colors.grey[200],
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}
