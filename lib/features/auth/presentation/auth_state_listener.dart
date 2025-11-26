import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/core/providers/service_providers.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/features/auth/presentation/auth_view_model.dart';

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
            // User is authenticated - get user data from Firestore
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
            // User is logged out - clear state
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
