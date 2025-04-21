import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.help_outline, color: Colors.blue[700]),
          const SizedBox(width: 8),
          const Text('Help'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registration Guide',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            icon: Icons.person_outline,
            title: 'Personal Info',
            description: 'Enter your basic contact information.',
          ),
          _buildHelpItem(
            icon: Icons.business_center_outlined,
            title: 'Business Details',
            description: 'Information about your shop or company.',
          ),
          _buildHelpItem(
            icon: Icons.location_on_outlined,
            title: 'Address',
            description: 'Your business address and location.',
          ),
          _buildHelpItem(
            icon: Icons.account_circle_outlined,
            title: 'Account',
            description: 'Set up your login credentials and preferences.',
          ),
          const SizedBox(height: 12),
          Text(
            'Need more help?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact our support team at support@example.com or call +1-234-567-8900.',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}