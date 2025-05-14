import 'package:go_router/go_router.dart';
import '../app_support/app_support.dart';
import '../app_terms_and_conditions.dart';
import '../feedback_screen.dart';
import '../help.dart';
import '../rate_us.dart';
import '../whats_new.dart';
import '../merchant_registration_terms_page.dart';
import '../privacy_policy.dart';
import '../terms_and_conditions.dart';
import '../about_us.dart';

class TermsRoute {
  static const String termsAndConditions = '/terms-and-conditions';
  static const String appTermsAndConditions = '/app-terms-and-conditions';
  static const String merchantRegistrationTerms =
      '/merchant-registration-terms';
  static const String feedback = '/feedback';
  static const String appSupport = '/app-support';
  static const String privacyPolicy = '/privacy-policy';

  static const String whatsNew = '/whats-new';
  static const String aboutUs = '/about-us';
  static const String rateUs = '/rate-us';
  static const String help = '/help';

  static List<GoRoute> pages() => [
    GoRoute(
      path: termsAndConditions,
      builder: (ctx, state) => TermsAndConditionsPage(),
    ),
    GoRoute(
      path: appTermsAndConditions,
      builder: (ctx, state) => AppTermsAndConditionsPage(),
    ),
    GoRoute(
      path: merchantRegistrationTerms,
      builder: (ctx, state) => MerchantRegistrationTermsPage(),
    ),

    GoRoute(
      path: '$feedback/:serviceProviderId/:serviceId/:customerName',
      builder: (ctx, state) {
        final serviceProviderId =
            state.pathParameters['serviceProviderId'] ?? '0';
        final serviceId = state.pathParameters['serviceId'] ?? '0';
        final customerName =
            state.pathParameters['customerName'] ?? 'Customer Name';

        return FeedbackScreen(
          serviceProviderId: serviceProviderId,
          serviceId: serviceId,
          customerName: customerName,
        );
      },
    ),

    GoRoute(path: appSupport, builder: (ctx, state) => FeedbackSupportScreen()),
    GoRoute(path: whatsNew, builder: (ctx, state) => WhatsNewPage()),
    GoRoute(path: aboutUs, builder: (ctx, state) => AboutUsPage()),
    GoRoute(path: rateUs, builder: (ctx, state) => const RateUsPage()),
    GoRoute(path: help, builder: (ctx, state) => const HelpPage()),
    GoRoute(path: privacyPolicy, builder: (ctx, _) => PrivacyPolicyScreen()),
  ];
}
