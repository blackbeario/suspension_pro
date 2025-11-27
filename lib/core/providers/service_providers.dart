import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/core/services/analytics_service.dart';
import 'package:ridemetrx/core/services/auth_service.dart';
import 'package:ridemetrx/core/services/db_service.dart';
import 'package:ridemetrx/core/services/encryption_service.dart';
import 'package:ridemetrx/core/services/hive_service.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';

part 'service_providers.g.dart';

/// Database Service Provider
/// Provides access to Firestore operations
/// Injects current user's uid from userNotifierProvider
@riverpod
DatabaseService databaseService(Ref ref) {
  final userState = ref.watch(userNotifierProvider);
  return DatabaseService(uid: userState.uid);
}

/// Auth Service Provider
/// Handles Firebase and Hive authentication
@riverpod
AuthService authService(Ref ref) {
  return AuthService();
}

/// Hive Service Provider
/// Manages local Hive database operations
@riverpod
HiveService hiveService(Ref ref) {
  return HiveService();
}

/// Analytics Service Provider
/// Provides Firebase Analytics logging
@riverpod
Analytics analyticsService(Ref ref) {
  return Analytics();
}

/// Encryption Service Provider
/// Handles password encryption/decryption
@riverpod
EncryptionService encryptionService(Ref ref) {
  return EncryptionService();
}
