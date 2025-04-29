import 'package:flutter/material.dart';
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/chat_manager.dart';
import 'conversation_list_screen.dart';
import 'inquiry_screen.dart';
import 'call_history_screen.dart';

class MerchantChatScreen extends StatefulWidget {
  final String merchantId;
  final String merchantName;
  
  const MerchantChatScreen({
    Key? key, 
    required this.merchantId,
    required this.merchantName,
  }) : super(key: key);

  @override
  State<MerchantChatScreen> createState() => _MerchantChatScreenState();
}

class _MerchantChatScreenState extends State<MerchantChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeChatManager();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeChatManager() async {
    final chatManager = Provider.of<ChatManager>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Initialize chat manager with merchant credentials
      if (!chatManager.isInitialized || chatManager.userType != 'merchant') {
        await chatManager.initialize(
          ApiConfig.baseChatUrl, // Your server URL
          widget.merchantId,
          'merchant', // Important: specify 'merchant' as the user type
        );
      }
      
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing chat manager: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize chat: $e';
      });
    }
  }
  
  void _navigateBack() {
    context.pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
        title: Text('${widget.merchantName} - Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Conversations'),
            Tab(text: 'Inquiries'),
            Tab(text: 'Call History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: const [
                    ConversationListScreen(),
                    InquiryScreen(),
                    CallHistoryScreen(),
                  ],
                ),
    );
  }
  
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeChatManager,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
