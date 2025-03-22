import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive notifications'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              if (_notificationsEnabled) ...[
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive email notifications'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
              ],
            ],
          ),
          _buildSection(
            title: 'Language',
            children: [
              ListTile(
                title: const Text('Language'),
                subtitle: Text(_selectedLanguage),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showLanguageDialog,
              ),
            ],
          ),
          _buildSection(
            title: 'Sound & Vibration',
            children: [
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Enable sound effects'),
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile Settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Navigate to profile settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Security'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Navigate to security settings
                },
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Show terms of service
                },
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages.map((language) {
                return ListTile(
                  title: Text(language),
                  trailing: language == _selectedLanguage
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
} 