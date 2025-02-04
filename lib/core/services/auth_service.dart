import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suspension_pro/core/models/user.dart';
import 'package:suspension_pro/core/models/user_singleton.dart';
import 'package:suspension_pro/core/services/encryption_service.dart';
import 'package:suspension_pro/core/services/hive_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  final EncryptionService _encryptionService = EncryptionService();

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }

  Future signInWithFirebase(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        final bool userExists = await checkUserExistsInHive(email);
        // Check to make sure the user is also created in Hive. If not, go ahead and create it.
        if (!userExists) await createHiveUser(credential.user!.uid, email, password);
        return credential.user;
      }
    } on FirebaseException catch (e) {
      return e;
    }
  }

  Future createFirebaseUser(String email, String password) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final User? user = credential.user;
      if (user != null) {
        await createFirebaseUserData(user.uid, user.email!); // remote
        await createHiveUser(user.uid, email, password); // local
        return credential.user;
      }
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  Future signOut() async {
    UserSingleton().resetUidForLogout();
    if (!await user.isEmpty) {
      await _firebaseAuth.signOut();
    }
  }

  Future<void> createFirebaseUserData(String uid, String email) async {
    DocumentReference userRef = _db.collection('users').doc(uid);
    return userRef.set({
      'uid': uid,
      'email': email,
      'username': email,
      'lastActivity': DateTime.now(),
    }, SetOptions(merge: true));
  }

  Future signInWithHive(String email, String password) async {
    try {
      final Box<AppUser> hiveUserBox = await Hive.box<AppUser>('hiveUserBox');
      // await hiveUserBox.clear();
      if (hiveUserBox.isNotEmpty) {
        final AppUser? user = hiveUserBox.get(email);
        if (user != null && user.email == email) {
          dynamic decryptedPass = await getHiveUserPass(email);
          if (decryptedPass.runtimeType == String) {
            if (password == decryptedPass) {
              UserSingleton().setNewUser(user);
              return user;
            } else {
              throw PlatformException(
                  code: 'password-match', message: 'Incorrect Password', details: 'Password is incorrect.');
            }
          } else if (decryptedPass.runtimeType == PlatformException) {
            return decryptedPass;
          }
        }
        // This will prob never happen now that the app is saving users by email keys
        if (user != null && user.email != email) {
          throw PlatformException(
              code: 'email-no-match',
              message: 'Account Mismatch',
              details:
                  'No user account on this device matches the provided email $email. \n\nIf you created an account with a different email address, please use that account while offline.');
        }
      }
      throw PlatformException(
        code: 'user-not-found',
        message: 'User Not Found',
        details:
            'There is no user account on this device that matches the provided email $email. \n\nWhile offline you can sign in, but first you must create an account when connected to the internet.',
      );
    } on Exception catch (e) {
      return e;
    }
  }

  Future createHiveUser(String uid, String email, String password) async {
    try {
      final Box<AppUser> hiveUserBox = await Hive.box<AppUser>('hiveUserBox');
      final AppUser user = AppUser(
        id: uid,
        userName: null,
        firstName: null,
        lastName: null,
        profilePic: null,
        email: email,
        created: DateTime.now(),
        aiCredits: 0,
      );
      // Store the user with the email as the key
      hiveUserBox.put(email, user);
      final Box<String> passBox = await Hive.box('hiveUserPass');
      // Encode a hex string to base32
      final String encrypted = await _encryptionService.encryptData(password);
      // Store the user with the email as the key
      passBox.put(email, encrypted);
    } on Exception catch (e) {
      return e;
    }
  }

  addUpdateHiveUser(AppUser user) async {
    try {
      final box = await Hive.box<AppUser>('hiveUserBox');
      if (box.isNotEmpty) {
        AppUser? hiveUser = await box.get(user.email);
        // update user values
        if (hiveUser != null) {
          hiveUser.id = user.id;
          hiveUser.userName = user.userName ?? 'Guest';
          hiveUser.firstName = user.firstName ?? '';
          hiveUser.lastName = user.lastName ?? '';
          hiveUser.aiCredits = user.aiCredits ?? 0;
          hiveUser.profilePic = user.profilePic;
          hiveUser.save();
        }
      }
      // If for some reason a user or this box got deleted, create a new user
      else {
        HiveService().putIntoBox('hiveUserBox', user.email, user, true);
      }
    } catch (e) {
      throw e;
    }
  }

  getHiveUserPass(String email) async {
    try {
      final Box<String> passBox = await Hive.box<String>('hiveUserPass');
      if (passBox.isNotEmpty) {
        final String? encrypted = passBox.get(email);
        if (encrypted != null) {
          final String decrypted = await _encryptionService.decryptData(encrypted);
          return decrypted;
        }
      }
      return PlatformException(
        code: 'no-saved_password',
        message: 'Offline: Password Not Found',
        details: 'Email found but there is no saved password. This is a rare error that can only be fixed when online.',
      );
    } on Exception catch (e) {
      return e as PlatformException;
    }
  }

  Future<bool> checkUserExistsInHive(email) async {
    final box = await Hive.box<AppUser>('hiveUserBox');
    // await box.clear();
    if (box.isNotEmpty) {
      AppUser? hiveUser = await box.get(email);
      if (hiveUser != null) return true;
    }
    return false;
  }
}
