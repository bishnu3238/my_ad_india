// Terms and Conditions page with checkbox
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pack/extensions/contextx.dart';

import '../refer_earn/core/refer_earn_route.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(middle: Text('Terms & Conditions')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Referral Program Terms & Conditions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTermsSection(
                        '1. Eligibility',
                        'To participate in our referral program, you must be a registered user of our application. Employees and their immediate family members are not eligible to participate.',
                      ),
                      _buildTermsSection(
                        '2. Referral Process',
                        'You will receive a unique referral code that you can share with your friends. When they register using your code, both you and your friend will receive the specified rewards after they complete their first transaction.',
                      ),
                      _buildTermsSection(
                        '3. Rewards',
                        'Rewards will be credited to your account within 7 business days after your referred friend completes their first qualified transaction. Rewards have no cash value and cannot be transferred or sold.',
                      ),
                      _buildTermsSection(
                        '4. Limitations',
                        'There is no limit to how many friends you can refer, but rewards may be subject to verification and approval. We reserve the right to modify or terminate this program at any time without notice.',
                      ),
                      _buildTermsSection(
                        '5. Prohibited Activities',
                        'Self-referrals, creating multiple accounts, or any form of fraudulent activity will result in disqualification from the program and potential termination of your account.',
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Divider(color: CupertinoColors.systemGrey4),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    CupertinoSwitch(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value;
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    Text('I agree to the terms and conditions'),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: context.colorScheme.primary, //007AFFFF
                  disabledColor: CupertinoColors.systemGrey3,
                  onPressed:
                      _agreeToTerms
                          ? () {
                            context.push(ReferEarnRoute.referAndEarn);
                          }
                          : null,
                  child: Text(
                    'Back',
                    style: context.bodyMedium!.copyWith(
                      color: context.colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}
