import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:my_ad/utils/translation_service/easy_localize_extensions.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/pack.dart';
import 'package:pack/services/service.dart';
import '../../../core/constant/image.dart';
import '../../../core/constant/trasnlation_key.dart';
import '../../../core/data/model/model.dart';
import '../../../provider_state/theme_provider.dart';
import '../../merchant/core/merchant_auth_provider.dart';
import '../../merchant/core/merchant_navigation.dart';
import 'package:provider/provider.dart';
import '../../../../provider_state/scroll_visibility_provider.dart';
import '../../../utils/widgets/svg_icon_widget.dart';

class HomeBottomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final bool showLabels;
  const HomeBottomNavigationBar({
    super.key,
    required this.navigationShell,
    this.showLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final isDarkMode = context.read<AppThemeProvider>().isDarkMode;
    return Consumer3<
      ScrollVisibilityProvider,
      MerchantAuthProvider,
      AuthProviderModel<UserModel>
    >(
      builder: (
        context,
        scrollProvider,
        merchantProvider,
        authProvider,
        child,
      ) {
        return AnimatedSlide(
          offset: scrollProvider.isVisible ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child:
              scrollProvider.isVisible
                  ? BottomNavigationBar(
                    currentIndex: navigationShell.currentIndex,
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    backgroundColor: Colors.white,
                    selectedItemColor: Colors.black,
                    unselectedItemColor: Colors.grey,
                    onTap: (index) => _onItemTapped(context, index),
                    type: BottomNavigationBarType.fixed,
                    items: [
                      BottomNavigationBarItem(
                        icon: SvgIconWidget(
                          iconPath:
                              navigationShell.currentIndex == 0
                                  ? SvgIcons.homeSmileFullIcon
                                  : SvgIcons.homeIcon,
                        ),

                        label: context.tr(TranslationKey.home.key),
                      ),
                      BottomNavigationBarItem(
                        icon: SvgIconWidget(
                          iconPath:
                              navigationShell.currentIndex == 1
                                  ? SvgIcons.searchBoldIcon
                                  : SvgIcons.searchIcon,
                        ),

                        label: context.tr(TranslationKey.search.key),
                      ),
                      BottomNavigationBarItem(
                        icon: Container(
                          decoration: BoxDecoration(
                            color: theme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    isDarkMode
                                        ? Colors.tealAccent.shade700
                                        : Colors.tealAccent.withValues(
                                          alpha: 0.3,
                                        ),
                                blurRadius: 3,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(1), // Space for inner content
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.onPrimary.withValues(alpha: 0.8),
                                  theme.inversePrimary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),

                              shape: BoxShape.circle, // Fully rounded
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primary.withValues(alpha: 0.4),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: ImageView(
                                margin: edgeInsets,
                                source: ImageSource.asset,
                                path: AppImage.logo,
                                height: kBottomNavigationBarHeight - 15,
                              ),
                            ),
                          ),
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: SvgIconWidget(
                          iconPath:
                              navigationShell.currentIndex == 3
                                  ? SvgIcons.categoryFullIcon
                                  : SvgIcons.categoryIcon,
                        ),

                        label: context.tr(TranslationKey.category.key),
                      ),
                      BottomNavigationBarItem(
                        icon: SvgIconWidget(
                          iconPath:
                              navigationShell.currentIndex == 4
                                  ? SvgIcons.settingFullGear
                                  : SvgIcons.settingIcon,
                        ),

                        label: context.tr(TranslationKey.settings.key),
                      ),
                    ],
                  )
                  : SizedBox.shrink(),
        );
      },
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == 2) {
      _onPostAdTapped(context);
    } else {
      navigationShell.goBranch(index);
    }
  }

  void _onPostAdTapped(BuildContext context) {
    context.push(MerchantRoute.merchantLogin);
  }
}
