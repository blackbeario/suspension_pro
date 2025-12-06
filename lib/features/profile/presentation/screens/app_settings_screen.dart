import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/profile/domain/app_settings_notifier.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsNotifierProvider);
    final notifier = ref.read(appSettingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        children: [
          // Notifications Section
          // _buildSectionHeader('Notifications'),
          _buildSettingTile(
            context: context,
            icon: Icons.notifications_outlined,
            iconColor: Colors.orange,
            title: 'Push Notifications',
            subtitle: 'Receive updates and reminders',
            value: settings.pushNotificationsEnabled,
            onChanged: (value) => notifier.togglePushNotifications(value),
          ),

          const SizedBox(height: 8),

          // Community Section
          // _buildSectionHeader('Community'),
          _buildSettingTile(
            context: context,
            icon: Icons.photo_library_outlined,
            iconColor: Colors.blue,
            title: 'Auto-Download Photos',
            subtitle: 'Automatically download community setting photos',
            value: settings.autoDownloadCommunityPhotos,
            onChanged: (value) => notifier.toggleAutoDownloadCommunityPhotos(value),
          ),

          const SizedBox(height: 8),

          // Privacy Section
          // _buildSectionHeader('Privacy & Data'),
          _buildSettingTile(
            context: context,
            icon: Icons.analytics_outlined,
            iconColor: Colors.green,
            title: 'Analytics',
            subtitle: 'Help improve the app with usage data',
            value: settings.enableAnalytics,
            onChanged: (value) => notifier.toggleAnalytics(value),
          ),

          const SizedBox(height: 40),

          // Reset Settings Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(context, notifier),
              icon: const Icon(Icons.restore, color: Colors.red),
              label: const Text(
                'Reset to Defaults',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        trailing: Platform.isIOS
            ? CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeColor: iconColor,
              )
            : Switch(
                value: value,
                onChanged: onChanged,
                activeColor: iconColor,
              ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, AppSettingsNotifier notifier) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'Are you sure you want to reset all settings to their default values?',
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Reset'),
              isDestructiveAction: true,
              onPressed: () {
                notifier.resetToDefaults();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to defaults'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
