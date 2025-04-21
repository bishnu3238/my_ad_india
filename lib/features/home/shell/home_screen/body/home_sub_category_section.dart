import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import '../core/home_provider.dart';
import 'package:provider/provider.dart';

class HomeSubCategorySection extends StatelessWidget {
  const HomeSubCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubCategoryStore>(
      builder: (ctx, homeViewModel, _) {
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverGrid.builder(
            itemCount:
                homeViewModel.items.length > 10
                    ? 10
                    : homeViewModel.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.69,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            itemBuilder: (ctx, index) {
              var subCategory = homeViewModel.items[index];
              return SizedBox(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        GoRouter.of(
                          context,
                        ).go('/sub-category/${subCategory.id}');
                      },
                      child: Image.network(
                        subCategory.fullImageUrl,
                        height: 50,
                        width: 50,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subCategory.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
