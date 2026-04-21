import '../services/api_service.dart';

class ChatService {
  /// Get all conversations for the current user
  static Future<ApiResponse> getConversations() async {
    return await ApiService.get('chat/conversations');
  }

  /// Get or create a conversation for a listing
  static Future<ApiResponse> getOrCreateConversation({
    required String listingType,
    required int listingId,
  }) async {
    return await ApiService.post(
      'chat/conversation',
      body: {'listing_type': listingType, 'listing_id': listingId},
    );
  }

  /// Get messages for a conversation
  static Future<ApiResponse> getMessages(
    int conversationId, {
    int page = 1,
  }) async {
    return await ApiService.get('chat/conversation/$conversationId?page=$page');
  }

  /// Send a message
  static Future<ApiResponse> sendMessage({
    required int conversationId,
    required String message,
  }) async {
    return await ApiService.post(
      'chat/send',
      body: {'conversation_id': conversationId, 'message': message},
    );
  }

  /// Get unread messages count
  static Future<ApiResponse> getUnreadCount() async {
    return await ApiService.get('chat/unread');
  }
}
