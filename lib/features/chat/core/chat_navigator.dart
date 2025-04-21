import 'package:go_router/go_router.dart';
import 'package:my_ad/features/chat/screens/chat_conversations_screen.dart';
import 'package:my_ad/features/chat/screens/chat_screen.dart';

class ChatNavigator {
  static const String chatScreen = '/chat-screen';
  static const String chatConversationScreen = '/chat-conversation-screen';

  static List<GoRoute> pages() {
    return [
      GoRoute(
        path: '$chatScreen/:merchantId/:merchantName/:userId',
        builder: (ctx, state) {
          final merchantId = state.pathParameters['merchantId'];
          final merchantName = state.pathParameters['merchantName'];
          final userId = state.pathParameters['userId'];

          return ChatScreen(
            merchantId: merchantId ?? '',
            merchantName: merchantName ?? '',
            userId: userId ?? '0',
          );
        },
      ),
      GoRoute(
        path: '$chatConversationScreen/:userId',
        builder: (ctx, state) {
          final userId = state.pathParameters['userId'];

          return ChatConversationsScreen(userId: userId ?? '');
        },
      ),
    ];
  }
}
