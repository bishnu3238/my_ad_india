import 'package:go_router/go_router.dart';

import '../../../../merchant_add_service/merchant_add_service_screen.dart';

 
class MerchantAddServiceRoute {

  static GoRoute page(String addService) => GoRoute(
    path: addService,
    builder: (ctx, state) => MerchantAddServiceScreen(),
  );
}
