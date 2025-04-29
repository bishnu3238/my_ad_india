import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_manager.dart';
import '../services/call_notification_service.dart';
import 'conversation_list_screen.dart';
import 'call_history_screen.dart';
import 'inquiry_screen.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final chatManager = Provider.of<ChatManager>(context);
    
    // Determine which screens to show based on user type
    final List<Widget> screens = [
      const ConversationListScreen(),
      const CallHistoryScreen(),
    ];
    
    if (chatManager.userType == 'merchant') {
      screens.add(const InquiryScreen());
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index < screens.length) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),
          if (chatManager.userType == 'merchant')
            const BottomNavigationBarItem(
              icon: Icon(Icons.help_outline),
              label: 'Inquiries',
            ),
        ],
      ),
    );
  }
}