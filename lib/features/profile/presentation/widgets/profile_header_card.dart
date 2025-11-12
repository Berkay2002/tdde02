import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profile header card with avatar, user info, and quick stats
class ProfileHeaderCard extends ConsumerWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final userProfile = ref.watch(authNotifierProvider).value;
    final favorites = ref.watch(favoriteRecipesProvider);
    final pantryItems = ref.watch(pantryIngredientsProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar with gradient border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.surface,
                child: _buildAvatar(
                  user: user,
                  userProfile: userProfile,
                  theme: theme,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Display name
            if (userProfile?.displayName != null || user?.displayName != null)
              Text(
                userProfile?.displayName ?? user?.displayName ?? '',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (userProfile?.displayName != null || user?.displayName != null)
              const SizedBox(height: 4),

            // Email
            Text(
              user?.email ?? 'Guest User',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),

            // Member since date
            Text(
              'Member since ${_formatDate(user?.metadata.creationTime)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Divider
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(
                  count: favorites.length,
                  label: 'Recipes',
                  icon: Icons.restaurant_menu,
                  theme: theme,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                _StatColumn(
                  count: favorites.length,
                  label: 'Favorites',
                  icon: Icons.favorite,
                  theme: theme,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                _StatColumn(
                  count: pantryItems.length,
                  label: 'Pantry',
                  icon: Icons.kitchen,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildAvatar({
    required User? user,
    required dynamic userProfile,
    required ThemeData theme,
  }) {
    final avatarUrl = userProfile?.avatarUrl ?? user?.photoURL;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 37,
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {
          // Fallback handled by errorBuilder in Image widget
        },
        child: null,
      );
    }

    // Fallback to icon with initials
    final displayName = userProfile?.displayName ?? user?.displayName;
    final email = userProfile?.email ?? user?.email;

    String initials = 'U';
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(' ');
      if (parts.length >= 2) {
        initials = parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
      } else {
        initials = displayName[0].toUpperCase();
      }
    } else if (email != null && email.isNotEmpty) {
      initials = email[0].toUpperCase();
    }

    return CircleAvatar(
      radius: 37,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initials,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final ThemeData theme;

  const _StatColumn({
    required this.count,
    required this.label,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
