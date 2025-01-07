import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suspension_pro/models/user.dart';
import 'package:base32/base32.dart';
import 'package:suspension_pro/models/user_singleton.dart';

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
      if (user?.uid != null) {
        await createFirebaseUserData(user!.uid, user.email!);
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
      final Box<AppUser> hiveUserBox = await Hive.openBox('hiveUserBox');
      if (hiveUserBox.isNotEmpty) {
        final AppUser? user = hiveUserBox.getAt(0);
        if (user != null) {
          UserSingleton().uid = user.id;
          UserSingleton().username = user.username ?? 'Guest';
          UserSingleton().proAccount = user.proAccount ?? false;
          UserSingleton().email = user.email!;
          return user;
        }
      }
      return Exception('User does not exist. Please create a new account.');
    } on Exception catch (e) {
      return e;
    }
  }

  Future createHiveUser(String email, String password) async {
    try {
      final Box<AppUser> hiveUserBox = await Hive.openBox('hiveUserBox');
      final AppUser user = AppUser(
        id: email,
        username: null,
        profilePic: null,
        email: email,
        created: DateTime.now(),
        proAccount: false,
      );
      hiveUserBox.add(user);

      final Box<String> passBox = await Hive.openBox('hiveUserPass');
      // Encode a hex string to base32
      String encrypted = base32.encodeHexString(password);
      passBox.add(encrypted);
    } on Exception catch (e) {
      return e;
    }
  }

  getHiveUserPass() async {
    try {
      final Box<String> passBox = await Hive.openBox('hiveUserPass');
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
