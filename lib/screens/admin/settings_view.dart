import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              _buildThemeToggle(context),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.text_fields,
                title: 'Font Size',
                subtitle: 'Medium',
                onTap: () {
                  // TODO: Implement font size settings
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Notifications',
            [
              _buildSwitchTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: true,
                onChanged: (value) {
                  // TODO: Implement notification settings
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive email updates',
                value: true,
                onChanged: (value) {
                  // TODO: Implement email settings
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Data & Privacy',
            [
              _buildSettingTile(
                icon: Icons.backup,
                title: 'Data Backup',
                subtitle: 'Last backup: Today 10:00 AM',
                onTap: () {
                  // TODO: Implement backup settings
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.security,
                title: 'Security Settings',
                subtitle: 'Configure security options',
                onTap: () {
                  // TODO: Implement security settings
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                icon: Icons.delete_outline,
                title: 'Clear App Data',
                subtitle: 'Reset all settings and data',
                onTap: () => _showClearDataDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return _buildSwitchTile(
      icon: Icons.dark_mode,
      title: 'Dark Mode',
      subtitle: 'Toggle dark/light theme',
      value: themeProvider.isDarkMode,
      onChanged: (value) => themeProvider.toggleTheme(),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1);
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text(
          'Are you sure you want to clear all app data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear data functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App data cleared')),
              );
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
} 