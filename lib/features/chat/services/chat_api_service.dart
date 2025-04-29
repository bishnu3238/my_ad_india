import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/chat_models.dart';

class ChatApiService {
  static final ChatApiService _instance = ChatApiService._internal();
  factory ChatApiService() => _instance;
  ChatApiService._internal();

  late String _baseUrl = 'http://192.168.1.12:3000';
  String? _userId;
  String? _userType;

  String get baseUrl => baseUrl;

  void initialize(String baseUrl, {String? userId, String? userType}) {
    _baseUrl = baseUrl;
    _userId = userId;
    _userType = userType;
  }

  void updateUserInfo(String userId, String userType) {
    _userId = userId;
    _userType = userType;
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
    };
  }

  Future<List<Conversation>> getConversations() async {
    if (_userType == null || _userId == null) {
      throw Exception('User information not set');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/conversations/$_userType/$_userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['conversations'] != null) {
        return (data['conversations'] as List)
            .map((json) => Conversation.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load conversations: ${response.statusCode}');
    }
  }

  Future<List<ChatMessage>> getMessages(String conversationId, {int page = 1, int limit = 50}) async {
    if (_userId == null) {
      throw Exception('User information not set');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/messages/$conversationId?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['messages'] != null) {
        return (data['messages'] as List)
            .map((json) => ChatMessage.fromJson(json, _userId!))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  Future<String> uploadFile(File file) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/upload'));
    
    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();
    
    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      fileLength,
      filename: file.path.split('/').last,
      contentType: MediaType('application', 'octet-stream'),
    );
    
    request.files.add(multipartFile);
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['fileUrl'] != null) {
        return data['fileUrl'];
      } else {
        throw Exception('File upload failed: ${data['error']}');
      }
    } else {
      throw Exception('File upload failed: ${response.statusCode}');
    }
  }

  Future<List<CallLog>> getCallHistory() async {
    if (_userType == null || _userId == null) {
      throw Exception('User information not set');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/calls/$_userType/$_userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['calls'] != null) {
        return (data['calls'] as List)
            .map((json) => CallLog.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load call history: ${response.statusCode}');
    }
  }

  Future<List<Inquiry>> getInquiries(String merchantId, {String status = 'pending'}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/inquiries/merchant/$merchantId?status=$status'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['inquiries'] != null) {
        return (data['inquiries'] as List)
            .map((json) => Inquiry.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load inquiries: ${response.statusCode}');
    }
  }

  Future<bool> updateInquiryStatus(String inquiryId, String status) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/inquiries/$inquiryId'),
      headers: _headers,
      body: json.encode({'status': status}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Failed to update inquiry status: ${response.statusCode}');
    }
  }
  
  Future<String> createConversation(String customerId, String merchantId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/conversations'),
      headers: _headers,
      body: json.encode({
        'customerId': customerId,
        'merchantId': merchantId,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['conversationId'] != null) {
        return data['conversationId'].toString();
      } else {
        throw Exception('Failed to create conversation');
      }
    } else {
      throw Exception('Failed to create conversation: ${response.statusCode}');
    }
  }
}