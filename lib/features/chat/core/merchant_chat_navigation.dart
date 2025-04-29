import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MerchantChatNavigation {
  // Navigate to merchant chat screen using GoRouter
  static void navigateToMerchantChat(
    BuildContext context,
    String merchantId,
    String merchantName,
  ) {
    GoRouter.of(context).push('/merchant/chat/$merchantId/$merchantName');
  }
  
  // Navigate to specific conversation
  static void navigateToConversation(
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
    
    GoRouter.of(context).push(
      '/merchant/chat/conversation/$conversationId/$encodedName/$encodedImage/$otherUserType/$otherUserId'
    );
  }
  
  // Navigate to inquiries
  static void navigateToInquiries(BuildContext context) {
    GoRouter.of(context).push('/merchant/chat/inquiries');
  }
  
  // Navigate to call history
  static void navigateToCallHistory(BuildContext context) {
    GoRouter.of(context).push('/merchant/chat/calls');
  }
}
