import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';
import 'package:my_ad/features/merchant/merchant_dashboard/core/merchant_dashboard_shell_provider.dart';
import 'package:pack/services/service.dart';
import 'package:provider/provider.dart';

// import '../../../../utils/translation_service/easy_localize.dart';
import '../../../terms/core/terms_and_conditions_route.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late EasyLocalize _easyLocalize;
late MerchantDashboardShellProvider _dashboardShellProvider;
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    _easyLocalize = EasyLocalize();
    _dashboardShellProvider = context.read<MerchantDashboardShellProvider>();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            _buildQuickActions(),
            _buildBusinessPromotion(),
            _buildLanguageSelector(),
            const Divider(height: 1),
            _buildSettingsSection(),
            const Divider(height: 1),
            _buildInfoSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      color: Colors.white,
      child: Consumer<MerchantDashboardStore>(
        builder: (context, store, _) {
          final merchant = store.entity?.merchantData.merchant;
          return Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              ListTile(
                leading: _buildProfileImage(),
                title: Text(
                  merchant!.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant.email,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {},
                      child: const Text(
                        "View Activity",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange),
      child: Consumer<MerchantDashboardStore>(
        builder: (context, store, _) {
          final merchant = store.entity?.merchantData.merchant;
          return Center(
            child:
                merchant!.companyLogo != null &&
                        merchant.companyLogo!.isNotEmpty
                    ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: merchant.companyLogo!,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        placeholder:
                            (context, url) => const CircularProgressIndicator(),
                        errorWidget:
                            (context, url, error) => Text(
                              merchant.username.isNotEmpty
                                  ? merchant.username[0].toUpperCase()
                                  : "E",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    )
                    : Text(
                      merchant.username.isNotEmpty
                          ? merchant.username[0].toUpperCase()
                          : "E",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildActionButton(
          //         icon: Icons.favorite_border,
          //         label: "Favourites",
          //         onTap: () {},
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _buildActionButton(
          //         icon: Icons.credit_card,
          //         label: "Transactions",
          //         onTap: () {},
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.star_border,
                  label: "Rate Us",
                  onTap: () {
                    Navigator.pop(context);
                    context.push(TermsRoute.rateUs);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.headset_mic_outlined,
                  label: "Help",
                  onTap: () {
                    Navigator.pop(context);
                    context.push(TermsRoute.help);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessPromotion() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          "List your Business for ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Free",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text("AD"),
          ),
          title: const Text(
            "Advertise & Grow your Business",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            "App and User Setting",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildLanguageButton("English", const Locale('en', 'US'), true),
              _buildLanguageButton("हिंदी", const Locale('hi', 'IN'), false),
              _buildLanguageButton("தமிழ்", const Locale('ta', 'IN'), false),
              _buildLanguageButton("ಕನ್ನಡ", const Locale('kn', 'IN'), false),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLanguageButton(String label, Locale locale, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () async {
          try {
            await _easyLocalize.setLocale(locale);
            setState(() {});
          } catch (e) {
            dev.log("Error changing language: $e");
          }
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildMenuItem(icon: Icons.settings, title: "Settings", onTap: () {}),
        _buildMenuItem(
          icon: Icons.chat_bubble_outline,
          title: "App Feedback",
          onTap: () {
            Navigator.pop(context);
            context.push(TermsRoute.feedback);
          },
        ),
        _buildMenuItem(icon: Icons.share, title: "Share App", onTap: () {}),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            "More Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: "Privacy Policy",
          onTap: () {
            Navigator.pop(context);
            context.push(TermsRoute.appSupport);
          },
        ),
        _buildMenuItem(
          icon: Icons.description_outlined,
          title: "Terms of Use",
          onTap: () {
            Navigator.pop(context);
            context.push(TermsRoute.termsAndConditions);
          },
        ),
        // _buildMenuItem(
        //   icon: Icons.people_outline,
        //   title: "Investor Relations",
        //   onTap: () {},
        // ),
        _buildMenuItem(
          icon: Icons.lightbulb_outline,
          title: "What's New",
          onTap: () {
            Navigator.pop(context);
            context.push(TermsRoute.whatsNew);
          },
        ),
        _buildMenuItem(icon: Icons.more_horiz, title: "About Us", onTap: () {
          Navigator.pop(context);
          context.push(TermsRoute.aboutUs);
        }),
        _buildMenuItem(
          icon: Icons.logout,
          title: "Logout",
          textColor: theme.colorScheme.error,
          iconColor: theme.colorScheme.error,
          onTap: () => _dashboardShellProvider.onLogout(context),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: textColor ?? Colors.black87),
      ),
      trailing: title != "Logout" ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}
