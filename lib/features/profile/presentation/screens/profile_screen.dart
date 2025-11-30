import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/bikes/presentation/widgets/new_user_action.dart';
import 'package:ridemetrx/features/profile/presentation/widgets/profile_pic.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/features/auth/presentation/auth_view_model.dart';
import 'package:ridemetrx/core/utilities/helpers.dart';
import 'package:ridemetrx/features/profile/presentation/screens/profile_form_screen.dart';
import 'package:ridemetrx/features/profile/presentation/widgets/roadmap/app_roadmap.dart';
import 'package:ridemetrx/features/purchases/domain/paywall_display_manager.dart';
import 'package:ridemetrx/features/purchases/presentation/screens/paywall_screen.dart';
import 'package:ridemetrx/features/purchases/presentation/screens/subscription_management_screen.dart';

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
              MaterialPageRoute(
                  builder: (context) => const ProfileFormScreen()),
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
              ProfilePic(picSize: 100, showBorder: true),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (user.isPro) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.amber.shade800
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(user.email),
            ],
          ),
          const SizedBox(height: 40),
          if (user.isPro)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.amber.shade700,
                  ),
                ),
                title: const Text('Manage Subscription'),
                subtitle: const Text('View Pro benefits'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionManagementScreen(),
                  ),
                ),
              ),
            ),
          if (!user.isPro)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: NewUserAction(
                showAppBar: false,
                title: 'Go Pro!',
                icon: Icon(Icons.star, color: Colors.amber.shade700),
                screen: PaywallScreen(
                  onDismiss: () async {
                    await PaywallDisplayManager.recordPaywallDismissed();
                  },
                ),
              ),
            ),
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
              onTap: () =>
                  loadURL('https://vibesoftware.io/privacy/suspension_pro'),
            ),
          ),
          ListTile(
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () =>
                loadURL('https://vibesoftware.io/terms/suspension_pro'),
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
