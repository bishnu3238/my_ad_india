import 'package:go_router/go_router.dart';
import 'package:my_ad/features/merchant/subscription/subscription_plans_screen.dart';

class SubscriptionPlanRoute {


static GoRoute page(String path)=>GoRoute(path: path, builder: (ctx, state)=>SubscriptionPlansScreen());
}