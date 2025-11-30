import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/features/auth/presentation/auth_view_model.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';

/// Provider that listens to Firebase auth state changes and updates UserNotifier
final authStateListenerProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final stream = authService.user;

  // Listen to auth state changes and update UserNotifier
  ref.listen<AsyncValue<User?>>(
    firebaseAuthStateProvider,
    (previous, next) {
      next.when(
        data: (user) async {
          if (user != null) {
            // User is authenticated - link RevenueCat to Firebase user
            try {
              print('AuthStateListener: Logging into RevenueCat with Firebase UID: ${user.uid}');
              final result = await Purchases.logIn(user.uid);
              print('AuthStateListener: RevenueCat login successful');
              print('AuthStateListener: originalAppUserId (first ID used): ${result.customerInfo.originalAppUserId}');
              print('AuthStateListener: Was new user created: ${result.created}');
              print('AuthStateListener: ✅ Subscription is now linked to Firebase UID: ${user.uid}');

              // Refresh subscription status after login
              ref.read(purchaseNotifierProvider.notifier).refreshCustomerInfo();
            } catch (e) {
              print('AuthStateListener: Failed to login to RevenueCat: $e');
            }

            // Get user data from Firestore
            final db = ref.read(databaseServiceProvider);
            try {
              // Stream the user data and update UserNotifier
              db.streamUser(user.uid).listen((appUser) {
                ref.read(userNotifierProvider.notifier).setUser(appUser);

                // Also update Hive
                final authService = ref.read(authServiceProvider);
                authService.addUpdateHiveUser(appUser);
              });
            } catch (e) {
              // Handle error
              print('Error streaming user data: $e');
            }
          } else {
            // User is logged out - only call RevenueCat logout if there was a previous authenticated user
            final previousUser = previous?.value;
            if (previousUser != null) {
              try {
                print('AuthStateListener: Logging out of RevenueCat');
                await Purchases.logOut();
                print('AuthStateListener: RevenueCat logout successful');
              } catch (e) {
                print('AuthStateListener: Failed to logout of RevenueCat: $e');
              }
            } else {
              print('AuthStateListener: No previous user, skipping RevenueCat logout');
            }

            // Clear user state
            ref.read(userNotifierProvider.notifier).logout();
          }
        },
        loading: () {},
        error: (error, stack) {
          print('Auth state error: $error');
        },
      );
    },
  );

  return stream;
});
