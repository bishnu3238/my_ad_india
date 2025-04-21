import 'package:go_router/go_router.dart';
import '../all_services.dart';

class AllServicesRoute {
  static const String allServices = '/all-services';

  static GoRoute page() => GoRoute(
    path: allServices,

    pageBuilder:
        (context, state) => NoTransitionPage(child: AllServicesScreen()),
  );
}
