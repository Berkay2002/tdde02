import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/services/gemini_ai_service.dart';
import '../../../../core/errors/rate_limit_exceptions.dart';
import '../../../../shared/providers/services_provider.dart';
import '../../data/models/chat_message.dart';
import 'chat_context_provider.dart';

/// State for chat conversation
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? streamingMessageId; // ID of message currently being streamed

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.streamingMessageId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? streamingMessageId,
    bool clearError = false,
    bool clearStreaming = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      streamingMessageId: clearStreaming
          ? null
          : (streamingMessageId ?? this.streamingMessageId),
    );
  }
}

/// Notifier for managing chat conversation
class ChatNotifier extends StateNotifier<ChatState> {
  final GeminiAIService _aiService;
  final String _userId;
  final Ref _ref;
  Box? _chatBox;

  ChatNotifier(this._aiService, this._userId, this._ref)
      : super(const ChatState()) {
    _initializeStorage();
  }

  /// Initialize Hive box for chat persistence
  Future<void> _initializeStorage() async {
    try {
      _chatBox = await Hive.openBox('chat_history');
      _loadChatHistory();
    } catch (e) {
      print('[ChatNotifier] Failed to initialize storage: $e');
    }
  }

  /// Load chat history from storage
  void _loadChatHistory() {
    if (_chatBox == null) return;

    try {
      final storedMessages = _chatBox!.get('messages_$_userId') as List?;
      if (storedMessages != null && storedMessages.isNotEmpty) {
        final messages = storedMessages
            .map((json) => ChatMessage.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();

        // Only load last 20 messages to avoid context bloat
        state = state.copyWith(
          messages: messages.length > 20
              ? messages.sublist(messages.length - 20)
              : messages,
        );
        print('[ChatNotifier] Loaded ${state.messages.length} messages from storage');
      }
    } catch (e) {
      print('[ChatNotifier] Failed to load chat history: $e');
    }
  }

  /// Save chat history to storage
  Future<void> _saveChatHistory() async {
    if (_chatBox == null) return;

    try {
      final jsonMessages = state.messages.map((m) => m.toJson()).toList();
      await _chatBox!.put('messages_$_userId', jsonMessages);
    } catch (e) {
      print('[ChatNotifier] Failed to save chat history: $e');
    }
  }

  /// Send a user message and get AI response
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Clear any previous errors
    state = state.copyWith(clearError: true);

    // Get current context from context provider
    final chatContext = _ref.read(chatContextProvider);

    // Create user message
    final userMessage = ChatMessage.user(
      content: content,
      attachedRecipeIds:
          chatContext.attachedRecipes?.map((r) => r.id).toList(),
    );

    // Add user message to state
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    // Save after adding user message
    await _saveChatHistory();

    // Create placeholder for streaming assistant response
    final assistantMessage = ChatMessage.assistant(
      content: '',
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, assistantMessage],
      streamingMessageId: assistantMessage.id,
    );

    try {
      // Build conversation history (last 10 messages for context)
      final history = state.messages
          .where((m) => !m.isStreaming && m.id != userMessage.id)
          .take(10)
          .map((m) => m.toHistoryEntry())
          .toList();

      // Stream the AI response
      final stream = _aiService.streamChatResponse(
        userMessage: content,
        userId: _userId,
        systemPrompt: chatContext.getSystemPrompt(),
        context: chatContext.toContextMap(),
        conversationHistory: history.isNotEmpty ? history : null,
      );

      String accumulatedContent = '';

      await for (final chunk in stream) {
        accumulatedContent += chunk;

        // Update the streaming message with accumulated content
        final updatedMessages = state.messages.map((m) {
          if (m.id == assistantMessage.id) {
            return m.copyWith(content: accumulatedContent);
          }
          return m;
        }).toList();

        state = state.copyWith(messages: updatedMessages);
      }

      // Finalize the message (no longer streaming)
      final finalMessages = state.messages.map((m) {
        if (m.id == assistantMessage.id) {
          return m.copyWith(isStreaming: false);
        }
        return m;
      }).toList();

      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
        clearStreaming: true,
      );

      // Save after completing response
      await _saveChatHistory();
    } on RateLimitException catch (e) {
      // Handle rate limit errors
      _handleError(e.userMessage);
    } catch (e) {
      // Handle other errors
      _handleError('Failed to get response: ${e.toString()}');
    }
  }

  /// Handle errors by adding error message and updating state
  void _handleError(String errorMessage) {
    // Remove the streaming placeholder message
    final messagesWithoutStreaming = state.messages
        .where((m) => m.id != state.streamingMessageId)
        .toList();

    // Add error message
    final errorMsg = ChatMessage.error(errorMessage);

    state = state.copyWith(
      messages: [...messagesWithoutStreaming, errorMsg],
      isLoading: false,
      error: errorMessage,
      clearStreaming: true,
    );
  }

  /// Clear chat history
  Future<void> clearChat() async {
    state = const ChatState();
    if (_chatBox != null) {
      await _chatBox!.delete('messages_$_userId');
    }
  }

  /// Delete a specific message
  void deleteMessage(String messageId) {
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != messageId).toList(),
    );
    _saveChatHistory();
  }

  @override
  void dispose() {
    _chatBox?.close();
    super.dispose();
  }
}

/// Provider for chat state
final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, userId) {
    final aiService = ref.watch(geminiAIServiceProvider);
    return ChatNotifier(aiService, userId, ref);
  },
);
