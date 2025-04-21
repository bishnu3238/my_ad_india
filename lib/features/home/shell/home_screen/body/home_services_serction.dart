import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:pack/ui/ui.dart';
import 'package:provider/provider.dart';
import 'package:pack/services/service.dart';
import '../../../../../core/data/model/product/service_model.dart';
import '../../../../ead_products/core/ead_product_navigator.dart';
import '../core/home_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../all_services/core/all_services_route.dart';

class HomeServicesSection extends StatelessWidget {
  const HomeServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Consumer2<ServiceStore, HomeScreenProvider>(
      builder: (context, homeViewModel, viewModel, _) {

        final services =
            homeViewModel.items
                .where(
                  (e) => '${e.categoryId}' == viewModel.state.selectedCategory,
                )
                .toList();
        return SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final service = services[index];
            // Handle "View All" card if it's the last one and we have more than 20
            bool isViewAllCard = services.length > 20 && index == 20;

            return CustomAnimatedGridItem(
              index: index,
              child: GestureDetector(
                onTap: () {
                  if (isViewAllCard) {
                    context.push(AllServicesRoute.allServices);
                  } else {
                    LogService().error('Service: ${service.fullImageUrl}');
                    context.push(
                      '${EadProductRoute.eadServices}/${service.id}/${ProductSearchBy.service.name}',
                    );
                  }
                },
                child: AnimatedServiceCard(
                  service: service,
                  width: width,
                  isViewAllCard: isViewAllCard,
                ),
              ),
            );
          }, childCount: services.length > 20 ? 21 : services.length),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            childAspectRatio: 0.85,
            mainAxisSpacing: 12.0,
          ),
        );
      },
    );
  }
}

class CustomAnimatedGridItem extends StatefulWidget {
  final Widget child;
  final int index;

  const CustomAnimatedGridItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<CustomAnimatedGridItem> createState() => _CustomAnimatedGridItemState();
}

class _CustomAnimatedGridItemState extends State<CustomAnimatedGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Stagger the animations based on index
    final delay = Duration(milliseconds: 100 * (widget.index % 3));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Create slide animation (horizontal offset)
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );

    // Create fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Create scale/flip animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
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
        // Apply the slide, fade, and scale transformations
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform(
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateY(
                      _scaleAnimation.value *
                          3.14159 *
                          (1 - _scaleAnimation.value),
                    ), // Rotate around Y axis
              alignment: Alignment.center,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class AnimatedServiceCard extends StatefulWidget {
  final ServiceModel service;
  final double width;
  final bool isViewAllCard;

  const AnimatedServiceCard({
    super.key,
    required this.service,
    required this.width,
    this.isViewAllCard = false,
  });

  @override
  State<AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<AnimatedServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _borderAnimation = Tween<double>(
      begin: 0.5,
      end: 3.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    _isHovered
                        ? Colors.blue.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color:
                  widget.isViewAllCard
                      ? Colors.blue.withValues(
                        alpha: _borderAnimation.value * 0.3,
                      )
                      : _isHovered
                      ? Theme.of(context).primaryColor.withValues(
                        alpha: _borderAnimation.value * 0.3,
                      )
                      : Colors.grey.withValues(alpha: 0.2),
              width: _borderAnimation.value,
            ),
          ),
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    widget.isViewAllCard
                        ? _buildViewAllCard()
                        : _buildServiceCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Hero(
            tag: 'service_${widget.service.id}',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageView(
                  path: widget.service.fullImageUrl,
                  // path: 'assets/images/placeholder.png',
                  width: double.infinity,
                  height: double.infinity,
                  source: ImageSource.network,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: widget.width * 0.028,
                  fontWeight: _isHovered ? FontWeight.bold : FontWeight.w600,
                  letterSpacing: 0.5,
                  color:
                      _isHovered
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                ),
                child: Text(
                  widget.service.serviceName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.grid_view_rounded, size: 36, color: Colors.blue),
        const SizedBox(height: 12),
        Text(
          "View All",
          style: TextStyle(
            fontSize: widget.width * 0.03,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Services",
          style: TextStyle(
            fontSize: widget.width * 0.025,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }
}
