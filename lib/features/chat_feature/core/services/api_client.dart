import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_ad/core/data/api/api_config.dart';
import 'package:pack/services/service.dart';
import 'package:http_parser/http_parser.dart';
import '../../models/models.dart';
import '../../utils/file_helper.dart';

class ApiClient {
  final String baseUrl;
  String? _token;
  final ApiCallService _apiService;

  ApiClient({required this.baseUrl, ApiCallService? api})
    : _apiService = api ?? ApiCallService(baseUrl: ApiConfig.baseChatUrl);

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // --- Auth ---
  Future<String> login(String email, String password) async {
    // final config = RequestConfig(
    //   baseUrl: baseUrl,
    //   endpoint: '/login',
    //   method: RequestMethod.post,
    //   body: {'email': email, 'password': password},
    //   headers: _headers,
    // );
    // return _apiService
    //     .request(config: config, responseConverter: (data) => data)
    //     .then(
    //       (value) => value.fold(
    //         (failure) {
    //           dev.log("Login failed: ${failure.message}");
    //           return 'Login failed';
    //         },
    //         (result) {
    //           dev.log('LOGIN RESULT : $result');
    //           return 'token';
    //         },
    //       ),
    //     );

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    }
    throw Exception('Login failed: ${response.body}');
  }

  // --- Conversations ---
  Future<List<Conversation>> getConversations(
    String userType,
    int userId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/conversations/$userType/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      dev.log('GET-CONVERSATIONS: ${response.statusCode} ${response.body}');
      return (data['conversations'] as List)
          .map((e) => Conversation.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch conversations');
  }

  Future<int> createConversation(int customerId, int merchantId) async {
    dev.log('CREATE-CONVERSATION: $customerId $merchantId');
    final response = await http.post(
      Uri.parse('$baseUrl/api/conversations'),
      headers: _headers,
      body: jsonEncode({
        'customerId': '$customerId',
        'merchantId': '$merchantId',
      }),
    );
    dev.log('CREATE-CONVERSATION: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['conversationId'];
    }
    throw Exception('Failed to create conversation');
  }

  Future<Conversation> getConversationDetails(int conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/conversations/$conversationId/details'),
      headers: _headers,
    );
    dev.log('GET-CONVERSATION: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Conversation.fromJson(data['conversation']);
    }
    throw Exception('Failed to fetch conversation details');
  }

  // --- Messages ---
  Future<List<Message>> getMessages(
    int conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/messages/$conversationId?page=$page&limit=$limit',
      ),
      headers: _headers,
    );
    dev.log('GET-MESSAGES: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['messages'] as List)
          .map((e) => Message.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch messages');
  }

  Future<Message> sendMessage(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/messages'),
      headers: _headers,
      body: jsonEncode(data),
    );
    dev.log('SEND-MESSAGE: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final res = jsonDecode(response.body);
      return Message.fromJson(res['message']);
    }
    throw Exception('Failed to send message');
  }

  Future<void> markMessagesAsRead(
    int conversationId,
    String userType,
    int userId,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/messages/$conversationId/read'),
      headers: _headers,
      body: jsonEncode({'userType': userType, 'userId': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark messages as read');
    }
  }

  Future<int> getUnreadMessageCount(String userType, int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/messages/unread/$userType/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'];
    }
    throw Exception('Failed to fetch unread message count');
  }

  // --- Calls ---
  Future<List<Call>> getCallHistory(
    int conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/calls/history/$conversationId?page=$page&limit=$limit',
      ),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['calls'] as List).map((e) => Call.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch call history');
  }

  Future<Call> getCallDetails(int callId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/calls/$callId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Call.fromJson(data['call']);
    }
    throw Exception('Failed to fetch call details');
  }

  Future<Call> logCall(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/calls'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      final res = jsonDecode(response.body);
      return Call.fromJson(res['call']);
    }
    throw Exception('Failed to log call');
  }

  Future<Call> updateCallStatus(int callId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/calls/$callId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Call.fromJson(data['call']);
    }
    throw Exception('Failed to update call status');
  }

  Future<Call> endCall(int callId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/calls/$callId/end'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Call.fromJson(data['call']);
    }
    throw Exception('Failed to end call');
  }

  // --- Inquiries ---
  Future<Inquiry> submitInquiry(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inquiries'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      final res = jsonDecode(response.body);
      return Inquiry.fromJson(res['inquiry']);
    }
    throw Exception('Failed to submit inquiry');
  }

  Future<List<Inquiry>> getMerchantInquiries(
    int merchantId, {
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final url =
        '$baseUrl/api/inquiries/merchant/$merchantId'
        '?${status != null ? 'status=$status&' : ''}page=$page&limit=$limit';
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['inquiries'] as List)
          .map((e) => Inquiry.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch merchant inquiries');
  }

  Future<List<Inquiry>> getCustomerInquiries(
    int customerId, {
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final url =
        '$baseUrl/api/inquiries/customer/$customerId'
        '?${status != null ? 'status=$status&' : ''}page=$page&limit=$limit';
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['inquiries'] as List)
          .map((e) => Inquiry.fromJson(e))
          .toList();
    }
    throw Exception('Failed to fetch customer inquiries');
  }

  Future<Inquiry> getInquiryById(int inquiryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/inquiries/$inquiryId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Inquiry.fromJson(data['inquiry']);
    }
    throw Exception('Failed to fetch inquiry');
  }

  Future<Inquiry> updateInquiryStatus(
    int inquiryId,
    String status, {
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/inquiries/$inquiryId/status'),
      headers: _headers,
      body: jsonEncode({'status': status, if (notes != null) 'notes': notes}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Inquiry.fromJson(data['inquiry']);
    }
    throw Exception('Failed to update inquiry status');
  }

  Future<Map<String, dynamic>> getInquiryCounts(
    String userType,
    int userId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/inquiries/counts/$userType/$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['counts'];
    }
    throw Exception('Failed to fetch inquiry counts');
  }

  // --- File Uploads ---
  Future<String> uploadFile(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/upload/single'),
    );
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    final mimeType = FileHelper.getMimeType(file.path);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(mimeType),
      ),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['file']['url'];
    }
    throw Exception('File upload failed');
  }

  Future<List<String>> uploadFiles(List<File> files) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/upload/multiple'),
    );
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    for (final file in files) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['files'] as List).map((f) => f['url'] as String).toList();
    }
    throw Exception('Multiple file upload failed');
  }

  Future<void> deleteFile(String filename) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/upload/$filename'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete file');
    }
  }

  Future<void> deleteConversation(int conversationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/conversations/$conversationId'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete conversation');
    }
  }

  Future<void> archiveConversation(int conversationId) async {
    // For this API, archive is the same as delete (soft delete)
    await deleteConversation(conversationId);
  }
}
