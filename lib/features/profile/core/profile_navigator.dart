import 'package:go_router/go_router.dart';

import '../edit_profile_screen.dart';
import '../profile_page.dart';

class ProfileNavigator {
  static const String profile = '/profile';
  static const String _editProfile = '/edit-profile';
  static const String editProfile = '/profile/edit-profile';
  static GoRoute page() {
    return GoRoute(
      path: profile,
      builder: (ctx, state) => PersonalDetailsScreen(),
      routes: [
        GoRoute(
          path: _editProfile,
          builder: (ctx, state) => EditProfileScreen(),
        ),
      ],
    );
  }
}
