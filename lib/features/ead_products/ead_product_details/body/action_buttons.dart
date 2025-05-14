import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:my_ad/features/ead_products/ead_product_details/core/ead_product_details_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactActionButtons extends StatelessWidget  {
  final ProductModel product;
  final ProductDetailsViewModel viewModel;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onChat;
  final VoidCallback onInquiry;

  const ContactActionButtons({
    super.key,
    required this.product,
    required this.viewModel,
    required this.onCall,
    required this.onWhatsApp,
    required this.onInquiry,
    required this.onChat,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.call,
            label: 'Call',
            color: Colors.green.shade600,
            onTap: () {
              viewModel.contactMerchant(isCall: true);
              onCall();
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            icon: Icons.chat,
            label: 'WhatsApp',
            color: Colors.green.shade700,
            onTap: () {
              viewModel.contactMerchant(isCall: false);
              onWhatsApp();
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            icon: Icons.chat_bubble_outline,
            label: 'Chat',
            color: Theme.of(context).colorScheme.primary,
            onTap:  onChat,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            context: context,
            icon: Icons.email_outlined,
            label: 'Inquiry',
            color: Colors.orange.shade700,
            onTap: onInquiry,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
