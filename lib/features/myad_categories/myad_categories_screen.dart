import 'dart:developer' as dev;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_ad/core/constant/trasnlation_key.dart';
// import 'package:my_ad/utils/translation_service/easy_localize_extensions.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';

import 'body/category_body.dart';
import 'body/category_search_bar.dart';
import 'core/all_category_view_modal.dart';

// Main All Categories Page
class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AllCategoriesScreenProvider>().clearSearch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AllCategoriesScreenProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CupertinoNavigationBar(
        middle: AutoSizeText(context.tr(TranslationKey.allCategories.key)),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      body: Column(
        children: [
          // Cupertino Search Bar
          CategorySearchBar(viewModel: viewModel),

          // Main Content
          Expanded(child: CategoryBody(viewModel: viewModel)),
        ],
      ),
    );
  }
}
