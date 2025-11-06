import 'package:flutter/material.dart';

/// Profile screen - user preferences and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Guest User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Using offline mode',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Settings sections
          _buildSettingsSection(
            context,
            title: 'Preferences',
            items: [
              _SettingsItem(
                icon: Icons.restaurant,
                title: 'Dietary Restrictions',
                subtitle: 'None',
                onTap: () {
                  // TODO: Navigate to dietary restrictions
                },
              ),
              _SettingsItem(
                icon: Icons.public,
                title: 'Cuisine Preferences',
                subtitle: 'All cuisines',
                onTap: () {
                  // TODO: Navigate to cuisine preferences
                },
              ),
              _SettingsItem(
                icon: Icons.emoji_events,
                title: 'Skill Level',
                subtitle: 'Beginner',
                onTap: () {
                  // TODO: Navigate to skill level
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSettingsSection(
            context,
            title: 'App Settings',
            items: [
              _SettingsItem(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: 'Light',
                onTap: () {
                  // TODO: Theme settings
                },
              ),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Enabled',
                onTap: () {
                  // TODO: Notification settings
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSettingsSection(
            context,
            title: 'About',
            items: [
              _SettingsItem(
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              _SettingsItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help',
                onTap: () {
                  // TODO: Help screen
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Card(
          child: Column(
            children: items
                .map((item) => _buildSettingsTile(context, item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(BuildContext context, _SettingsItem item) {
    return ListTile(
      leading: Icon(item.icon, color: Theme.of(context).colorScheme.primary),
      title: Text(item.title),
      subtitle: Text(item.subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: item.onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'AI Recipe Generator',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.restaurant_menu,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text(
          'An AI-powered recipe generator that analyzes your fridge contents '
          'and creates personalized recipes using on-device machine learning.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• On-device AI processing\n'
          '• Offline functionality\n'
          '• Personalized recipes\n'
          '• Privacy-focused',
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
