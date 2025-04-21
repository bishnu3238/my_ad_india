import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import 'i_chat_service.dart';

class ChatService implements IChatService {
  // API endpoints
  static const String _baseUrl = ApiConfig.baseChatUrl;
  static const String _socketUrl = ApiConfig.socketUrl;

  // Socket instance
  io.Socket? _socket;

  // User ID
  String? _userId;

  @override
  String? get currentUserId => _userId;

  // Stream controllers
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _messageStatusController = StreamController<ChatMessage>.broadcast();

  // Connection status
  bool _isConnected = false;

  @override
  Future<void> initialize(String userId) async {
    _userId = userId;
    await connect(userId);
  }

  @override
  Future<bool> connect(String userId) async {
    try {
      // Initialize socket connection
      _socket = io.io(_socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'query': {'userId': _userId},
      });

      // Socket event handlers
      _socket!.onConnect((_) {
        dev.log('Socket connected');
        _isConnected = true;
        _connectionController.add(true);
      });

      _socket!.onDisconnect((_) {
        dev.log('Socket disconnected');
        _isConnected = false;
        _connectionController.add(false);
      });

      _socket!.onError((error) {
        dev.log('Socket error: $error');
        _isConnected = false;
        _connectionController.add(false);
      });

      // Listen for new messages
      _socket!.on('message', (data) {
        dev.log('message = $data');
        final message = ChatMessage.fromJson(data);
        _messageController.add(message);
      });

      // Listen for typing indicators
      _socket!.on('typing', (data) {
        dev.log('Typing : $data');
        _typingController.add(data);
      });

      // Listen for message status updates
      _socket!.on('messageStatus', (data) {
        dev.log("MESSAGE STATUS = $data");
        final message = ChatMessage.fromJson(data);
        _messageStatusController.add(message);
      });

      // Connect to socket server
      _socket!.connect();

      return true;
    } catch (e) {
      dev.log('Error connecting to socket: $e');
      _isConnected = false;
      _connectionController.add(false);
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    _socket?.disconnect();
    _isConnected = false;
    _connectionController.add(false);
  }

  @override
  Future<List<ChatConversation>> getConversations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations?userId=$_userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatConversation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      throw Exception('Failed to load conversations: $e');
    }
  }

  @override
  Future<ChatConversation> getConversation(String conversationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/$conversationId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatConversation.fromJson(data);
      } else {
        throw Exception('Failed to load conversation: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting conversation: $e');
      throw Exception('Failed to load conversation: $e');
    }
  }

  @override
  Future<ChatConversation> createConversation(
    String userId,
    String merchantId,
    String merchantName,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/conversations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': _userId,
          'merchantId': merchantId,
          'merchantName': merchantName,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ChatConversation.fromJson(data);
      } else {
        throw Exception(
          'Failed to create conversation: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      throw Exception('Failed to create conversation: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/conversations/$conversationId/messages?limit=$limit&offset=$offset',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting messages: $e');
      throw Exception('Failed to load messages: $e');
    }
  }

  @override
  Future<ChatMessage> sendMessage(
    String conversationId,
    String content,
    MessageType type, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create a temporary message with a local ID
      final tempId = const Uuid().v4();
      final tempMessage = ChatMessage(
        id: tempId,
        senderId: _userId!,
        receiverId: '', // Will be filled by the server
        content: content,
        type: type,
        status: MessageStatus.sending,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      // Emit message through socket for real-time delivery
      _socket?.emit('sendMessage', {
        'conversationId': conversationId,
        'message': tempMessage.toJson(),
      });

      // Also send via HTTP for reliability
      final response = await http.post(
        Uri.parse('$_baseUrl/conversations/$conversationId/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': _userId,
          'content': content,
          'type': type.toString().split('.').last,
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ChatMessage.fromJson(data);
      } else {
        // If HTTP request fails, update the temp message status to failed
        final failedMessage = tempMessage.copyWith(
          status: MessageStatus.failed,
        );
        _messageController.add(failedMessage);
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'userId': _userId,
      'isTyping': isTyping,
    });
  }

  @override
  Future<void> markMessagesAsRead(
    String conversationId,
    List<String> messageIds,
  ) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/conversations/$conversationId/messages/read'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'messageIds': messageIds, 'userId': _userId}),
      );

      // Also emit through socket for real-time updates
      _socket?.emit('markAsRead', {
        'conversationId': conversationId,
        'messageIds': messageIds,
        'userId': _userId,
      });
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<void> deleteMessages(
    String conversationId,
    List<String> messageIds,
  ) async {
    try {
      await http.delete(
        Uri.parse('$_baseUrl/conversations/$conversationId/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'messageIds': messageIds, 'userId': _userId}),
      );

      // Also emit through socket for real-time updates
      _socket?.emit('deleteMessages', {
        'conversationId': conversationId,
        'messageIds': messageIds,
        'userId': _userId,
      });
    } catch (e) {
      debugPrint('Error deleting messages: $e');
      throw Exception('Failed to delete messages: $e');
    }
  }

  @override
  Future<String> uploadFile(
    String conversationId,
    String filePath,
    MessageType type,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['conversationId'] = conversationId;
      request.fields['userId'] = _userId!;
      request.fields['type'] = type.toString().split('.').last;

      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['fileUrl'];
      } else {
        throw Exception('Failed to upload file: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  @override
  bool isConnected() {
    return _isConnected;
  }

  @override
  Stream<ChatMessage> onMessageReceived() {
    return _messageController.stream;
  }

  @override
  Stream<Map<String, dynamic>> onTypingIndicator() {
    return _typingController.stream;
  }

  @override
  Stream<bool> onConnectionStatusChanged() {
    return _connectionController.stream;
  }

  @override
  Stream<ChatMessage> onMessageStatusChanged() {
    return _messageStatusController.stream;
  }

  // Dispose resources
  void dispose() {
    _socket?.disconnect();
    _messageController.close();
    _typingController.close();
    _connectionController.close();
    _messageStatusController.close();
  }
}
