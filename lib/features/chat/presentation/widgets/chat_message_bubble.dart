import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
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
                            child: message.content.isEmpty
                                ? Text(
                                    'Thinking...',
                                    style: TextStyle(
                                      color: _getTextColor(
                                        theme,
                                        isUser,
                                        isError,
                                      ),
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  )
                                : MarkdownBody(
                                    data: message.content,
                                    selectable: true,
                                    styleSheet: _getMarkdownStyleSheet(
                                      theme,
                                      isUser,
                                      isError,
                                    ),
                                    onTapLink: (text, href, title) {
                                      if (href != null) {
                                        launchUrl(Uri.parse(href));
                                      }
                                    },
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
                      MarkdownBody(
                        data: message.content,
                        selectable: true,
                        styleSheet: _getMarkdownStyleSheet(
                          theme,
                          isUser,
                          isError,
                        ),
                        onTapLink: (text, href, title) {
                          if (href != null) {
                            launchUrl(Uri.parse(href));
                          }
                        },
                      ),
                    if (message.groundingMetadata != null)
                      _buildGroundingSources(
                        context,
                        message.groundingMetadata!,
                      ),
                    if (message.groundingMetadata != null &&
                        message.groundingMetadata!['searchEntryPoint'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: HtmlWidget(
                          message.groundingMetadata!['searchEntryPoint'],
                          onTapUrl: (url) async {
                            return await launchUrl(Uri.parse(url));
                          },
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

  MarkdownStyleSheet _getMarkdownStyleSheet(
    ThemeData theme,
    bool isUser,
    bool isError,
  ) {
    final textColor = _getTextColor(theme, isUser, isError);

    return MarkdownStyleSheet(
      p: TextStyle(color: textColor, fontSize: 15, height: 1.4),
      h1: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h2: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h3: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h4: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h5: TextStyle(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h6: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
      strong: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      code: TextStyle(
        color: textColor,
        fontSize: 14,
        fontFamily: 'monospace',
        backgroundColor: isUser
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.05),
      ),
      blockquote: TextStyle(
        color: textColor.withOpacity(0.8),
        fontSize: 15,
        fontStyle: FontStyle.italic,
      ),
      blockquotePadding: const EdgeInsets.only(left: 12),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: textColor.withOpacity(0.3), width: 3),
        ),
      ),
      codeblockPadding: const EdgeInsets.all(8),
      codeblockDecoration: BoxDecoration(
        color: isUser
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      listBullet: TextStyle(color: textColor, fontSize: 15),
      listIndent: 20,
      a: TextStyle(
        color: isUser
            ? Colors.white.withOpacity(0.9)
            : theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
    );
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

  Widget _buildGroundingSources(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    final chunks = metadata['groundingChunks'] as List?;
    if (chunks == null || chunks.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sources',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: chunks.map<Widget>((chunk) {
              final uri = chunk['uri'] as String?;
              final title = chunk['title'] as String? ?? 'Source';
              if (uri == null) return const SizedBox.shrink();

              return ActionChip(
                label: Text(title, style: const TextStyle(fontSize: 10)),
                avatar: const Icon(Icons.link, size: 12),
                onPressed: () => launchUrl(Uri.parse(uri)),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
