import 'package:go_router/go_router.dart';

import '../refer_earn.dart';

class ReferEarnRoute {

  static const String referAndEarn = '/referEarn';

  static GoRoute page()=>GoRoute(path: referAndEarn, builder: (ctx, state) => ReferAndEarnPage());


}