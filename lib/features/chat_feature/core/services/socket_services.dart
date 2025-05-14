import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../models/models.dart';
import '../../../../core/data/api/api_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket _socket;
  bool isConnected = false;

  // Add fields to store last connection parameters
  String? _lastBaseUrl;
  String? _lastUserType;
  int? _lastUserId;
  String? _lastToken;

  final _isConnectingController = StreamController<bool>.broadcast();
  // Streams for events
  final _newMessageController = StreamController<Message>.broadcast();
  final _messageSentController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messagesReadController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _userTypingController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _callEventController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _callResponseController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _callEndedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _callMissedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _inquirySubmittedController = StreamController<Inquiry>.broadcast();
  final _inquiryStatusUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _userStatusController = StreamController<UserStatus>.broadcast();
  final _userStatusChangedController = StreamController<UserStatus>.broadcast();
  final _inactiveDisconnectController = StreamController<String>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<bool> get connectionStatus => _isConnectingController.stream;

  // Expose streams
  Stream<Message> get onNewMessage => _newMessageController.stream;
  Stream<Map<String, dynamic>> get onMessageSent =>
      _messageSentController.stream;
  Stream<Map<String, dynamic>> get onMessagesRead =>
      _messagesReadController.stream;
  Stream<Map<String, dynamic>> get onUserTyping => _userTypingController.stream;
  Stream<Map<String, dynamic>> get onCallEvent => _callEventController.stream;
  Stream<Map<String, dynamic>> get onCallResponse =>
      _callResponseController.stream;
  Stream<Map<String, dynamic>> get onCallEnded => _callEndedController.stream;
  Stream<Map<String, dynamic>> get onCallMissed => _callMissedController.stream;
  Stream<Inquiry> get onInquirySubmitted => _inquirySubmittedController.stream;
  Stream<Map<String, dynamic>> get onInquiryStatusUpdated =>
      _inquiryStatusUpdatedController.stream;
  Stream<UserStatus> get onUserStatus => _userStatusController.stream;
  Stream<UserStatus> get onUserStatusChanged =>
      _userStatusChangedController.stream;
  Stream<String> get onInactiveDisconnect =>
      _inactiveDisconnectController.stream;
  Stream<String> get onError => _errorController.stream;

  // Connect and authenticate
  Future<bool> connect({
    required String baseUrl,
    required String userType,
    required int userId,
    String? token,
  }) async {
    if (isConnected) return true;

    dev.log('TRY TO CONNECT TO SOCKET: $baseUrl FOR $userType ON $userId');

    _lastBaseUrl = baseUrl;
    _lastUserType = userType;
    _lastUserId = userId;
    _lastToken = token;

    final completer = Completer<bool>();

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders(
            token != null ? {'Authorization': 'Bearer $token'} : {},
          )
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) async {
      dev.log('Socket connected');
      _isConnectingController.add(true);
      isConnected = true;

      final authResult = await authenticate(baseUrl, userId, userType, token);
      completer.complete(authResult);
    });

    _socket.onConnectError((error) {
      dev.log('Socket connection error: $error');
      _errorController.add('Connection error: $error');
      completer.complete(false);
    });

    _socket.onDisconnect((_) {
      dev.log('Socket disconnected');
      isConnected = false;
      _isConnectingController.add(false);
    });

    _socket.on('connect', (_) {
      dev.log('Socket connected');
    });

    _socket.on('disconnect', (_) {
      dev.log('Socket disconnected');
    });

    _socket.on('connect_error', (error) {
      dev.log('Socket connection error: $error');
    });

    _socket.on('reconnect', (_) {
      dev.log('Socket reconnected');

      // Re-authenticate on reconnect
      authenticate(baseUrl, userId, userType, token);
      //_socket.emit('authenticate', {'userType': userType,'userId': userId.toString(),});
    });

    // --- Authentication events ---
    _socket.on('authenticated', (data) {
      dev.log("AUTHENTICATE: $data");
    });

    // --- Message events ---
    _socket.on('new_message', (data) {
      _newMessageController.add(Message.fromJson(data));
    });
    _socket.on('message_sent', (data) {
      _messageSentController.add(data);
    });
    _socket.on('messages_read', (data) {
      _messagesReadController.add(data);
    });
    _socket.on('mark_read_success', (data) {
      _messagesReadController.add(data);
    });
    _socket.on('user_typing', (data) {
      _userTypingController.add(data);
    });

    // --- Call events ---
    _socket.on('incoming_call', (data) {
      _callEventController.add(data);
    });
    _socket.on('call_initiated', (data) {
      _callEventController.add(data);
    });
    _socket.on('call_response', (data) {
      _callResponseController.add(data);
    });
    _socket.on('call_ended', (data) {
      _callEndedController.add(data);
    });
    _socket.on('call_end_success', (data) {
      _callEndedController.add(data);
    });
    _socket.on('call_missed', (data) {
      _callMissedController.add(data);
    });

    // --- Inquiry events ---
    _socket.on('inquiry_submitted', (data) {
      _inquirySubmittedController.add(
        Inquiry.fromJson(data['inquiry'] ?? data),
      );
    });
    _socket.on('inquiry_status_updated', (data) {
      _inquiryStatusUpdatedController.add(data);
    });

    // --- Status events ---
    _socket.on('user_status', (data) {
      _userStatusController.add(UserStatus.fromJson(data));
    });
    _socket.on('user_status_changed', (data) {
      dev.log('USER-AUTH-STATUS-CHANGE: %$data');
      _userStatusChangedController.add(UserStatus.fromJson(data));
    });

    // --- System events ---
    _socket.on('inactive_disconnect', (data) {
      _inactiveDisconnectController.add(
        data is String ? data : data['message'] ?? '',
      );
    });

    // --- Error events ---
    _socket.on('error', (data) {
      _errorController.add(
        data is String ? data : data['message'] ?? 'Unknown error',
      );
    });
    return completer.future;
  }

  Future<bool> authenticate(
    String baseUrl,
    int userId,
    String userType,
    String? token,
  ) async {
    if (!_socket.connected) {
      dev.log('Cannot authenticate: Socket not connected');
      // Try to connect if not connected
      connect(
        baseUrl: baseUrl,
        userType: userType,
        userId: userId,
        token: token,
      );
    }

    try {
      dev.log('Socket connected, authenticating...');
      _socket.emit('authenticate', {'userType': userType, 'userId': '$userId'});

      // Wait for authentication response
      Completer<bool> completer = Completer<bool>();

      // Set timeout
      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      // One-time listener for authentication response
      _socket.once('authenticated', (data) {
        dev.log('AUTHENTICATED: $data');
        if (!completer.isCompleted) {
          bool success = data['success'] == true;
          completer.complete(success);
        }
      });

      return await completer.future;
    } catch (e) {
      dev.log('Authentication error: $e');
      return false;
    }
  }

  bool checkConnection() {
    if (!isConnected) {
      _errorController.add('Socket not connected, attempting to reconnect...');
      // Call connect with saved parameters (store them in the class)
      connect(
        baseUrl: _lastBaseUrl ?? ApiConfig.socketUrl,
        userType: _lastUserType ?? 'customer',
        userId: _lastUserId ?? 1,
        token: _lastToken,
      );
      return false;
    }
    return true;
  }

  void disconnect() {
    _socket.dispose();
    isConnected = false;
  }

  // --- Emitters ---

  // Send message
  void sendMessage(Map<String, dynamic> data) {
    _socket.emit('send_message', data);
  }

  // Mark messages as read
  void markAsRead(Map<String, dynamic> data) {
    _socket.emit('mark_as_read', data);
  }

  // Typing indicator
  void sendTyping(Map<String, dynamic> data) {
    _socket.emit('typing', data);
  }

  // Call events
  void initiateCall(Map<String, dynamic> data) {
    _socket.emit('initiate_call', data);
  }

  void respondToCall(Map<String, dynamic> data) {
    _socket.emit('call_response', data);
  }

  void endCall(Map<String, dynamic> data) {
    _socket.emit('end_call', data);
  }

  // Inquiry events
  void submitInquiry(Map<String, dynamic> data) {
    _socket.emit('submit_inquiry', data);
  }

  void updateInquiryStatus(Map<String, dynamic> data) {
    _socket.emit('update_inquiry_status', data);
  }

  // Status events
  void getUserStatus(Map<String, dynamic> data) {
    _socket.emit('get_user_status', data);
  }

  void getOnlineUsers(Map<String, dynamic> data) {
    _socket.emit('get_online_users', data);
  }

  void userActivity() {
    _socket.emit('user_activity');
  }

  // --- Dispose all controllers ---
  void dispose() {
    _newMessageController.close();
    _messageSentController.close();
    _messagesReadController.close();
    _userTypingController.close();
    _callEventController.close();
    _callResponseController.close();
    _callEndedController.close();
    _callMissedController.close();
    _inquirySubmittedController.close();
    _inquiryStatusUpdatedController.close();
    _userStatusController.close();
    _userStatusChangedController.close();
    _inactiveDisconnectController.close();
    _errorController.close();
  }
}
