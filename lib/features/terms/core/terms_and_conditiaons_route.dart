import 'package:go_router/go_router.dart';
import '../merchant_registration_terms_page.dart';
import '../terms_and_conditions.dart';

class TermsRoute {
  static const String termsAndConditions = '/terms-and-conditions';
  static const String merchantRegistrationTerms =
      '/merchant-registration-terms';

  static List<GoRoute> pages() => [
    GoRoute(
      path: termsAndConditions,
      builder: (ctx, state) => TermsAndConditionsPage(),
    ),
    GoRoute(
      path: merchantRegistrationTerms,
      builder: (ctx, state) => MerchantRegistrationTermsPage(),
    ),
  ];
}
