import 'package:flutter/material.dart';
import 'package:pack/extensions/contextx.dart';

import '../../core/constant/app_config.dart';

class AppTermsAndConditionsPage extends StatelessWidget {
  const AppTermsAndConditionsPage({super.key});

  Text buildHeading(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );

  Text buildSubheading(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Text buildBody(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: TextStyle(color: context.colorScheme.surface),
        ),
        backgroundColor: context.primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeading("TERMS AND CONDITIONS"),
              const SizedBox(height: 10),
              buildBody(
                'The terms "We" / "Us" / "Our"/"Company" individually and collectively refer to MyAd and the terms "Visitor" "User" refer to the users of our platform, including both service seekers and service providers.',
              ),
              const SizedBox(height: 10),
              buildBody(
                'This page states the Terms and Conditions under which you may use this website and our services. Please read this page carefully...',
              ),

              const SizedBox(height: 20),
              buildSubheading("NATURE OF OUR SERVICES"),
              buildBody(
                'MyAd operates as a coordination platform that connects service providers with users...',
              ),

              const SizedBox(height: 20),
              buildSubheading("INTERMEDIARY STATUS AND LIABILITY LIMITATIONS"),
              buildBody(
                'MyAd functions solely as an intermediary platform and is not a party to any transaction...',
              ),

              const SizedBox(height: 20),
              buildSubheading("USE OF CONTENT"),
              buildBody(
                'All logos, brands, marks, headings, labels, names... are properties either owned or used under license by MyAd.',
              ),

              const SizedBox(height: 20),
              buildSubheading("USER ACCOUNTS AND RESPONSIBILITIES"),
              buildBody(
                'For Service Seekers:\n'
                '• You must provide accurate and complete information...\n'
                '• You are responsible for maintaining account confidentiality...',
              ),

              buildBody(
                'For Service Providers:\n'
                '• You must provide accurate information...\n'
                '• You are responsible for service quality and timeliness...',
              ),

              const SizedBox(height: 20),
              buildSubheading("ACCEPTABLE WEBSITE USE"),
              buildBody(
                '(A) Security Rules\n'
                '• Accessing data not intended for you...\n'
                '• Attempting to interfere with service to any user...\n',
              ),
              buildBody(
                '(B) General Rules\n'
                '• Transmit material that encourages criminal conduct...\n',
              ),

              const SizedBox(height: 20),
              buildSubheading("PAYMENT AND FEES"),
              buildBody(
                'MyAd may charge service providers fees for listing... Users are responsible for paying service providers directly...',
              ),

              const SizedBox(height: 20),
              buildSubheading("INDEMNITY"),
              buildBody(
                'You agree to indemnify and hold harmless, without objection, MyAd...',
              ),

              const SizedBox(height: 20),
              buildSubheading("LIABILITY LIMITATIONS"),
              buildBody(
                'In no event shall MyAd be liable for any direct, indirect, incidental...',
              ),

              const SizedBox(height: 20),
              buildSubheading("DISCLAIMER OF WARRANTIES"),
              buildBody(
                'MyAd provides its services on an "as is" and "as available" basis...',
              ),

              const SizedBox(height: 20),
              buildSubheading("MODIFICATIONS TO SERVICE"),
              buildBody(
                'MyAd reserves the right to modify or discontinue the service...',
              ),

              const SizedBox(height: 20),
              buildSubheading("TERMINATION"),
              buildBody(
                'MyAd may terminate your access to all or any part of our services...',
              ),

              const SizedBox(height: 20),
              buildSubheading("GOVERNING LAW"),
              buildBody(
                'These Terms and Conditions shall be governed by and construed in accordance with the laws of India...',
              ),

              const SizedBox(height: 20),
              buildSubheading("CONTACT INFORMATION"),
              buildBody(
                'Email: ${AppConfig.supportEmail}\nAddress: ${AppConfig.address}\n\nLast Updated: April 15, 2025',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
