import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
// ---------------------- Help Page ----------------------
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I create a new account?',
      answer: 'To create a new account, go to the sign-up page and fill in your details. You\'ll need to provide a valid email address and create a secure password. After submitting, verify your email to activate your account.',
    ),
    FAQItem(
      question: 'I forgot my password. What should I do?',
      answer: 'Click on the "Forgot Password" link on the login page. Enter your registered email address, and we\'ll send you instructions to reset your password. Check your email (including spam folder) and follow the provided link.',
    ),
    FAQItem(
      question: 'How do I list my business?',
      answer: 'To list your business, go to the "List Your Business" section from the main menu. Fill in all the required details about your business, including name, category, location, contact information, and business hours. You can also add photos and a description.',
    ),
    FAQItem(
      question: 'How can I advertise my business?',
      answer: 'Visit the "Advertise & Grow" section to explore our advertising options. We offer various packages to promote your business, including featured listings, banner ads, and promotional campaigns. Choose the package that best suits your needs and budget.',
    ),
    FAQItem(
      question: 'How do I change my account settings?',
      answer: 'Access your account settings by clicking on the profile icon and selecting "Settings." From there, you can update your personal information, change your password, manage notifications, and adjust privacy settings.',
    ),
    FAQItem(
      question: 'Is my payment information secure?',
      answer: 'Yes, we use industry-standard encryption and security protocols to protect your payment information. We do not store your complete credit card details on our servers. All payment processing is handled through secure, PCI-compliant payment gateways.',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSupportOptions(theme),
                    const SizedBox(height: 24),
                    _buildFAQSection(theme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.primaryColor.withOpacity(0.05),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for help topics...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.primaryColor, width: 1),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildSupportOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How can we help you?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildSupportCard(
              theme,
              'Contact Support',
              Icons.headset_mic,
                  () => _showContactDialog(context),
            ),
            _buildSupportCard(
              theme,
              'Live Chat',
              Icons.chat_bubble_outline,
                  () => _launchLiveChat(),
            ),
            _buildSupportCard(
              theme,
              'Video Tutorials',
              Icons.video_library_outlined,
                  () => _navigateToTutorials(),
            ),
            _buildSupportCard(
              theme,
              'Email Us',
              Icons.email_outlined,
                  () => _sendSupportEmail(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportCard(
      ThemeData theme,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(ThemeData theme) {
    final filteredFAQs = _faqItems.where((item) {
      return _searchQuery.isEmpty ||
          item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.answer.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (filteredFAQs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "$_searchQuery"',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try using different keywords or contact our support team',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredFAQs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildFAQItem(theme, filteredFAQs[index]);
            },
          ),
        const SizedBox(height: 32),
        Center(
          child: TextButton.icon(
            onPressed: () => _navigateToFullFAQ(),
            icon: const Icon(Icons.list_alt),
            label: const Text('View All FAQs'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(ThemeData theme, FAQItem item) {
    return ExpansionTile(
      title: Text(
        item.question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      backgroundColor: Colors.grey[50],
      collapsedBackgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      children: [
        Text(
          item.answer,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Us'),
              subtitle: const Text('+1 (800) 123-4567'),
              onTap: () => _makePhoneCall(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text('support@myad.com'),
              onTap: () => _sendSupportEmail(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Support Hours'),
              subtitle: const Text('Mon-Fri: 9AM - 6PM'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall() async {
    final phoneUrl = Uri.parse('tel:+18001234567');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  void _sendSupportEmail() async {
    final emailUrl = Uri.parse('mailto:support@myad.com?subject=Support Request');
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email client')),
        );
      }
    }
  }

  void _launchLiveChat() {
    // Implement live chat functionality
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live chat is coming soon!')),
      );
    }
  }

  void _navigateToTutorials() {
    // Navigate to video tutorials page
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video tutorials coming soon!')),
      );
    }
  }

  void _navigateToFullFAQ() {
    // Navigate to full FAQ page
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigating to full FAQ page')),
      );
    }
  }
}