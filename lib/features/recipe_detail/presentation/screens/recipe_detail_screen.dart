import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';

/// RecipeDetailScreen - Detailed view of a single recipe
/// 
/// Shows full recipe information including ingredients, instructions,
/// and allows toggling favorite status.
class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteRecipes = ref.watch(favoriteRecipesProvider);
    final isFavorite = favoriteRecipes.any((r) => r.id == recipe.id);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite 
                        ? 'Removed from favorites' 
                        : 'Added to favorites',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recipe title
          Text(
            _stripMarkdown(recipe.name),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          if (recipe.description.isNotEmpty) ...[
            Text(
              recipe.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Meta information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetaItem(
                    icon: Icons.schedule,
                    label: 'Prep',
                    value: '${recipe.prepTime} min',
                  ),
                  _buildMetaItem(
                    icon: Icons.timer,
                    label: 'Cook',
                    value: '${recipe.cookTime} min',
                  ),
                  _buildMetaItem(
                    icon: Icons.signal_cellular_alt,
                    label: 'Difficulty',
                    value: recipe.difficulty,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tags
          if (recipe.tags.isNotEmpty) ...[
            Text(
              'Tags',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recipe.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  avatar: const Icon(Icons.label, size: 16),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Ingredients section
          Text(
            'Ingredients',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: recipe.ingredients.map((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Instructions section
          Text(
            'Instructions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...recipe.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      radius: 16,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _stripMarkdown(instruction),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Strip common markdown formatting from text
  String _stripMarkdown(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!) // Bold
        .replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m.group(1)!)     // Italic
        .replaceAllMapped(RegExp(r'__(.+?)__'), (m) => m.group(1)!)     // Bold alt
        .replaceAllMapped(RegExp(r'_(.+?)_'), (m) => m.group(1)!)       // Italic alt
        .replaceAllMapped(RegExp(r'`(.+?)`'), (m) => m.group(1)!)       // Code
        .trim();
  }
}
