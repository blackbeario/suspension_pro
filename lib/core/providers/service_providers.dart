import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:suspension_pro/core/services/analytics_service.dart';
import 'package:suspension_pro/core/services/auth_service.dart';
import 'package:suspension_pro/core/services/db_service.dart';
import 'package:suspension_pro/core/services/encryption_service.dart';
import 'package:suspension_pro/core/services/hive_service.dart';
import 'package:suspension_pro/core/services/in_app_service.dart';
import 'package:suspension_pro/features/auth/domain/user_notifier.dart';

part 'service_providers.g.dart';

/// Database Service Provider
/// Provides access to Firestore operations
/// Injects current user's uid from userNotifierProvider
@riverpod
DatabaseService databaseService(DatabaseServiceRef ref) {
  final userState = ref.watch(userNotifierProvider);
  return DatabaseService(uid: userState.uid);
}

/// Auth Service Provider
/// Handles Firebase and Hive authentication
@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

/// Hive Service Provider
/// Manages local Hive database operations
@riverpod
HiveService hiveService(HiveServiceRef ref) {
  return HiveService();
}

/// In-App Purchase Service Provider
/// Handles purchase flow and verification
@riverpod
InAppPurchaseService inAppPurchaseService(InAppPurchaseServiceRef ref) {
  return InAppPurchaseService();
}

/// Analytics Service Provider
/// Provides Firebase Analytics logging
@riverpod
Analytics analyticsService(AnalyticsServiceRef ref) {
  return Analytics();
}

/// Encryption Service Provider
/// Handles password encryption/decryption
@riverpod
EncryptionService encryptionService(EncryptionServiceRef ref) {
  return EncryptionService();
}
