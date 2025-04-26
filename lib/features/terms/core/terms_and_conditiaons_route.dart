import 'package:go_router/go_router.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:my_ad/features/terms/feedback_screen.dart';
import 'package:pack/auth/src/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../app_support/app_support.dart';
import '../merchant_registration_terms_page.dart';
import '../terms_and_conditions.dart';

class TermsRoute {
  static const String termsAndConditions = '/terms-and-conditions';
  static const String merchantRegistrationTerms =
      '/merchant-registration-terms';
  static const String feedback = '/feedback';
  static const String appSupport = '/app-support';

  static List<GoRoute> pages() => [
    GoRoute(
      path: termsAndConditions,
      builder: (ctx, state) => TermsAndConditionsPage(),
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
  ];
}
