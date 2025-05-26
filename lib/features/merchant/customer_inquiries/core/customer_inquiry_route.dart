import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/domain/data_store/merchant_dashboard_store.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:provider/provider.dart';

import '../customer_inquiries.dart';
import 'customer_inquiry_provider.dart';

class CustomerInquiryRoute {
  static const String customerInquiry = '/customer-inquiry';

  static GoRoute page() => GoRoute(
    path: customerInquiry,
    builder:
        (ctx, state) => ChangeNotifierProvider(
          create:
              (ctx) => DependencyInjector.getWithParams<
                CustomerInquiriesProvider,
                MerchantDashboardStore,
                dynamic
              >(param1: ctx.read<MerchantDashboardStore>(), param2: 1),
          child: CustomerInquiriesPage(),
        ),
  );

  static openInquiry(BuildContext context) {
    context.push(customerInquiry);
  }
}
