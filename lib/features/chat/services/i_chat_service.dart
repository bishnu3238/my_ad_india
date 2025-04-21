import '../models/chat_conversation.dart';
import '../models/chat_message.dart';

abstract class IChatService {
  String? get currentUserId;
  /// Initialize the chat service and establish connection
  Future<void> initialize(String userId);
  
  /// Connect to the chat server
  Future<bool> connect(String userId);
  
  /// Disconnect from the chat server
  Future<void> disconnect();
  
  /// Get all conversations for the current user
  Future<List<ChatConversation>> getConversations(String userId);
  
  /// Get a specific conversation by ID
  Future<ChatConversation> getConversation(String conversationId);
  
  /// Create a new conversation with a merchant
  Future<ChatConversation> createConversation(String userID,  String merchantId, String merchantName);
  
  /// Get messages for a specific conversation
  Future<List<ChatMessage>> getMessages(String conversationId, {int limit = 50, int offset = 0});
  
  /// Send a message
  Future<ChatMessage> sendMessage(String conversationId, String content, MessageType type, {Map<String, dynamic>? metadata});
  
  /// Send typing indicator
  Future<void> sendTypingIndicator(String conversationId, bool isTyping);
  
  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, List<String> messageIds);
  
  /// Delete messages
  Future<void> deleteMessages(String conversationId, List<String> messageIds);
  
  /// Upload file (image, audio, video, document)
  Future<String> uploadFile(String conversationId, String filePath, MessageType type);
  
  /// Check connection status
  bool isConnected();
  
  /// Listen for new messages
  Stream<ChatMessage> onMessageReceived();
  
  /// Listen for typing indicators
  Stream<Map<String, dynamic>> onTypingIndicator();
  
  /// Listen for connection status changes
  Stream<bool> onConnectionStatusChanged();
  
  /// Listen for message status updates
  Stream<ChatMessage> onMessageStatusChanged();
}
