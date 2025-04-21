// auth_drawer_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'drawer_provider.dart';
import 'custom_drawer.dart';

class AuthDrawerWrapper extends StatelessWidget {
  final Widget child;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final PreferredSizeWidget? appBar;

  const AuthDrawerWrapper({
    super.key,
    required this.child,
    this.scaffoldKey,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawerProvider(),
      child: Consumer<DrawerProvider>(
        builder: (context, drawerProvider, _) {
          return Scaffold(
            key: scaffoldKey,
            appBar: appBar,
            drawer: const CustomDrawer(),
            body: Stack(
              children: [
                child,
                if (drawerProvider.isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Extension method to access drawer provider from anywhere
extension DrawerContextExtension on BuildContext {
  DrawerProvider get drawerProvider =>
      Provider.of<DrawerProvider>(this, listen: false);

  void refreshUserAuthState() {
    drawerProvider.refreshUserData();
  }

  void openDrawer() {
    Scaffold.of(this).openDrawer();
  }
}
