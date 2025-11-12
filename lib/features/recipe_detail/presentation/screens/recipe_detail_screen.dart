import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../core/constants/recipe_categories.dart';

/// RecipeDetailScreen - Detailed view of a single recipe
///
/// Shows full recipe information including ingredients, instructions,
/// and allows toggling favorite status.
class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  final Set<int> _checkedIngredients = {};
  double _servingMultiplier = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoriteRecipes = ref.watch(favoriteRecipesProvider);
    final isFavorite = favoriteRecipes.any((r) => r.id == widget.recipe.id);
    final cuisine = RecipeCategoryHelper.detectCuisine(
      widget.recipe.name,
      widget.recipe.tags,
    );
    final difficulty = RecipeCategoryHelper.parseDifficulty(
      widget.recipe.difficulty,
    );
    final totalTime = widget.recipe.prepTime + widget.recipe.cookTime;

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
              ref
                  .read(favoriteRecipesProvider.notifier)
                  .toggleFavorite(widget.recipe);

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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'share') {
                _shareRecipe();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 12),
                    Text('Share Recipe'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recipe image header with gradient
          _buildImageHeader(cuisine, theme),
          const SizedBox(height: 16),

          // Recipe title
          Text(
            _stripMarkdown(widget.recipe.name),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          if (widget.recipe.description.isNotEmpty) ...[
            Text(
              widget.recipe.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Meta information cards
          Row(
            children: [
              Expanded(
                child: _buildMetaCard(
                  icon: Icons.schedule,
                  label: 'Total Time',
                  value: '$totalTime min',
                  color: theme.colorScheme.primary,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetaCard(
                  icon: RecipeCategoryHelper.getDifficultyIcon(difficulty),
                  label: 'Difficulty',
                  value: widget.recipe.difficulty,
                  color: RecipeCategoryHelper.getDifficultyColor(difficulty),
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetaCard(
                  icon: Icons.timer,
                  label: 'Prep Time',
                  value: '${widget.recipe.prepTime} min',
                  color: theme.colorScheme.secondary,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetaCard(
                  icon: Icons.local_fire_department,
                  label: 'Cook Time',
                  value: '${widget.recipe.cookTime} min',
                  color: Colors.orange,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tags
          if (widget.recipe.tags.isNotEmpty) ...[
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
              children: widget.recipe.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Ingredients section with serving adjuster
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ingredients',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildServingAdjuster(theme),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_checkedIngredients.length}/${widget.recipe.ingredients.length} checked',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (_servingMultiplier != 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Quantities adjusted ${_servingMultiplier}x',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.recipe.ingredients.asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final ingredient = entry.value;
                  final isChecked = _checkedIngredients.contains(index);
                  final adjustedIngredient = _adjustIngredientQuantity(
                    ingredient,
                    _servingMultiplier,
                  );

                  return CheckboxListTile(
                    value: isChecked,
                    onChanged: (checked) {
                      setState(() {
                        if (checked ?? false) {
                          _checkedIngredients.add(index);
                        } else {
                          _checkedIngredients.remove(index);
                        }
                      });
                    },
                    title: Text(
                      adjustedIngredient,
                      style: TextStyle(
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        color: isChecked
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Instructions section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Instructions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.recipe.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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

  Widget _buildImageHeader(RecipeCuisine cuisine, ThemeData theme) {
    final gradientColors = RecipeCategoryHelper.getCuisineGradient(cuisine);
    final cuisineIcon = RecipeCategoryHelper.getCuisineIcon(cuisine);
    final cuisineName = RecipeCategoryHelper.getCuisineName(cuisine);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              cuisineIcon,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cuisineIcon, size: 20, color: gradientColors.first),
                  const SizedBox(width: 8),
                  Text(
                    cuisineName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: gradientColors.first,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServingAdjuster(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _servingMultiplier > 0.5
                ? () {
                    setState(() {
                      _servingMultiplier -= 0.5;
                    });
                  }
                : null,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            '${_servingMultiplier}x',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _servingMultiplier < 4
                ? () {
                    setState(() {
                      _servingMultiplier += 0.5;
                    });
                  }
                : null,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  /// Adjust ingredient quantity based on serving multiplier
  String _adjustIngredientQuantity(String ingredient, double multiplier) {
    if (multiplier == 1.0) return ingredient;

    // Try to parse and adjust common quantity patterns
    // Pattern: "number unit rest" (e.g., "1 tablespoon olive oil")
    final numberPattern = RegExp(r'^(\d+\.?\d*|\d*/\d+)\s+(.+)$');
    final match = numberPattern.firstMatch(ingredient.trim());

    if (match != null) {
      final quantityStr = match.group(1)!;
      final rest = match.group(2)!;

      // Parse the quantity (handle fractions like "1/2")
      double quantity;
      if (quantityStr.contains('/')) {
        final parts = quantityStr.split('/');
        quantity = double.parse(parts[0]) / double.parse(parts[1]);
      } else {
        quantity = double.parse(quantityStr);
      }

      // Multiply
      final adjusted = quantity * multiplier;

      // Format the result nicely
      String formattedQuantity;
      if (adjusted == adjusted.toInt()) {
        formattedQuantity = adjusted.toInt().toString();
      } else {
        // Try to express as a fraction for common values
        if ((adjusted * 2) == (adjusted * 2).toInt()) {
          formattedQuantity = '${(adjusted * 2).toInt()}/2';
        } else if ((adjusted * 4) == (adjusted * 4).toInt()) {
          formattedQuantity = '${(adjusted * 4).toInt()}/4';
        } else {
          formattedQuantity = adjusted.toStringAsFixed(1);
        }
      }

      return '$formattedQuantity $rest';
    }

    // If we can't parse it, return original with a note
    return ingredient;
  }

  void _shareRecipe() {
    // For now, just show a message since share_plus is not in pubspec
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will be available soon!'),
      ),
    );

    // When share_plus is added to pubspec, use this:
    /*
    final text = '''
${widget.recipe.name}

${widget.recipe.description}

Ingredients:
${widget.recipe.ingredients.map((i) => '• $i').join('\n')}

Instructions:
${widget.recipe.instructions.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n\n')}

Prep Time: ${widget.recipe.prepTime} min | Cook Time: ${widget.recipe.cookTime} min
Difficulty: ${widget.recipe.difficulty}
''';
    Share.share(text, subject: widget.recipe.name);
    */
  }

  /// Strip common markdown formatting from text
  String _stripMarkdown(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!) // Bold
        .replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m.group(1)!) // Italic
        .replaceAllMapped(RegExp(r'__(.+?)__'), (m) => m.group(1)!) // Bold alt
        .replaceAllMapped(RegExp(r'_(.+?)_'), (m) => m.group(1)!) // Italic alt
        .replaceAllMapped(RegExp(r'`(.+?)`'), (m) => m.group(1)!) // Code
        .trim();
  }
}
