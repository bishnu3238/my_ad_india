import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:pack/auth/custom_auth.dart';
import '../../core/data/model/model.dart';
import '../../core/domain/use_cases/api_call_use_cases.dart';
import 'body/list_of_widgets.dart';
import 'package:provider/provider.dart';

import 'body/feature_section.dart';
import 'body/refer_and_earn_form.dart';
import 'body/refer_appbar.dart';
import 'body/reward_card.dart';
import 'core/refer_and_earn_provider.dart';

class ReferAndEarnPage extends StatelessWidget {
  const ReferAndEarnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => ReferAndEarnProvider(
            DependencyInjector.get<AuthProviderModel<UserModel>>(),
            DependencyInjector.get<ApiCallUseCase>(),
          ),
      child: Scaffold(
        body: Stack(
          children: [
            // Modern Professional Background
            ...listOfWidgets,

            // Content
            SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Bar
                      ReferAppbar(),
                      SizedBox(height: 20),
                      RewardCard(),
                      SizedBox(height: 16),

                      // Form Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ReferAndEarnForm(), // Use the new form widget
                        ),
                      ),

                      SizedBox(height: 24),
                      FeatureSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
