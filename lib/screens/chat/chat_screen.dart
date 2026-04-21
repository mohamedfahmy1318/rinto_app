import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/chat_service.dart';
import '../../services/realtime_service.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String otherUserName;
  final String listingTitle;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.listingTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _otherUser;
  Map<String, dynamic>? _instructions;
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    RealtimeService.instance.clearCallbacks();
    super.dispose();
  }

  void _setupRealtimeListener() {
    RealtimeService.instance.startPolling();
    RealtimeService.instance.onNewChatMessage((data) {
      if (data['conversation_id'] == widget.conversationId) {
        final newMessage = data['message'] as Map<String, dynamic>?;
        if (newMessage != null && mounted) {
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
        }
      }
    });
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await ChatService.getMessages(widget.conversationId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _messages = List<Map<String, dynamic>>.from(
            response.data['messages'] ?? [],
          );
          _otherUser = response.data['other_user'];
          _instructions =
              response.data['instructions'] as Map<String, dynamic>?;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } else {
          _error = response.message;
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    // Optimistic update - add message immediately
    final tempMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'conversation_id': widget.conversationId,
      'sender_id': 0, // Will be replaced
      'message': message,
      'is_read': 0,
      'created_at': DateTime.now().toIso8601String(),
      'sender_name': '',
      'sender_image': null,
      '_pending': true,
    };

    setState(() {
      _messages.add(tempMessage);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    final response = await ChatService.sendMessage(
      conversationId: widget.conversationId,
      message: message,
    );

    if (mounted) {
      setState(() => _isSending = false);

      debugPrint(
        'Send message response: success=${response.success}, data=${response.data}, message=${response.message}',
      );

      if (response.success) {
        // Replace temp message with real one if data available
        if (response.data != null) {
          try {
            final messageData = response.data is Map<String, dynamic>
                ? response.data
                : Map<String, dynamic>.from(response.data as Map);
            setState(() {
              // Remove temp and add real
              _messages.removeWhere(
                (m) => m['_pending'] == true && m['message'] == message,
              );
              _messages.add(messageData);
            });
          } catch (e) {
            debugPrint('Error updating message: $e');
            // Keep temp message, just remove pending flag
            setState(() {
              final idx = _messages.indexWhere(
                (m) => m['_pending'] == true && m['message'] == message,
              );
              if (idx >= 0) {
                _messages[idx] = Map<String, dynamic>.from(_messages[idx])
                  ..remove('_pending');
              }
            });
          }
        } else {
          // No data but success - just remove pending flag
          setState(() {
            final idx = _messages.indexWhere(
              (m) => m['_pending'] == true && m['message'] == message,
            );
            if (idx >= 0) {
              _messages[idx] = Map<String, dynamic>.from(_messages[idx])
                ..remove('_pending');
            }
          });
        }
      } else {
        // Failed - remove temp message and show error
        setState(() {
          _messages.removeWhere(
            (m) => m['_pending'] == true && m['message'] == message,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message.isNotEmpty
                  ? response.message
                  : context.tr('message_failed'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        _messageController.text = message;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.otherUserName, style: const TextStyle(fontSize: 16)),
            if (widget.listingTitle.isNotEmpty)
              Text(
                widget.listingTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Instructions Banner
          if (_instructions != null && _getInstructionText().isNotEmpty)
            _buildInstructionsBanner(isDark),
          Expanded(
            child: _isLoading
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
                          onPressed: _loadMessages,
                          child: Text(context.tr('retry')),
                        ),
                      ],
                    ),
                  )
                : _messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index], isDark);
                    },
                  ),
          ),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(context.tr('start_conversation')),
          const SizedBox(height: 8),
          Text(
            '${context.tr('send_message_to')} ${widget.otherUserName}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _getInstructionText() {
    if (_instructions == null) return '';
    // Get instruction based on app language
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'en':
        return _instructions!['value_en'] ?? _instructions!['value_ar'] ?? '';
      case 'he':
        return _instructions!['value_he'] ?? _instructions!['value_ar'] ?? '';
      default:
        return _instructions!['value_ar'] ?? _instructions!['value_en'] ?? '';
    }
  }

  Widget _buildInstructionsBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.primary.withOpacity(0.08),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _getInstructionText(),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isDark) {
    final isMe =
        message['sender_id'].toString() != _otherUser?['id']?.toString();
    final messageText = message['message'] ?? '';
    final time = DateTime.tryParse(message['created_at'] ?? '');

    String timeStr = '';
    if (time != null) {
      timeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary
              : (isDark ? AppColors.darkCard : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              messageText,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? Colors.white70
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: context.tr('type_message'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
