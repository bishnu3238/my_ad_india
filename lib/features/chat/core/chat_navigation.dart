import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/chat_screen.dart';
import '../services/chat_manager.dart';

class ChatNavigation {
  // Navigate to conversation list
  static void navigateToConversationList(BuildContext context) {
    GoRouter.of(context).go('/chat');
  }

  // Navigate to specific chat conversation
  static void navigateToChat(
    BuildContext context,
    String conversationId,
    String otherUserName,
    String otherUserImage,
    String otherUserType,
    String otherUserId,
  ) {
    // URL encode parameters to handle special characters
    final encodedName = Uri.encodeComponent(otherUserName);
    final encodedImage = Uri.encodeComponent(otherUserImage);

    context.push(
      '/chat/conversation/$conversationId/$encodedName/$encodedImage/$otherUserType/$otherUserId',
    );
  }

  // Navigate to call history
  static void navigateToCallHistory(BuildContext context) {
    GoRouter.of(context).go('/chat/calls');
  }

  // Navigate to inquiries (for merchants)
  static void navigateToInquiries(BuildContext context) {
    GoRouter.of(context).go('/chat/inquiries');
  }

  // Open chat with a merchant from product details
  static Future<void> openChatWithMerchant(
    BuildContext pageContext,
    ChatManager chatManager,
    String customerId,
    String merchantId,
    String merchantName,
    String merchantImage,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: pageContext,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create or get conversation
      final conversationId = await chatManager.getOrCreateConversation(
        customerId,
        merchantId,
      );
      // Close loading dialog
      if (pageContext.mounted) {
        Navigator.of(pageContext, rootNavigator: true).pop();
      }

      // Navigate to chat screen
      if (pageContext.mounted) {
        navigateToChat(
          pageContext,
          conversationId,
          merchantName,
          merchantImage,
          'merchant',
          merchantId,
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (pageContext.mounted && Navigator.canPop(pageContext)) {
        Navigator.pop(pageContext);
      }

      // Show error message
      if (pageContext.mounted) {
        ScaffoldMessenger.of(
          pageContext,
        ).showSnackBar(SnackBar(content: Text('Error opening chat: $e')));
      }
    }
  }
}
