import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/recipe_reference.dart';
import '../providers/chat_context_provider.dart';
import 'recipe_context_chip.dart';

/// Widget for chat message input with @recipe mention support
class ChatInputField extends ConsumerStatefulWidget {
  final Function(String) onSendMessage;
  final List<RecipeReference> availableRecipes; // Favorites for autocomplete

  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.availableRecipes = const [],
  });

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showRecipeDropdown = false;
  List<RecipeReference> _filteredRecipes = [];
  int _cursorPosition = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    _cursorPosition = _controller.selection.base.offset;

    // Check if user typed @recipe
    if (text.contains('@recipe')) {
      final lastAtIndex = text.lastIndexOf('@recipe', _cursorPosition);
      if (lastAtIndex != -1) {
        final searchQuery = text
            .substring(lastAtIndex + 7, _cursorPosition)
            .trim()
            .toLowerCase();

        setState(() {
          _showRecipeDropdown = true;
          _filteredRecipes = widget.availableRecipes
              .where(
                (recipe) => recipe.name.toLowerCase().contains(searchQuery),
              )
              .take(5)
              .toList();
        });
        return;
      }
    }

    // Hide dropdown if no @recipe
    if (_showRecipeDropdown) {
      setState(() {
        _showRecipeDropdown = false;
      });
    }
  }

  void _selectRecipe(RecipeReference recipe) {
    // Add recipe to context
    ref.read(chatContextProvider.notifier).addRecipeReference(recipe);

    // Remove @recipe from text
    final text = _controller.text;
    final lastAtIndex = text.lastIndexOf('@recipe', _cursorPosition);
    if (lastAtIndex != -1) {
      final before = text.substring(0, lastAtIndex);
      final after = text.substring(_cursorPosition);
      _controller.text = before + after;
      _controller.selection = TextSelection.collapsed(offset: before.length);
    }

    setState(() {
      _showRecipeDropdown = false;
    });

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${recipe.name}" to context'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(text);
    _controller.clear();

    // Clear attached recipes after sending
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(chatContextProvider.notifier).clearAttachedRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatContext = ref.watch(chatContextProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show attached recipes
        if (chatContext.attachedRecipes != null &&
            chatContext.attachedRecipes!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Attached recipes:',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: chatContext.attachedRecipes!
                      .map(
                        (recipe) => RecipeContextChip(
                          recipe: recipe,
                          onRemove: () {
                            ref
                                .read(chatContextProvider.notifier)
                                .removeRecipeReference(recipe.id);
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

        // Recipe dropdown
        if (_showRecipeDropdown && _filteredRecipes.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor, width: 1),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _filteredRecipes[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.restaurant_menu,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  title: Text(
                    recipe.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: recipe.description != null
                      ? Text(
                          recipe.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                  onTap: () => _selectRecipe(recipe),
                );
              },
            ),
          ),

        // Input field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // @recipe button
                IconButton(
                  icon: Icon(
                    Icons.alternate_email,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    final currentText = _controller.text;
                    final cursorPos = _controller.selection.base.offset;
                    final newText =
                        '${currentText.substring(0, cursorPos)}@recipe ${currentText.substring(cursorPos)}';
                    _controller.text = newText;
                    _controller.selection = TextSelection.collapsed(
                      offset: cursorPos + 8,
                    );
                    _focusNode.requestFocus();
                  },
                  tooltip: 'Mention a recipe',
                ),
                const SizedBox(width: 8),
                // Text field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
