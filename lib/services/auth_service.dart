import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suspension_pro/models/user.dart';
import 'package:base32/base32.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'package:suspension_pro/services/hive_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges();
  }

  Future signInWithFirebase(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
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
    await _firebaseAuth.signOut();
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
      final Box<AppUser> hiveUserBox = await Hive.box('hiveUserBox');
      if (hiveUserBox.isNotEmpty) {
        final AppUser? user = hiveUserBox.getAt(0);
        if (user != null && user.email == email) {
          String decryptedPass = await getHiveUserPass();
          if (password == decryptedPass) {
            UserSingleton().uid = user.id;
            UserSingleton().userName = user.userName ?? 'Guest';
            UserSingleton().aiCredits = user.aiCredits ?? 0;
            UserSingleton().email = user.email;
            return user;
          } else {
            return Exception('Incorrect password');
          }
        }
        if (user != null && user.email != email) {
          return Exception('Email does not match. Please check for typos.');
        }
      }
      throw PlatformException(
        code: 'user-not-found',
        message: 'User Not Found',
        details: 'While offline you can sign in, but first you must create an account when connected to the internet.',
      );
    } on Exception catch (e) {
      return e;
    }
  }

  Future createHiveUser(String uid, String email, String password) async {
    try {
      final Box<AppUser> hiveUserBox = await Hive.box('hiveUserBox');
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
      hiveUserBox.add(user);

      final Box<String> passBox = await Hive.box('hiveUserPass');
      // Encode a hex string to base32
      String encrypted = base32.encodeHexString(password);
      passBox.add(encrypted);
    } on Exception catch (e) {
      return e;
    }
  }

  addUpdateHiveUser(String uid, AppUser user) async {
    try {
      final box = await Hive.box<AppUser>('hiveUserBox');
      if (box.isNotEmpty) {
        AppUser? hiveUser = await box.getAt(0);
        // update user values
        if (hiveUser != null) {
          hiveUser.id = uid;
          hiveUser.userName = user.userName ?? 'Guest';
          hiveUser.firstName = user.firstName ?? '';
          hiveUser.lastName = user.lastName ?? '';
          hiveUser.aiCredits = user.aiCredits ?? 0;
          hiveUser.save();
        }
      }
      // If for some reason a user or this box got deleted, create a new user
      else {
        HiveService().addToBox('hiveUserBox', user);
      }
    } catch (e) {
      throw e;
    }
  }

  getHiveUserPass() async {
    try {
      final Box<String> passBox = await Hive.box('hiveUserPass');
      final String? encrypted = passBox.getAt(0); // Should be only one entry
      if (encrypted != null) {
        // base32 decoding to original string.
        String decrypted = base32.decodeAsHexString(encrypted);
        return decrypted;
      }
    } on Exception catch (e) {
      return e;
    }
  }
}
