import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:suspension_pro/models/user.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _userFromFirebase(auth.User? user) {
    if (user == null) {
      return null;
    }
    return AppUser(id: user.uid, username: user.displayName, email: user.email);
  }

  Stream<AppUser?> get user {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebase(credential.user);
    } on auth.FirebaseException catch (e) {
      return e.message;
    }
  }

  Future createUser(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebase(credential.user);
    } on auth.FirebaseException catch (e) {
      return e.message;
    }
  }

  Future signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> createUserData(String uid, String email) async {
    DocumentReference userRef =
        _db.collection('users').doc(uid);
    return userRef.set(
        {
        'uid': uid, 
        'email': email, 
        'points': 0,
        'role': 'newbie',
        'username': email,
        'lastActivity': DateTime.now(),
        },
        SetOptions(merge: true));
  }
}
