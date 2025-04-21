import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:my_ad/core/domain/data_store/banner_store.dart';
import 'package:provider/provider.dart';
import 'package:pack/ui/ui.dart';
import 'dart:async';
import '../../../../../core/theme/app_color_palette.dart';
import '../core/home_provider.dart';
//
// class HomeBannerSection extends StatefulWidget {
//   const HomeBannerSection({super.key});
//
//   @override
//   State<HomeBannerSection> createState() => _HomeBannerSectionState();
// }
//
// class _HomeBannerSectionState extends State<HomeBannerSection> {
//   final PageController _pageController = PageController();
//   Timer? _autoScrollTimer;
//   int _currentPage = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _startAutoScroll();
//   }
//
//   @override
//   void dispose() {
//     _autoScrollTimer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   void _startAutoScroll() {
//     _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       final viewModel = context.read<BannerStore>();
//       if (_currentPage < viewModel.items.length - 1) {
//         _currentPage++;
//       } else {
//         _currentPage = 0;
//       }
//
//       if (_pageController.hasClients) {
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 350),
//           curve: Curves.easeIn,
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<BannerStore>(
//       builder: (context, store, child) {
//         var banners = store.items;
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: 150,
//               child: Stack(
//                 children: [
//                   PageView.builder(
//                     controller: _pageController,
//                     onPageChanged: (int page) {
//                       setState(() {
//                         _currentPage = page;
//                       });
//                     },
//                     itemCount: banners.length,
//                     itemBuilder: (context, index) {
//                       final banner = banners[index];
//                       return ClipRRect(
//                         child: Stack(
//                           children: [
//                             ImageView(
//                               source: ImageSource.network,
//                               path: banner.fullImageUrl,
//                               height: 150,
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               child: Container(
//                                 color: Colors.black.withValues(alpha: 0.2),
//                                 padding: const EdgeInsets.all(10),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                   // Dot indicators
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(
//                           banners.length,
//                           (index) => DotIndicator(
//                             // key: UniqueKey(),
//                             activeColor: AppColors.accentAmber,
//                             inActiveColor: AppColors.backgroundDark,
//                             isActive: index == _currentPage,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final viewModel = context.read<BannerStore>();
      if (viewModel.items.isEmpty) return;

      if (_currentPage < viewModel.items.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerStore>(
      builder: (context, store, child) {
        var banners = store.items;

        if (_hasError) {
          return _buildErrorState();
        }

        if (banners.isEmpty) {
          return Container(
            height: 150,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No banners available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ImageView(
                          source: ImageSource.network,
                          path: banner.fullImageUrl,
                          fit: BoxFit.cover,
                        ),
                        // Optional gradient overlay for text readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // Dot indicators
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      banners.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _currentPage == index ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              _currentPage == index
                                  ? AppColors.accentAmber
                                  : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _errorMessage.isEmpty ? 'Failed to load banners' : _errorMessage,
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
