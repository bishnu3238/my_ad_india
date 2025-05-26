import 'dart:async';

 import 'package:flutter/material.dart';
 import 'package:google_fonts/google_fonts.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:my_ad/features/chat_feature/route/routes.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_client.dart';
import '../../core/services/socket_services.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  SocketService socketService = SocketService();
  final ApiClient _apiClient = ApiClient(baseUrl: ApiConfig.baseChatUrl);
  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    socketService.connect(
      baseUrl: ApiConfig.socketUrl,
      userType: 'customer',
      userId: 1,
      token: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Demo Screen for Socket IO",
          style: GoogleFonts.poppins(fontSize: 30),
        ),
        actions: [
          IconButton(onPressed: () => connect(), icon: Icon(Icons.refresh)),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => _apiClient.login('ino@gmail.com', '123456'),
                child: Text("login"),
              ),
              ElevatedButton(
                onPressed:
                    () => ChatFeatureRoutes.goToChatScreen(
                      context,
                      22,
                      1,
                      'customer',
                      'Joy',
                    ),
                child: Text("Go to chat Screen"),
              ),
              ElevatedButton(
                onPressed: () => context.push(ChatFeatureRoutes.demoChat),
                child: Text("demo chat"),
              ),
              ElevatedButton(
                onPressed: () => context.push(ChatFeatureRoutes.demoCall),
                child: Text("Demo call"),
              ),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
              ElevatedButton(onPressed: () {}, child: Text("login")),
            ],
          ),
        ),
      ),
    );
  }
}
