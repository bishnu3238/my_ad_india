// --- Update ChatFeatureRoutes ---

import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:my_ad/core/injector/dependency_injection.dart';
import 'package:my_ad/features/chat_feature/core/provider/call_provider.dart';
import 'package:my_ad/features/chat_feature/core/provider/chat_list_provider.dart';
import 'package:my_ad/features/chat_feature/core/provider/chat_provider.dart';
import 'package:my_ad/features/chat_feature/core/services/api_client.dart';
import 'package:my_ad/features/chat_feature/core/services/call_service.dart';
import 'package:my_ad/features/chat_feature/core/services/chat_list_service.dart';
import 'package:my_ad/features/chat_feature/core/services/socket_services.dart';
import 'package:my_ad/features/chat_feature/screens/call/call_screen.dart';
import 'package:pack/extensions/extensions.dart';
import 'package:pack/services/api_services/api_services.dart';
import 'package:provider/provider.dart';

import '../screens/chat/chat_details_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/demo/call_demo.dart';
import '../screens/demo/chat_demo.dart';
import '../screens/demo/demo_screen.dart';
import '../screens/chat/chat_list_screen.dart';

class ChatFeatureRoutes {
  static const String demo = '/demo';
  static const String demoChat = '/demo-chat';
  static const String demoCall = '/demo-call';

  static const String chat = '/chat';
  static const String chatList = '/chat-list';
  static const String call = '/call-screen';
  static const String chatSettings = '/chat_settings';
  static const String chatSearch = '/chat_search';

  static List<GoRoute> page() => [
    GoRoute(path: demo, builder: (ctx, state) => DemoScreen()),
    GoRoute(path: demoChat, builder: (ctx, state) => ChatHomeScreen()),
    GoRoute(path: demoCall, builder: (ctx, state) => CallExampleScreen()),
    GoRoute(
      path: '$chat/:receiverId/:senderId/:senderType/:receiverName',
      builder: (ctx, state) {
        final receiverId = int.parse(state.pathParameters['receiverId']!);
        final senderId = int.parse(state.pathParameters['senderId']!);
        final senderType = state.pathParameters['senderType']!;
        final receiverName = state.pathParameters['receiverName']!;

        return ChangeNotifierProvider(
          create:
              (ctx) => ChatProvider(
                apiClient: ApiClient(baseUrl: ApiConfig.baseChatUrl),
                socketService: SocketService(),
              ),
          child: ChatDetailScreen(
            receiverId: receiverId,
            senderId: senderId,
            senderType: senderType,
            receiverName: receiverName,
          ),
        );
      },
    ),
    chatListPage(),
    callPage(),
  ];

  static GoRoute chatListPage() => GoRoute(
    path: '$chatList/:userType/:userId',
    builder: (ctx, state) {
      final userType = state.pathParameters['userType']!;
      final userId = int.parse(state.pathParameters['userId']!);

      return ChangeNotifierProvider(
        create:
            (ctx) => ChatListProvider(
              chatListService: ChatListService(
                apiClient: ApiClient(
                  baseUrl: ApiConfig.baseChatUrl,
                  api: DependencyInjector.get<ApiCallService>(),
                ),
              ),
            ),
        child: ChatListScreen(userType: userType, userId: userId),
      );
    },
  );
  static GoRoute callPage() => GoRoute(
    path: '$call/:isIncoming',
    builder: (ctx, state) {
      final isIncoming = state.pathParameters.getBool('isIncoming');
      final callData = state.extra as Map<String, String?>;

      return ChangeNotifierProvider(
        create:
            (ctx) => CallProvider(
              callService: CallService(
                socketService: DependencyInjector.get<SocketService>(),
              ),
            ),
        child: CallScreen(isIncoming: isIncoming, callData: callData),
      );
    },
  );

  static goToChatScreen(
    context,
    int receiverId,
    int senderId,
    String senderType,
    String receiverName,
  ) {
    GoRouter.of(
      context,
    ).push('$chat/$receiverId/$senderId/$senderType/$receiverName');
  }

  static goToChatListScreen(context, int userId, String userType) {
    GoRouter.of(context).push('$chatList/$userType/$userId');
  }

  static void goToCallScreen(BuildContext context, Map<String, String?> data) {
    dev.log('Call data: $data');
    GoRouter.of(context).push('$call/false', extra: data);
  }
}
