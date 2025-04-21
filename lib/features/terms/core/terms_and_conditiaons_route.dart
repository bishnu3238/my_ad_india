import 'package:go_router/go_router.dart';
import '../terms_and_conditions.dart';

class TermsRoute {
  static const String termsAndConditions = '/terms-and-conditions';

  static List<GoRoute> pages() => [
    GoRoute(
      path: termsAndConditions,
      builder: (ctx, state) => TermsAndConditionsPage(),
    ),
  ];
}
