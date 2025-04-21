import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ead_product_view_model.dart';

class EadProductSearchbar extends StatelessWidget {
  const EadProductSearchbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Consumer<EadProductsViewModel>(
        builder: (context, viewModel, child) {
          return CupertinoSearchTextField(
            placeholder: 'Search service providers...',
            onChanged: (value) => viewModel.searchServices(value),
            onSubmitted: (value) => viewModel.searchServices(value),
            onSuffixTap: () => viewModel.clearSearch(),
            backgroundColor: Colors.grey[200],
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          );
        },
      ),
    );
  }
}
