import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/conversation.dart';
import 'package:submee/models/message.dart';
import 'package:submee/models/user.dart';

import '../network/dio_client.dart';
import '../providers/conversation_provider.dart';
import '../providers/environment_service.dart';

final conversationService = Provider<ConversationService>((ref) {
  final envService = ref.watch(environmentService);
  final client = ref.watch(dioClient);
  final service = ConversationService(
    baseUrl: envService.environment.baseApiUrl,
    client: client,
  );
  return service;
});

class ConversationService {
  ConversationService({
    required this.baseUrl,
    required this.client,
  });
  final DioClient client;
  final String baseUrl;

  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/conversation',
        cachePolicy: CachePolicy.request,
        requireAuth: true,
      );
      return (response.data!['data'] ?? [])
          .map((e) => ConversationModel.fromJson(e))
          .toList()
          .cast<ConversationModel>();
    } catch (e) {
      rethrow;
    }
  }

  Future<ConversationModel> getConversation(int id) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/conversation/$id',
        cachePolicy: CachePolicy.request,
        requireAuth: true,
      );
      if (response.data!['success'] != true) {
        throw Exception('Conversation not found');
      }
      return ConversationModel.fromJson(response.data!['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserSwipeInfoChat> getOtherUserConversation(UserChatParam param) async {
    try {
      String path = '/conversation';
      if (param.conversationId != null) {
        path += '/${param.conversationId}/other';
      } else if (param.propertyId != null) {
        path += '/property/${param.propertyId}/other';
      }
      final response = await client.get<Map<String, dynamic>>(
        path,
        cachePolicy: CachePolicy.request,
        requireAuth: true,
      );
      if (response.data!['success'] != true) {
        throw Exception('User not found');
      }
      final user = UserSwipeInfoChat.fromJson(response.data!['data']);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessages(int conversationId) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        '/conversation/$conversationId/messages',
        cachePolicy: CachePolicy.request,
        requireAuth: true,
      );

      return (response.data!['data'] ?? [])
          .map((e) => MessageModel.fromJson(e))
          .toList()
          .cast<MessageModel>();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String content,
    int? conversationId,
    int? propertyId,
    int? otherUserId,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'content': content,
      };

      // Add either conversationId or propertyId
      if (conversationId != null) {
        requestBody['conversation_id'] = conversationId;
      } else if (propertyId != null) {
        requestBody['property_id'] = propertyId;
        if (otherUserId != null) {
          requestBody['user_id'] = otherUserId;
        }
      }

      final response = await client.post<Map<String, dynamic>>(
        '/conversation/send',
        requireAuth: true,
        data: requestBody,
      );

      if (response.data!['success'] == true) {
        return response.data!['data']; // Contains message and conversation info
      } else {
        throw Exception(response.data!['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
