/// Role of the message sender
enum MessageRole {
  user,
  assistant;

  String toJson() => name;

  static MessageRole fromJson(String value) {
    return MessageRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => MessageRole.user,
    );
  }
}

/// Represents a single chat message in the conversation
class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<String>? attachedRecipeIds; // References to recipes in context
  final bool isStreaming; // True while AI is still generating
  final bool isError; // True if message represents an error
  final Map<String, dynamic>? groundingMetadata; // Google Search grounding data

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.attachedRecipeIds,
    this.isStreaming = false,
    this.isError = false,
    this.groundingMetadata,
  });

  /// Create a user message
  factory ChatMessage.user({
    required String content,
    List<String>? attachedRecipeIds,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
      attachedRecipeIds: attachedRecipeIds,
    );
  }

  /// Create an assistant message
  factory ChatMessage.assistant({
    required String content,
    bool isStreaming = false,
    Map<String, dynamic>? groundingMetadata,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      isStreaming: isStreaming,
      groundingMetadata: groundingMetadata,
    );
  }

  /// Create an error message
  factory ChatMessage.error(String errorMessage) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: errorMessage,
      timestamp: DateTime.now(),
      isError: true,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toJson(),
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'attachedRecipeIds': attachedRecipeIds,
      'isStreaming': isStreaming,
      'isError': isError,
      'groundingMetadata': groundingMetadata,
    };
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachedRecipeIds: (json['attachedRecipeIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isStreaming: json['isStreaming'] as bool? ?? false,
      isError: json['isError'] as bool? ?? false,
      groundingMetadata: json['groundingMetadata'] as Map<String, dynamic>?,
    );
  }

  /// Create a copy with updated fields
  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    List<String>? attachedRecipeIds,
    bool? isStreaming,
    bool? isError,
    Map<String, dynamic>? groundingMetadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      attachedRecipeIds: attachedRecipeIds ?? this.attachedRecipeIds,
      isStreaming: isStreaming ?? this.isStreaming,
      isError: isError ?? this.isError,
      groundingMetadata: groundingMetadata ?? this.groundingMetadata,
    );
  }

  /// Convert to simple map for API calls (conversation history)
  Map<String, String> toHistoryEntry() {
    return {'role': role.name, 'content': content};
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: ${role.name}, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }
}
