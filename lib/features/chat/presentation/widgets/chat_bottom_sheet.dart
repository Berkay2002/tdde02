import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/firebase_provider.dart';
import '../../data/models/recipe_reference.dart';
import '../providers/chat_provider.dart';
import 'chat_message_bubble.dart';
import 'chat_input_field.dart';

/// Bottom sheet for chat interface
class ChatBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final List<RecipeReference>? availableRecipes;

  const ChatBottomSheet({
    super.key,
    this.title = 'AI Chef Assistant',
    this.availableRecipes,
  });

  @override
  ConsumerState<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends ConsumerState<ChatBottomSheet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(firebaseAuthProvider);
    final userId = auth.currentUser?.uid ?? 'anonymous';
    final chatState = ref.watch(chatProvider(userId));

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatState.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, theme, userId),

          // Messages list
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return ChatMessageBubble(message: message);
                    },
                  ),
          ),

          // Loading indicator
          if (chatState.isLoading &&
              !chatState.messages.any((m) => m.isStreaming))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Thinking...',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Input field
          ChatInputField(
            onSendMessage: (message) {
              ref.read(chatProvider(userId).notifier).sendMessage(message);
            },
            availableRecipes: widget.availableRecipes ?? [],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, String userId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Chef icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Powered by Gemini AI',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Clear chat button
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            onPressed: () {
              _showClearConfirmation(context, userId);
            },
            tooltip: 'Clear chat',
          ),
          // Close button
          IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about recipes, cooking tips,\ningredient substitutions, and more!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            _buildSuggestionChips(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(ThemeData theme) {
    final suggestions = [
      'What can I make with chicken?',
      'How do I know if my pasta is al dente?',
      'Vegetarian dinner ideas',
      'Best way to store herbs',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return ActionChip(
          label: Text(suggestion),
          onPressed: () {
            final auth = ref.read(firebaseAuthProvider);
            final userId = auth.currentUser?.uid ?? 'anonymous';
            ref.read(chatProvider(userId).notifier).sendMessage(suggestion);
          },
          backgroundColor: theme.colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }

  void _showClearConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear chat history?'),
        content: const Text(
          'This will delete all messages in this conversation. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(chatProvider(userId).notifier).clearChat();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat history cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show chat bottom sheet
void showChatBottomSheet(
  BuildContext context, {
  String title = 'AI Chef Assistant',
  List<RecipeReference>? availableRecipes,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        ChatBottomSheet(title: title, availableRecipes: availableRecipes),
  );
}
