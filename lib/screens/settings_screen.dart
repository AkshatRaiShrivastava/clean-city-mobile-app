import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cleancity/services/auth_service.dart';
import 'package:cleancity/screens/auth/login_screen.dart';
import 'package:cleancity/services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final userData = authService.userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildSectionHeader(context, 'Profile'),
          _buildProfileCard(userData, authService),
          const SizedBox(height: 24),

          // General Settings
          _buildSectionHeader(context, 'General'),
          _buildSettingsCard(
            title: 'Notifications',
            subtitle: 'Receive alerts about your reports',
            icon: Icons.notifications,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          _buildSettingsCard(
            title: 'Location Services',
            subtitle: 'Allow app to access your location',
            icon: Icons.location_on,
            trailing: Switch(
              value: _locationEnabled,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
          ),
          _buildSettingsCard(
            title: 'Dark Mode',
            subtitle: 'Toggle dark theme',
            icon: themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            trailing: Switch(
              value: themeService.isDarkMode,
              onChanged: (value) {
                themeService.toggleTheme();
              },
            ),
          ),
          _buildSettingsCard(
            title: 'Language',
            subtitle: _language,
            icon: Icons.language,
            onTap: () {
              _showLanguageSelection();
            },
          ),
          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader(context, 'Support'),
          _buildSettingsCard(
            title: 'Help Center',
            subtitle: 'Get help with the app',
            icon: Icons.help,
            onTap: () {
              // Navigate to help center
            },
          ),
          _buildSettingsCard(
            title: 'Report a Problem',
            subtitle: 'Let us know about issues',
            icon: Icons.bug_report,
            onTap: () {
              // Navigate to problem reporting
            },
          ),
          _buildSettingsCard(
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            icon: Icons.privacy_tip,
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          _buildSettingsCard(
            title: 'Terms of Service',
            subtitle: 'Legal information',
            icon: Icons.description,
            onTap: () {
              // Navigate to terms of service
            },
          ),
          const SizedBox(height: 24),

          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildSettingsCard(
            title: 'About CleanCity',
            subtitle: 'Version 1.0.0',
            icon: Icons.info,
            onTap: () {
              // Show app info
            },
          ),
          _buildSettingsCard(
            title: 'Sign Out',
            icon: Icons.logout,
            isDestructive: true,
            onTap: () {
              _showSignOutConfirmation(authService);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      Map<String, dynamic>? userData, AuthService authService) {
    final name = userData?['name'] ?? 'User';
    final email = userData?['email'] ?? 'No email';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to profile edit screen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ??
            (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: const Text('English'),
                      trailing: _language == 'English'
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _language = 'English';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Hindi'),
                      trailing: _language == 'Hindi'
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _language = 'Hindi';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Spanish'),
                      trailing: _language == 'Spanish'
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _language = 'Spanish';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('French'),
                      trailing: _language == 'French'
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          _language = 'French';
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSignOutConfirmation(AuthService authService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
