import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await ChatService.getConversations();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _conversations = List<Map<String, dynamic>>.from(
            response.data['conversations'] ?? [],
          );
        } else {
          _error = response.message;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('messages')), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadConversations,
                    child: Text(context.tr('retry')),
                  ),
                ],
              ),
            )
          : _conversations.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadConversations,
              child: ListView.builder(
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  return _buildConversationItem(_conversations[index], isDark);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('no_conversations'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('no_conversations_hint'),
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(
    Map<String, dynamic> conversation,
    bool isDark,
  ) {
    final unreadCount = conversation['unread_count'] ?? 0;
    final lastMessage = conversation['last_message'] ?? '';
    final lastMessageTime = conversation['last_message_time'];
    final otherUserName = conversation['other_user_name'] ?? context.tr('user');
    final listingTitle = conversation['listing_title'] ?? '';
    final listingImage = conversation['listing_image'];

    String timeAgo = '';
    if (lastMessageTime != null) {
      final time = DateTime.tryParse(lastMessageTime);
      if (time != null) {
        final diff = DateTime.now().difference(time);
        if (diff.inMinutes < 1) {
          timeAgo = context.tr('now');
        } else if (diff.inHours < 1) {
          timeAgo = '${diff.inMinutes} د';
        } else if (diff.inDays < 1) {
          timeAgo = '${diff.inHours} س';
        } else if (diff.inDays < 7) {
          timeAgo = '${diff.inDays} ي';
        } else {
          timeAgo = '${time.day}/${time.month}';
        }
      }
    }

    return ListTile(
      onTap: () {
        final convId = conversation['id'] is int
            ? conversation['id']
            : int.tryParse(conversation['id'].toString()) ?? 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: convId,
              otherUserName: otherUserName,
              listingTitle: listingTitle,
            ),
          ),
        ).then((_) => _loadConversations());
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: listingImage != null && listingImage.isNotEmpty
                ? NetworkImage(listingImage)
                : null,
            child: listingImage == null || listingImage.isEmpty
                ? Icon(
                    conversation['listing_type'] == 'car'
                        ? Icons.directions_car
                        : Icons.apartment,
                    color: AppColors.primary,
                  )
                : null,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherUserName,
              style: TextStyle(
                fontWeight: unreadCount > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (timeAgo.isNotEmpty)
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: unreadCount > 0 ? AppColors.primary : Colors.grey,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (listingTitle.isNotEmpty)
            Text(
              listingTitle,
              style: TextStyle(fontSize: 12, color: AppColors.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            lastMessage,
            style: TextStyle(
              color: unreadCount > 0
                  ? (isDark ? Colors.white : Colors.black87)
                  : Colors.grey,
              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
