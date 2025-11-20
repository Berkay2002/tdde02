import 'package:flutter/material.dart';
import '../../data/models/recipe_reference.dart';

/// Widget for displaying an attached recipe in chat context (like ChatGPT attachments)
class RecipeContextChip extends StatelessWidget {
  final RecipeReference recipe;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const RecipeContextChip({
    super.key,
    required this.recipe,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recipe icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            // Recipe info
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.name,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (recipe.prepTime != null || recipe.cookTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 10,
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTotalTime(),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                          if (recipe.difficulty != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              _getDifficultyIcon(),
                              size: 10,
                              color: theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.difficulty!,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Remove button
            if (onRemove != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(
                      0.7,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTotalTime() {
    final total = (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0);
    if (total < 60) {
      return '${total}m';
    } else {
      final hours = total ~/ 60;
      final minutes = total % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  IconData _getDifficultyIcon() {
    switch (recipe.difficulty?.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'intermediate':
      case 'medium':
        return Icons.sentiment_neutral;
      case 'advanced':
      case 'hard':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
}
