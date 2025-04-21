import 'package:go_router/go_router.dart';

import '../merchant_services_screen.dart';

class MerchantServicesRoute {
  static GoRoute page(String path) =>
      GoRoute(path: path, builder: (ctx, state) => MerchantServicesScreen());
}
