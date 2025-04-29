import 'package:go_router/go_router.dart';
import '../screens/call_history_screen.dart';
import '../screens/chat_home_page.dart';
import '../screens/chat_screen.dart';
import '../screens/inquiry_screen.dart';

class ChatNavigator {
  static const String chatScreen = '/chat-screen';
  static const String chatConversationScreen = '/chat-conversation-screen';

  static List<GoRoute> pages() {
    return [
      // Add these routes to your existing GoRouter configuration
      // Inside the routes list:
      GoRoute(path: '/chat', builder: (context, state) => const ChatHomePage()),
      GoRoute(
        path:
            '/chat/conversation/:conversationId/:otherUserName/:otherUserImage/:otherUserType/:otherUserId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId'] ?? '';
          final otherUserName = Uri.decodeComponent(
            state.pathParameters['otherUserName'] ?? '',
          );
          final otherUserImage = Uri.decodeComponent(
            state.pathParameters['otherUserImage'] ?? '',
          );
          final otherUserType = state.pathParameters['otherUserType'] ?? '';
          final otherUserId = state.pathParameters['otherUserId'] ?? '';

          return ChatScreen(
            conversationId: conversationId,
            otherUserName: otherUserName,
            otherUserImage: otherUserImage,
            otherUserType: otherUserType,
            otherUserId: otherUserId,
          );
        },
      ),
      GoRoute(
        path: '/chat/calls',
        builder: (context, state) => const CallHistoryScreen(),
      ),
      GoRoute(
        path: '/chat/inquiries',
        builder: (context, state) => const InquiryScreen(),
      ),
    ];
  }
}
