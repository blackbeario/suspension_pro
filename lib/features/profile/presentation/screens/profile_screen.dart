import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suspension_pro/views/roadmap/app_roadmap.dart';
import 'package:suspension_pro/features/auth/domain/user_notifier.dart';
import 'package:suspension_pro/features/auth/presentation/auth_view_model.dart';
import 'package:suspension_pro/core/utilities/helpers.dart';
import 'package:suspension_pro/views/profile/profile_pic.dart';
import 'package:suspension_pro/features/profile/presentation/screens/profile_form_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileFormScreen()),
            ),
            child: const Text('Edit'),
          ),
        ],
        title: Text(user.userName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
            children: [
              ProfilePic(size: 100),
              Text(
                '${user.firstName} ${user.lastName}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(user.email),
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: const Text('App Settings'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {}, // TODO: create app user settings screen
            ),
          ),
          ListTile(
            title: const Text('App Roadmap'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AppRoadmap()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => loadURL('https://vibesoftware.io/privacy/suspension_pro'),
            ),
          ),
          ListTile(
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => loadURL('https://vibesoftware.io/terms/suspension_pro'),
          ),
          const SizedBox(height: 40),
          ListTile(
            leading: const Icon(Icons.power_settings_new, color: Colors.red),
            tileColor: Colors.grey.shade100,
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () => _showSignOutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Sign Out'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Okay'),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                ref.read(authViewModelProvider.notifier).signOut();
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
