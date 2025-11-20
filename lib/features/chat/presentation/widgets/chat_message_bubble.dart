import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/chat_message.dart';

/// Widget for displaying a single chat message bubble
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == MessageRole.user;
    final isError = message.isError;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(theme, isError),
          const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(theme, isUser, isError),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isStreaming)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              message.content.isEmpty
                                  ? 'Thinking...'
                                  : message.content,
                              style: TextStyle(
                                color: _getTextColor(theme, isUser, isError),
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getTextColor(
                                  theme,
                                  isUser,
                                  isError,
                                ).withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        message.content,
                        style: TextStyle(
                          color: _getTextColor(theme, isUser, isError),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    if (!message.isStreaming) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: _getTextColor(
                            theme,
                            isUser,
                            isError,
                          ).withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (isError) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: _getTextColor(theme, isUser, isError),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Error',
                            style: TextStyle(
                              color: _getTextColor(theme, isUser, isError),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(theme, isError),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool isError) {
    final isUser = message.role == MessageRole.user;

    return CircleAvatar(
      radius: 16,
      backgroundColor: isError
          ? theme.colorScheme.error.withOpacity(0.1)
          : (isUser
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.secondary.withOpacity(0.1)),
      child: Icon(
        isUser
            ? Icons.person
            : (isError ? Icons.error_outline : Icons.restaurant),
        size: 18,
        color: isError
            ? theme.colorScheme.error
            : (isUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme, bool isUser, bool isError) {
    if (isError) {
      return theme.colorScheme.error.withOpacity(0.1);
    }
    if (isUser) {
      return theme.colorScheme.primary;
    }
    return theme.colorScheme.surfaceContainerHighest;
  }

  Color _getTextColor(ThemeData theme, bool isUser, bool isError) {
    if (isError) {
      return theme.colorScheme.error;
    }
    if (isUser) {
      return theme.colorScheme.onPrimary;
    }
    return theme.colorScheme.onSurface;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showMessageOptions(BuildContext context) {
    if (message.isStreaming) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy message'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
