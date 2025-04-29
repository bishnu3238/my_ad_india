import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import 'socket_service.dart';
import 'chat_api_service.dart';

class ChatManager extends ChangeNotifier {
  final SocketService socketService = SocketService();
  final ChatApiService _apiService = ChatApiService();
  
  // User information
  String? userId;
  String? userType;
  
  // State variables
  List<Conversation> _conversations = [];
  Map<String, List<ChatMessage>> _messages = {};
  List<CallLog> _callHistory = [];
  List<Inquiry> _inquiries = [];
  
  // Current conversation
  String? _currentConversationId;
  String? _otherUserType;
  String? _otherUserId;
  
  // Typing indicator state
  Map<String, bool> _typingUsers = {};
  Timer? _typingTimer;
  
  // Getters
  List<Conversation> get conversations => _conversations;
  List<ChatMessage> getMessages(String conversationId) => _messages[conversationId] ?? [];
  List<CallLog> get callHistory => _callHistory;
  List<Inquiry> get inquiries => _inquiries;
  bool isTyping(String conversationId) => _typingUsers[conversationId] ?? false;
  
  bool get isInitialized => userId != null && userType != null;
  
  // Ensure the manager is initialized before performing operations
  bool ensureInitialized() {
    if (!isInitialized) {
      debugPrint('ChatManager not initialized. Call initialize() first.');
      throw Exception('ChatManager not initialized. Call initialize() first.');
    }
    return true;
  }
  
  // Update user information
  void updateUserInfo(String userId, String userType) {
    this.userId = userId;
    this.userType = userType;
    if (_apiService.baseUrl.isNotEmpty) {
      _apiService.initialize(_apiService.baseUrl, userId: userId, userType: userType);
    }
    notifyListeners();
  }

  // Initialize the chat manager
  Future<void> initialize(String baseUrl, String userId, String userType) async {
    debugPrint('Initializing ChatManager with userId: $userId, userType: $userType');
    
    this.userId = userId;
    this.userType = userType;
    
    // Initialize services
    _apiService.initialize(baseUrl, userId: userId, userType: userType);
    socketService.initialize(baseUrl);
    
    // Setup socket listeners
    _setupSocketListeners();
    
    try {
      // Connect to socket
       socketService.connect();
      
      // Authenticate with socket
      _authenticate();
      
      // Load initial data
      await refreshConversations();
      await refreshCallHistory();
      
      if (userType == 'merchant') {
        try {
          await refreshInquiries();
        } catch (e) {
          debugPrint('Error refreshing inquiries: $e');
          // Don't throw here, just log the error
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error during ChatManager initialization: $e');
      throw Exception('Failed to initialize chat: $e');
    }
  }
  
  void _setupSocketListeners() {
    // Handle connection events
    socketService.onConnect.listen((_) {
      debugPrint('Socket connected, authenticating...');
      _authenticate();
    });
    
    // Handle new messages
    socketService.onNewMessage.listen((data) {
      _handleNewMessage(data);
    });
    
    // Handle messages read
    socketService.onMessagesRead.listen((data) {
      _handleMessagesRead(data);
    });
    
    // Handle typing indicators
    socketService.onUserTyping.listen((data) {
      _handleUserTyping(data);
    });
    
    // Handle incoming calls
    socketService.onIncomingCall.listen((data) {
      // This will be handled by the UI layer
      // Just pass it through
    });
    
    // Handle call responses
    socketService.onCallResponse.listen((data) {
      // This will be handled by the UI layer
      // Just pass it through
    });
    
    // Handle call ended
    socketService.onCallEnded.listen((data) {
      // Refresh call history
      refreshCallHistory();
    });
    
    // Handle new inquiries (for merchants)
    if (userType == 'merchant') {
      socketService.onNewInquiry.listen((data) {
        refreshInquiries();
      });
    }
  }
  
  void _authenticate() {
    if (!isInitialized) {
      debugPrint('Cannot authenticate: User information not set');
      return;
    }
    socketService.authenticate(userId!, userType!);
  }
  
  // Refresh data from API
  Future<void> refreshConversations() async {
    ensureInitialized();
    
    try {
      _conversations = await _apiService.getConversations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing conversations: $e');
      rethrow;
    }
  }
  
  Future<void> loadMessages(String conversationId, {bool refresh = false, int page = 1}) async {
    ensureInitialized();
    
    try {
      if (refresh || !_messages.containsKey(conversationId)) {
        final messages = await _apiService.getMessages(conversationId);
        _messages[conversationId] = messages;
        notifyListeners();
      } else if (page > 1) {
        // Load more messages for pagination
        final moreMessages = await _apiService.getMessages(conversationId, page: page);
        if (moreMessages.isNotEmpty) {
          _messages[conversationId] = [...moreMessages, ..._messages[conversationId]!];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      rethrow;
    }
  }
  
  Future<void> refreshCallHistory() async {
    ensureInitialized();
    
    try {
      _callHistory = await _apiService.getCallHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing call history: $e');
      // Don't throw here, just log the error
    }
  }
  
  Future<void> refreshInquiries({String status = 'pending'}) async {
    ensureInitialized();
    
    if (userType != 'merchant') {
      debugPrint('Only merchants can access inquiries');
      return;
    }
    
    try {
      _inquiries = await _apiService.getInquiries(userId!, status: status);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing inquiries: $e');
      // Don't throw here, just log the error
    }
  }
  
  // Set current conversation
  Future<void> setCurrentConversation(String conversationId, String otherUserType, String otherUserId) async {
    ensureInitialized();
    
    _currentConversationId = conversationId;
    _otherUserType = otherUserType;
    _otherUserId = otherUserId;
    
    try {
      // Load messages for this conversation
      await loadMessages(conversationId, refresh: true);
      
      // Mark messages as read
      await markMessagesAsRead(conversationId);
    } catch (e) {
      debugPrint('Error setting current conversation: $e');
      rethrow;
    }
  }
  
  // Create a new conversation if needed
  Future<String> getOrCreateConversation(String customerId, String merchantId) async {
    if (!isInitialized) {
      // Initialize with the provided IDs if not already initialized
      if (userType == null) {
        updateUserInfo(customerId, 'customer'); // Assume customer by default
      }
    }
    
    ensureInitialized();
    
    // Check if conversation already exists
    for (var conversation in _conversations) {
      if (conversation.customerId == customerId && conversation.merchantId == merchantId) {
        return conversation.id;
      }
    }
    
    // Create new conversation
    try {
      final conversationId = await _apiService.createConversation(customerId, merchantId);
      await refreshConversations(); // Refresh to get the new conversation
      return conversationId;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      rethrow;
    }
  }
  
  // Send a text message
  Future<void> sendTextMessage(String message) async {
    ensureInitialized();
    
    if (_currentConversationId == null || _otherUserType == null || _otherUserId == null) {
      throw Exception('No active conversation');
    }
    
    try {
      final messageData = {
        'conversationId': _currentConversationId,
        'senderType': userType,
        'senderId': userId,
        'receiverType': _otherUserType,
        'receiverId': _otherUserId,
        'message': message,
        'messageType': 'text',
      };
      
       socketService.sendMessage(messageData);
    } catch (e) {
      debugPrint('Error sending text message: $e');
      rethrow;
    }
  }
  
  // Send a file message
  Future<void> sendFileMessage(File file, String messageType) async {
    if (!ensureInitialized()) {
      throw Exception('User information not set');
    }
    
    if (_currentConversationId == null || _otherUserType == null || _otherUserId == null) {
      throw Exception('No active conversation');
    }
    
    try {
      // Upload the file
      final fileUrl = await _apiService.uploadFile(file);
      
      // Create message with file URL
      final messageData = {
        'conversationId': _currentConversationId,
        'senderType': userType,
        'senderId': userId,
        'receiverType': _otherUserType,
        'receiverId': _otherUserId,
        'message': 'Sent a ${messageType == 'image' ? 'photo' : 'file'}',
        'messageType': messageType,
        'fileUrl': fileUrl,
      };
      
      socketService.sendMessage(messageData);
    } catch (e) {
      debugPrint('Error sending file message: $e');
      throw e;
    }
  }
  
  // Send an inquiry (customer only)
  Future<void> sendInquiry(String inquiryText, String merchantId) async {
    if (!ensureInitialized()) {
      throw Exception('User information not set');
    }
    
    if (userType != 'customer') {
      throw Exception('Only customers can send inquiries');
    }
    
    if (_currentConversationId == null) {
      throw Exception('No active conversation');
    }
    
    socketService.submitInquiry(
      _currentConversationId!,
      userId!,
      merchantId,
      inquiryText,
    );
  }
  
  // Update inquiry status (merchant only)
  Future<void> updateInquiryStatus(String inquiryId, String status) async {
    if (!ensureInitialized()) {
      throw Exception('User information not set');
    }
    
    if (userType != 'merchant') {
      throw Exception('Only merchants can update inquiry status');
    }
    
    try {
      final success = await _apiService.updateInquiryStatus(inquiryId, status);
      if (success) {
        refreshInquiries();
      }
    } catch (e) {
      debugPrint('Error updating inquiry status: $e');
      throw e;
    }
  }
  
  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    ensureInitialized();
    
    try {
       socketService.markAsRead(conversationId);
      
      // Also update local state
      if (_messages.containsKey(conversationId)) {
        final updatedMessages = _messages[conversationId]!.map((msg) {
          if (!msg.isMine && !msg.isRead) {
            return msg.copyWith(isRead: true);
          }
          return msg;
        }).toList();
        
        _messages[conversationId] = updatedMessages;
        
        // Update conversation unread count
        final convoIndex = _conversations.indexWhere((c) => c.id == conversationId);
        if (convoIndex >= 0) {
          _conversations[convoIndex] = _conversations[convoIndex].copyWith(unreadCount: 0);
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      // Don't throw here, just log the error
    }
  }
  
  // Send typing indicator
  void sendTypingIndicator() {
    if (_currentConversationId == null || _otherUserType == null || _otherUserId == null) {
      return;
    }
    
    // Cancel previous timer if exists
    _typingTimer?.cancel();
    
    socketService.sendTypingIndicator(
      _currentConversationId!,
      _otherUserType!,
      _otherUserId!,
    );
    
    // Set a timer to stop typing indicator after 3 seconds
    _typingTimer = Timer(const Duration(seconds: 3), () {
      // No need to send a "stopped typing" event, the server handles timeouts
    });
  }
  
  // Initiate a call
  void initiateCall(String callType) {
    if (!ensureInitialized()) {
      throw Exception('User information not set');
    }
    
    if (_currentConversationId == null || _otherUserType == null || _otherUserId == null) {
      throw Exception('No active conversation');
    }
    
    socketService.initiateCall(
      _currentConversationId!,
      _otherUserType!,
      _otherUserId!,
      callType,
    );
  }
  
  // Respond to a call
  void respondToCall(String callId, String response, String callerType, String callerId) {
    if (!ensureInitialized()) {
      throw Exception('User information not set');
    }
    
    socketService.respondToCall(callId, response, callerType, callerId);
  }
  
  // End a call
  void endCall(String callId, String otherType, String otherId) {
    if (!ensureInitialized()) {
      throw Exception('User information not set');
    }
    
    socketService.endCall(callId, otherType, otherId);
  }
  
  // Handle incoming events
  void _handleNewMessage(Map<String, dynamic> data) {
    if (userId == null) return;
    
    final message = ChatMessage.fromJson(data, userId!);
    final conversationId = message.conversationId;
    
    // Add message to the appropriate conversation
    if (_messages.containsKey(conversationId)) {
      _messages[conversationId]!.add(message);
    } else {
      _messages[conversationId] = [message];
    }
    
    // Update conversation list
    refreshConversations();
    
    // If this is the current conversation, mark as read
    if (_currentConversationId == conversationId) {
      markMessagesAsRead(conversationId);
    }
    
    notifyListeners();
  }
  
  void _handleMessagesRead(Map<String, dynamic> data) {
    final conversationId = data['conversationId'];
    
    if (_messages.containsKey(conversationId)) {
      final updatedMessages = _messages[conversationId]!.map((msg) {
        if (msg.isMine && !msg.isRead) {
          return msg.copyWith(isRead: true);
        }
        return msg;
      }).toList();
      
      _messages[conversationId] = updatedMessages;
      notifyListeners();
    }
  }
  
  void _handleUserTyping(Map<String, dynamic> data) {
    final conversationId = data['conversationId'];
    
    _typingUsers[conversationId] = true;
    notifyListeners();
    
    // Clear typing indicator after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _typingUsers[conversationId] = false;
      notifyListeners();
    });
  }
  
  // Clean up resources
  @override
  void dispose() {
    socketService.disconnect();
    _typingTimer?.cancel();
    super.dispose();
  }
}
