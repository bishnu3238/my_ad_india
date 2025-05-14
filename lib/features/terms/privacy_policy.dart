import 'package:flutter/material.dart';

import '../../core/constant/app_config.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(child: PrivacyPolicyContent()),
    );
  }
}

class PrivacyPolicyContent extends StatelessWidget {
  PrivacyPolicyContent({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'MyAd Privacy Policy',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Last Updated: April 15, 2025',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Introduction'),
                  _buildParagraph(
                    context,
                    'The terms "We" / "Us" / "Our"/"Company" individually and collectively refer to MyAd and the terms "You" /"Your" / "Yourself" refer to the users.',
                  ),
                  _buildParagraph(
                    context,
                    'This Privacy Policy is an electronic record in the form of an electronic contract formed under the Information Technology Act, 2000 and the rules made thereunder and the amended provisions pertaining to electronic documents / records in various statutes as amended by the Information Technology Act, 2000. This Privacy Policy does not require any physical, electronic or digital signature.',
                  ),
                  _buildParagraph(
                    context,
                    'This Privacy Policy is a legally binding document between you and MyAd. The terms of this Privacy Policy will be effective upon your acceptance of the same (directly or indirectly in electronic form, by clicking on the I accept tab or by use of the website or by other means) and will govern the relationship between you and MyAd for your use of our services through our website and mobile applications.',
                  ),
                  _buildParagraph(
                    context,
                    'This document is published and shall be construed in accordance with the provisions of applicable data protection laws and regulations that require publishing of the Privacy Policy for collection, use, storage and transfer of personal data or information.',
                  ),
                  _buildSectionTitle(context, 'Introduction to Our Service'),
                  _buildParagraph(
                    context,
                    'MyAd is a service provider company that coordinates and facilitates connections between service providers and users. We operate as an intermediary platform that enables users to discover, contact, and engage with various service providers listed on our platform. It is important to understand that MyAd itself does not provide the end services but rather serves as a coordination platform.',
                  ),
                  _buildHighlightBox(
                    context,
                    'Liability Disclaimer: MyAd is not liable in any condition if a service provider deceives a user or vice versa. While we strive to maintain quality standards and verification processes, we function solely as an intermediary platform connecting service providers with users. All transactions, agreements, and service deliveries occur directly between the service provider and the user. Users are advised to exercise due diligence and caution when engaging with service providers found through our platform.',
                  ),
                  _buildSectionTitle(context, 'Information We Collect'),
                  _buildParagraph(
                    context,
                    'To facilitate our services, we collect various types of information from users, including both personal and non-personal information:',
                  ),
                  _buildSubsectionTitle(context, 'Personal Information:'),
                  _buildParagraph(
                    context,
                    'To register and use our services, we collect information such as:',
                  ),
                  _buildBulletList(context, [
                    'Full name',
                    'Contact information (email address, phone number)',
                    'Location data (address, city, state, PIN code)',
                    'Profile information (age, gender, profession)',
                    'Payment information (when applicable)',
                    'Service preferences and requirements',
                    'For service providers: professional details, service descriptions, qualifications, and business information',
                  ]),
                  _buildSubsectionTitle(context, 'Usage Information:'),
                  _buildParagraph(
                    context,
                    'We also collect data about how you interact with our platform, including:',
                  ),
                  _buildBulletList(context, [
                    'Services browsed or searched',
                    'Actions taken on the platform',
                    'Usage patterns and frequency',
                    'Device information (IP address, browser type, operating system)',
                    'Location data (with your permission)',
                  ]),
                  _buildSectionTitle(context, 'How We Use Your Information'),
                  _buildParagraph(
                    context,
                    'We use the collected information for the following purposes:',
                  ),
                  _buildBulletList(context, [
                    'To create and manage your account',
                    'To facilitate connections between service providers and users',
                    'To improve and personalize your experience on our platform',
                    'To process transactions and handle billing (where applicable)',
                    'To communicate important updates and information about our services',
                    'To analyze usage patterns and improve our service offerings',
                    'To detect, prevent, and address technical issues or fraudulent activities',
                    'To comply with legal obligations',
                  ]),
                  _buildSectionTitle(
                    context,
                    'Cookies and Tracking Technologies',
                  ),
                  _buildParagraph(
                    context,
                    'We use cookies and similar tracking technologies to enhance your experience on our platform. These tools help us understand how users navigate our website, which features they use, and how we can improve our services.',
                  ),
                  _buildParagraph(
                    context,
                    'Our cookies may collect information such as your IP address, browser type, the pages you visit, the time spent on those pages, and other statistics. You can control cookies through your browser settings, although disabling certain cookies may limit your ability to use some features of our platform.',
                  ),
                  _buildSectionTitle(
                    context,
                    'Information Sharing and Disclosure',
                  ),
                  _buildParagraph(
                    context,
                    'We may share your information in the following circumstances:',
                  ),
                  _buildSubsectionTitle(context, 'Service Facilitation:'),
                  _buildParagraph(
                    context,
                    'To facilitate connections between service providers and users, certain information is shared between these parties to enable service delivery.',
                  ),
                  _buildSubsectionTitle(context, 'Service Providers:'),
                  _buildParagraph(
                    context,
                    'We may engage third-party companies and individuals to facilitate our services, provide services on our behalf, or assist us in analyzing how our services are used. These third parties have access to your personal information only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.',
                  ),
                  _buildSubsectionTitle(context, 'Legal Requirements:'),
                  _buildParagraph(
                    context,
                    'We may disclose your information when required by law, legal process, or government request, or to protect our rights, property, or safety, or that of our users or others.',
                  ),
                  _buildSubsectionTitle(context, 'Business Transfers:'),
                  _buildParagraph(
                    context,
                    'In the event of a merger, acquisition, or sale of all or a portion of our assets, user information may be among the transferred assets.',
                  ),
                  _buildSectionTitle(context, 'Data Security'),
                  _buildParagraph(
                    context,
                    'We implement appropriate security measures to protect against unauthorized access, alteration, disclosure, or destruction of your personal information. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.',
                  ),
                  _buildParagraph(
                    context,
                    'We regularly review our data collection, storage, and processing practices to enhance security measures. Access to personal information is restricted to employees, contractors, and agents who need to know that information to process it for us.',
                  ),
                  _buildSectionTitle(context, 'Your Rights and Choices'),
                  _buildParagraph(
                    context,
                    'You have several rights regarding your personal information:',
                  ),
                  _buildBulletList(context, [
                    'Access and update your personal information through your account settings',
                    'Request deletion of your account and personal information (subject to certain exceptions)',
                    'Opt-out of marketing communications',
                    'Object to certain processing of your information',
                    'Request a copy of your personal data',
                  ]),
                  _buildParagraph(
                    context,
                    'To exercise these rights, please contact us using the information in the "Contact Us" section.',
                  ),
                  _buildSectionTitle(context, 'Third-Party Links and Services'),
                  _buildParagraph(
                    context,
                    'Our platform may contain links to third-party websites, services, or applications that are not operated by us. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party services. We strongly advise you to review the privacy policy of every site you visit.',
                  ),
                  _buildSectionTitle(context, 'Changes to This Privacy Policy'),
                  _buildParagraph(
                    context,
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.',
                  ),
                  _buildSectionTitle(context, 'Grievance Redressal'),
                  _buildParagraph(
                    context,
                    'If you have any questions, concerns, or complaints about this Privacy Policy or our data practices, please contact our designated Grievance Officer at:',
                  ),
                  _buildContactInfo(context),
                  _buildParagraph(
                    context,
                    'We will acknowledge and address your concern promptly, typically within 30 days of receiving your communication.',
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Accept Policy',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  Widget _buildBulletList(BuildContext context, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildHighlightBox(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: const Color(0xFFFFCA28), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: const Color(0xFFFF9800), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF5D4037)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Email: ${AppConfig.supportEmail}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Address: ${AppConfig.address}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
