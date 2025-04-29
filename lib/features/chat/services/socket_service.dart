import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_models.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  bool _isConnected = false;
  bool _isAuthenticated = false;
  String? _userId;
  String? _userType;

  // Stream controllers for different events
  final _onConnectController = StreamController<bool>.broadcast();
  final _onDisconnectController = StreamController<bool>.broadcast();
  final _onNewMessageController = StreamController<Map<String, dynamic>>.broadcast();
  final _onMessagesReadController = StreamController<Map<String, dynamic>>.broadcast();
  final _onUserTypingController = StreamController<Map<String, dynamic>>.broadcast();
  final _onUserStatusChangedController = StreamController<Map<String, dynamic>>.broadcast();
  final _onIncomingCallController = StreamController<Map<String, dynamic>>.broadcast();
  final _onCallResponseController = StreamController<Map<String, dynamic>>.broadcast();
  final _onCallEndedController = StreamController<Map<String, dynamic>>.broadcast();
  final _onNewInquiryController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams for UI to listen to
  Stream<bool> get onConnect => _onConnectController.stream;
  Stream<bool> get onDisconnect => _onDisconnectController.stream;
  Stream<Map<String, dynamic>> get onNewMessage => _onNewMessageController.stream;
  Stream<Map<String, dynamic>> get onMessagesRead => _onMessagesReadController.stream;
  Stream<Map<String, dynamic>> get onUserTyping => _onUserTypingController.stream;
  Stream<Map<String, dynamic>> get onUserStatusChanged => _onUserStatusChangedController.stream;
  Stream<Map<String, dynamic>> get onIncomingCall => _onIncomingCallController.stream;
  Stream<Map<String, dynamic>> get onCallResponse => _onCallResponseController.stream;
  Stream<Map<String, dynamic>> get onCallEnded => _onCallEndedController.stream;
  Stream<Map<String, dynamic>> get onNewInquiry => _onNewInquiryController.stream;

  bool get isConnected => _isConnected;
  bool get isAuthenticated => _isAuthenticated;

  void initialize(String serverUrl) {
    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socket.onConnect((_) {
      debugPrint('Socket connected');
      _isConnected = true;
      _onConnectController.add(true);
    });

    socket.onDisconnect((_) {
      debugPrint('Socket disconnected');
      _isConnected = false;
      _isAuthenticated = false;
      _onDisconnectController.add(true);
    });

    socket.on('authenticated', (data) {
      debugPrint('Socket authenticated: $data');
      if (data['success'] == true) {
        _isAuthenticated = true;
      }
    });

    socket.on('new_message', (data) {
      debugPrint('New message received: $data');
      _onNewMessageController.add(data);
    });

    socket.on('messages_read', (data) {
      debugPrint('Messages read: $data');
      _onMessagesReadController.add(data);
    });

    socket.on('user_typing', (data) {
      _onUserTypingController.add(data);
    });

    socket.on('user_status_changed', (data) {
      debugPrint('User status changed: $data');
      _onUserStatusChangedController.add(data);
    });

    socket.on('incoming_call', (data) {
      debugPrint('Incoming call: $data');
      _onIncomingCallController.add(data);
    });

    socket.on('call_response', (data) {
      debugPrint('Call response: $data');
      _onCallResponseController.add(data);
    });

    socket.on('call_ended', (data) {
      debugPrint('Call ended: $data');
      _onCallEndedController.add(data);
    });

    socket.on('new_inquiry', (data) {
      debugPrint('New inquiry: $data');
      _onNewInquiryController.add(data);
    });

    socket.onError((error) {
      debugPrint('Socket error: $error');
    });
  }

  void connect() {
    if (!_isConnected) {
      socket.connect();
    }
  }

  void disconnect() {
    if (_isConnected) {
      socket.disconnect();
      _isConnected = false;
      _isAuthenticated = false;
    }
  }

  void authenticate(String userId, String userType) {
    if (_isConnected) {
      _userId = userId;
      _userType = userType;
      socket.emit('authenticate', {
        'userType': userType,
        'userId': userId,
      });
    } else {
      debugPrint('Cannot authenticate: Socket not connected');
    }
  }

  void sendMessage(Map<String, dynamic> messageData) {
    if (_isConnected && _isAuthenticated) {
      socket.emit('send_message', messageData);
    } else {
      debugPrint('Cannot send message: Socket not connected or not authenticated');
    }
  }

  void markAsRead(String conversationId) {
    if (_isConnected && _isAuthenticated && _userType != null && _userId != null) {
      socket.emit('mark_as_read', {
        'conversationId': conversationId,
        'userType': _userType,
        'userId': _userId,
      });
    }
  }

  void sendTypingIndicator(String conversationId, String receiverType, String receiverId) {
    if (_isConnected && _isAuthenticated && _userType != null && _userId != null) {
      socket.emit('typing', {
        'conversationId': conversationId,
        'userType': _userType,
        'userId': _userId,
        'receiverType': receiverType,
        'receiverId': receiverId,
      });
    }
  }

  void initiateCall(String conversationId, String receiverType, String receiverId, String callType) {
    if (_isConnected && _isAuthenticated && _userType != null && _userId != null) {
      socket.emit('initiate_call', {
        'conversationId': conversationId,
        'callerType': _userType,
        'callerId': _userId,
        'receiverType': receiverType,
        'receiverId': receiverId,
        'callType': callType,
      });
    }
  }

  void respondToCall(String callId, String response, String callerType, String callerId) {
    if (_isConnected && _isAuthenticated && _userType != null && _userId != null) {
      socket.emit('call_response', {
        'callId': callId,
        'response': response,
        'receiverType': _userType,
        'receiverId': _userId,
        'callerType': callerType,
        'callerId': callerId,
      });
    }
  }

  void endCall(String callId, String otherType, String otherId) {
    if (_isConnected && _isAuthenticated && _userType != null && _userId != null) {
      socket.emit('end_call', {
        'callId': callId,
        'endedByType': _userType,
        'endedById': _userId,
        'otherType': otherType,
        'otherId': otherId,
      });
    }
  }

  void submitInquiry(String conversationId, String customerId, String merchantId, String inquiryText) {
    if (_isConnected && _isAuthenticated) {
      socket.emit('submit_inquiry', {
        'conversationId': conversationId,
        'customerId': customerId,
        'merchantId': merchantId,
        'inquiryText': inquiryText,
      });
    }
  }

  void dispose() {
    disconnect();
    _onConnectController.close();
    _onDisconnectController.close();
    _onNewMessageController.close();
    _onMessagesReadController.close();
    _onUserTypingController.close();
    _onUserStatusChangedController.close();
    _onIncomingCallController.close();
    _onCallResponseController.close();
    _onCallEndedController.close();
    _onNewInquiryController.close();
  }
}