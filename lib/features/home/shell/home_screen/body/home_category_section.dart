import 'dart:developer' as dev;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/domain/data_store/category_store.dart';
import 'package:my_ad/features/ead_products/core/ead_product_navigator.dart';
// import 'package:my_ad/utils/translation_service/easy_localize.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/service.dart';
import '../../../../../core/data/model/product/category_model.dart';
import 'package:provider/provider.dart';
import 'package:pack/ui/ui.dart';
import '../core/home_provider.dart';
import '../../../../../utils/widgets/header_section.dart';
import 'package:go_router/go_router.dart';
import '../../../../myad_categories/core/all_category_route.dart';

class HomeCategorySection extends StatelessWidget {
  const HomeCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryStore>(
      builder: (context, homeViewModel, child) {
        List<CategoryModel> categories = List.from(
          homeViewModel.items,
        ); // Safe copy

        // Find the index where name contains 'repair'
        final int targetIndex = categories.indexWhere(
          (category) => category.title.toLowerCase().contains('repair'),
        );

        if (targetIndex != -1) {
          // If found, move it to first
          final CategoryModel itemToMove = categories.removeAt(targetIndex);
          categories.insert(0, itemToMove);
        }

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(
                title: 'category',
                textStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                onTap: () => context.push(AllCategoriesRoute.allCategory),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: AnimatedCategoryList(categories: categories),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedCategoryList extends StatefulWidget {
  final List<CategoryModel> categories;

  const AnimatedCategoryList({super.key, required this.categories});

  @override
  State<AnimatedCategoryList> createState() => _AnimatedCategoryListState();
}

class _AnimatedCategoryListState extends State<AnimatedCategoryList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount:
          widget.categories.length > 6
              ? 7
              : widget.categories.length, // +1 for View All card
      itemBuilder: (context, index) {
        // View All is the last item
        // bool isViewAllCard = index == widget.categories.length;

        bool isViewAllCard = widget.categories.length > 6 && index == 6;

        return AnimatedCategoryItem(
          index: index,
          child:
              isViewAllCard
                  ? _buildViewAllCard(context)
                  : _buildCategoryCard(context, widget.categories[index]),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel category) {
    final categoryId =
        context.watch<HomeScreenProvider>().state.selectedCategory;
    return GestureDetector(
      onTap: () {
        context.read<HomeScreenProvider>().setCategory(category.id);
      },
      child: Container(
        width: ScreenUtils().getHorizontalSize(90),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: 5.symmetricHV(3),
        decoration: BoxDecoration(
          color:
              categoryId == category.id
                  ? context.colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.white70,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image with animated container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Hero(
                tag: 'category_${category.id}',
                child: ImageView(
                  source: ImageSource.network,
                  path: category.fullFavIconUrl,
                  shape: ImageShape.circle,
                  height: 52,
                  width: 52,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AutoSizeText(
              category.title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AllCategoriesRoute.allCategory),
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                size: 30,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'VIEW ALL',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCategoryItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedCategoryItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<AnimatedCategoryItem> createState() => _AnimatedCategoryItemState();
}

class _AnimatedCategoryItemState extends State<AnimatedCategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Stagger the animations based on index
    final delay = Duration(milliseconds: 100 * widget.index);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Add delay based on index
    Future.delayed(delay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
