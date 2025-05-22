import 'package:chat_sdk/chat_sdk.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:my_ad/features/chat_feature/route/routes.dart';

import '../core/services/socket_services.dart';

// class DemoScreen extends StatefulWidget {
//   const DemoScreen({super.key});
//
//   @override
//   State<DemoScreen> createState() => _DemoScreenState();
// }
//
// class _DemoScreenState extends State<DemoScreen> {
//   SocketService socketService = SocketService();
//   final ApiClient _apiClient = ApiClient(baseUrl: ApiConfig.baseChatUrl);
//   @override
//   void initState() {
//     super.initState();
//     connect();
//   }
//
//   void connect() {
//     socketService.connect(
//       baseUrl: ApiConfig.socketUrl,
//       userType: 'customer',
//       userId: 1,
//       token: '',
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Demo Screen for Socket IO",
//           style: GoogleFonts.poppins(fontSize: 30),
//         ),
//         actions: [
//           IconButton(onPressed: () => connect(), icon: Icon(Icons.refresh)),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               ElevatedButton(
//                 onPressed: () => _apiClient.login('ino@gmail.com', '123456'),
//                 child: Text("login"),
//               ),
//               ElevatedButton(
//                 onPressed:
//                     () => ChatFeatureRoutes.goToChatScreen(
//                       context,
//                       22,
//                       1,
//                       'customer',
//                       'Joy',
//                     ),
//                 child: Text("Go to chat Screen"),
//               ),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//               ElevatedButton(onPressed: () {}, child: Text("login")),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  late final ApiClient api;
  late final SocketManager socket;
  late final ChatService chatService;
  ChatController? chatController;

  final String currentUserId = '1';
  final String otherUserId = '3'; // Example

  @override
  void initState() {
    super.initState();
    api = ApiClient(ApiConfig.baseChatUrl);
    socket = SocketManager();
    socket.connect(ApiConfig.socketUrl);
    chatService = ChatService(api, socket);
    _initConversation();
  }

  Future<void> _initConversation() async {
    // Create or get conversation from backend
    final res = await api.post(
      '/api/conversations',
      data: {'customerId': currentUserId, 'merchantId': otherUserId},
    );
    final conversationId = res.data['conversationId'].toString();
    chatController = ChatController(
      chatService: chatService,
      conversationId: conversationId,
      currentUserId: currentUserId,
    );
    await chatController!.loadMessages();
    chatController!.listenForMessages();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (chatController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('MyAd Chat Example')),
      body: AnimatedBuilder(
        animation: chatController!,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: ChatListView(
                  messages: chatController!.messages,
                  currentUserId: currentUserId,
                  isLoading: chatController!.state == ChatState.loading,
                  errorMessage: chatController!.errorMessage,
                  onRetry: chatController!.retry,
                  onProfileTap: (userId) {
                    // Show profile or user details
                  },
                ),
              ),
              MessageInput(
                onSend: (text, {filePath}) {
                  chatController!.sendMessage(text, fileUrl: filePath);
                },
                isSending: chatController!.isSending,
                onAttach: () {
                  // Show file picker
                },
                onVoiceRecord: () {
                  // Show voice recorder
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
