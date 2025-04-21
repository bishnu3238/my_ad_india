import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:pack/resources/resources.dart';
import '../../../core/data/model/model.dart';
import '../../../routes/auth/auth_routes.dart';
import '../svg_icon_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderModel<UserModel>>(context);
    final theme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: theme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, authProvider),
            Divider(color: theme.onSurface),
            Expanded(child: _buildMenuItems(authProvider, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AuthProviderModel<UserModel> authProvider,
  ) {
    var theme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          authProvider.isAuthenticated && authProvider.user != null
              ? CircleAvatar(
                radius: 20,

                /// TODO: Replace the image with the user's profile image
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=3',
                ),
              )
              : CircleAvatar(
                radius: 24,
                child: SvgIconWidget(
                  iconPath: SvgIcons.profileIcon,
                  width: 20,
                  height: 20,
                ),
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.isAuthenticated ? 'Hello 👋' : 'Welcome!',
                  style: _customTextStyle(theme.onSurfaceVariant, 14),
                ),
                Text(
                  authProvider.isAuthenticated
                      ? authProvider.user?.name ?? 'User'
                      : 'Please Login',
                  style: _customTextStyle(
                    theme.onSurfaceVariant,
                    18,
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: theme.onSurface),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(
    AuthProviderModel<UserModel> authProvider,
    BuildContext context,
  ) {
    final theme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (authProvider.isAuthenticated)
          ListTile(
            leading: Icon(
              FontAwesomeIcons.arrowRightFromBracket,
              color: theme.error,
            ),
            title: Text(
              'Logout',
              style: TextStyle(color: theme.errorContainer),
            ),
            onTap: () async {
              await authProvider.logout();
            },
          )
        else
          Column(
            children: [
              _menuButton(
                context,
                'Login',
                () => context.push(AuthRoutes.login),
              ),
              const SizedBox(height: 10),
              _menuButton(
                context,
                'Sign Up',
                () => context.push(AuthRoutes.register),
              ),
            ],
          ),
      ],
    );
  }

  Widget _menuButton(BuildContext context, String title, VoidCallback onTap) {
    return OutlinedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size.fromWidth(double.maxFinite),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(
        title,
        style: _customTextStyle(
          Theme.of(context).colorScheme.onPrimary,
          16,
          FontWeight.w600,
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: _customTextStyle(Colors.white, 16)),
      trailing: trailing,
      onTap: () {},
    );
  }

  Widget _menuItemWithBadge({
    required IconData icon,
    required String title,
    int badgeCount = 0,
  }) {
    return _menuItem(
      icon: icon,
      title: title,
      trailing:
          badgeCount > 0
              ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.yellow,
                child: Text(
                  '$badgeCount',
                  style: _customTextStyle(Colors.black, 12),
                ),
              )
              : null,
    );
  }

  Widget _expandableClasses() {
    return ExpansionTile(
      title: Text('Classes', style: _customTextStyle(Colors.white, 16)),
      leading: const Icon(Icons.menu_book, color: Colors.white),
      collapsedIconColor: Colors.white,
      iconColor: Colors.white,
      childrenPadding: const EdgeInsets.only(left: 20),
      children: [
        _subMenuItem('Maths'),
        _subMenuItem('English', isActive: true),
        _subMenuItem('Economics'),
        _subMenuItem('Accounts'),
      ],
    );
  }

  Widget _subMenuItem(String title, {bool isActive = false}) {
    return ListTile(
      title: Text(
        title,
        style: _customTextStyle(
          isActive ? Colors.white : Colors.grey,
          14,
          isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {},
    );
  }

  static TextStyle _customTextStyle(
    Color color,
    double size, [
    FontWeight fontWeight = FontWeight.normal,
  ]) {
    return GoogleFonts.poppins(
      color: color,
      fontSize: size,
      fontWeight: fontWeight,
    );
  }
}
