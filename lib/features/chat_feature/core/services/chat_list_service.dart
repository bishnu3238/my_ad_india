import '../../models/conversation.dart';
import 'api_client.dart';

class ChatListService {
  final ApiClient apiClient;

  ChatListService({required this.apiClient});

  Future<List<Conversation>> fetchConversations({
    required String userType,
    required int userId,
  }) async {
    try {
      return await apiClient.getConversations(userType, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteConversation(int conversationId) async {
    try {
      await apiClient.deleteConversation(conversationId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archiveConversation(int conversationId) async {
    try {
      await apiClient.archiveConversation(conversationId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> batchDelete(List<int> conversationIds) async {
    for (final id in conversationIds) {
      await deleteConversation(id);
    }
  }

  Future<void> batchArchive(List<int> conversationIds) async {
    for (final id in conversationIds) {
      await archiveConversation(id);
    }
  }
}
