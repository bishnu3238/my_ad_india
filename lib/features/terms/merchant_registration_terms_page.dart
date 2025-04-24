import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class MerchantRegistrationTermsPage extends StatelessWidget {
  MerchantRegistrationTermsPage({super.key});

  final ScrollController _scrollController = ScrollController();

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  TextSpan sectionTitle(String text) => TextSpan(
    text: "\n\n$text\n",
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
  );

  TextSpan sectionContent(String text) => TextSpan(
    text: "$text\n",
    style: const TextStyle(fontSize: 16, height: 1.5),
  );

  TextSpan bulletPoint(String text) => TextSpan(
    text: "• $text\n",
    style: const TextStyle(fontSize: 16, height: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(
                  text: "TERMS AND CONDITIONS\n\n",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                sectionContent(
                  'The terms "We" / "Us" / "Our"/"Company" individually and collectively refer to MyAd and the terms "Visitor" "User" refer to the users of our platform, including both service seekers and service providers.',
                ),
                sectionContent(
                  "This page states the Terms and Conditions under which you may use this website and our services. Please read this page carefully. If you do not accept the Terms and Conditions stated here, please exit this site.",
                ),
                sectionContent(
                  "MyAd reserves the right to revise these Terms and Conditions at any time by updating this posting. You should visit this page periodically to review the Terms and Conditions, as they are binding on all users.",
                ),
                sectionTitle("NATURE OF OUR SERVICES"),
                bulletPoint("MyAd operates as a coordination platform connecting service providers and users."),
                bulletPoint("We do not directly provide listed services."),
                bulletPoint("We facilitate discovery, connection, scheduling, payments, and reviews."),
                sectionTitle("INTERMEDIARY STATUS AND LIABILITY LIMITATIONS"),
                sectionContent(
                  "MyAd functions solely as an intermediary platform and is not a party to any transaction between users and service providers.",
                ),
                bulletPoint("We do not control, endorse, or guarantee service quality."),
                bulletPoint("All agreements happen directly between users and providers."),
                bulletPoint("Users must exercise due diligence."),
                sectionTitle("USE OF CONTENT"),
                sectionContent(
                  "All logos, brands, and marks are owned by MyAd or used under license. Unauthorized use is prohibited.",
                ),
                sectionTitle("USER ACCOUNTS AND RESPONSIBILITIES"),
                const TextSpan(
                  text: "\nFor Service Seekers:\n",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                bulletPoint("Provide accurate information."),
                bulletPoint("Maintain confidentiality of account credentials."),
                bulletPoint("Pay service providers directly."),
                bulletPoint("Provide honest and fair reviews."),
                const TextSpan(
                  text: "\nFor Service Providers:\n",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                bulletPoint("Provide accurate service details."),
                bulletPoint("Deliver quality services promptly."),
                bulletPoint("Follow all laws and maintain professionalism."),
                sectionTitle("ACCEPTABLE WEBSITE USE"),
                const TextSpan(
                  text: "\n(A) Security Rules:\n",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                bulletPoint("Do not attempt unauthorized access."),
                bulletPoint("Do not attempt to disrupt service or network."),
                bulletPoint("No sending of unsolicited promotions."),
                const TextSpan(
                  text: "\n(B) General Rules:\n",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                bulletPoint("Do not transmit illegal content."),
                bulletPoint("Respect intellectual property and privacy rights."),
                bulletPoint("No hateful, defamatory, or obscene content."),
                bulletPoint("No misrepresentation of identity."),
                sectionTitle("PAYMENT AND FEES"),
                sectionContent(
                  "MyAd may charge listing fees to service providers. Payment to providers is the user's responsibility unless specified otherwise.",
                ),
                sectionTitle("INDEMNITY"),
                sectionContent(
                  "You agree to indemnify and hold harmless MyAd from any claims arising out of your platform use.",
                ),
                sectionTitle("LIABILITY LIMITATIONS"),
                sectionContent(
                  "MyAd is not liable for damages arising from use of the platform or interactions between users and providers.",
                ),
                sectionTitle("DISCLAIMER OF WARRANTIES"),
                sectionContent(
                  "Services are provided 'as is' and 'as available', without warranties of any kind.",
                ),
                sectionTitle("MODIFICATIONS TO SERVICE"),
                sectionContent(
                  "MyAd may modify or discontinue services at any time without notice.",
                ),
                sectionTitle("TERMINATION"),
                sectionContent(
                  "MyAd reserves the right to terminate access at any time. Certain provisions survive termination.",
                ),
                sectionTitle("GOVERNING LAW"),
                sectionContent(
                  "These Terms are governed by the laws of India. Disputes shall be subject to courts located in [Your City].",
                ),
                sectionTitle("CONTACT INFORMATION"),
                TextSpan(
                  text: "Email: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "support@myad.com\n",
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()..onTap = () => _launchEmail('support@myad.com'),
                ),
                /// TODO: Add company address later.
                TextSpan(
                  text: "Address: [Your company address]\n\n",
                  style: const TextStyle(fontSize: 16),
                ),
                sectionContent(
                  "Last Updated: April 15, 2025",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}