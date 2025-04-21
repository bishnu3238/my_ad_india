import 'package:go_router/go_router.dart';

import '../location_screen.dart';

class LocationRoute {
  static const String location = '/location';
  static const String name = 'location';

  static GoRoute page() {
    return GoRoute(
      path: location,
      pageBuilder:
          (context, state) => NoTransitionPage(child: LocationScreen()),
    );
  }
}
