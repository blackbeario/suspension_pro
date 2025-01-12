import 'package:flutter/material.dart';
import 'package:suspension_pro/models/user.dart';

class UserSingleton extends ChangeNotifier {
  // Private constructor to prevent direct instantiation
  UserSingleton._internal();

  // Static instance variable
  static final UserSingleton _instance = UserSingleton._internal();
  factory UserSingleton() => _instance;

  // User information fields
  String _userName = '';
  String _firstName = '';
  String _lastName = '';
  String _uid = '';
  String _profilePic = '';
  String _email = '';
  int _aiCredits = 0;

  // Getter and setter methods for user information
  String get userName => _userName;
  void set userName(String userName) => _userName = userName;

  String get firstName => _firstName;
  void set firstName(String firstName) => _firstName = firstName;

  String get lastName => _lastName;
  void set lastName(String lastName) => _lastName = lastName;

  String get uid => _uid;
  void set uid(String uid) => _uid = uid;

  String get profilePic => _profilePic;
  void set profilePic(String profilePic) {
    _profilePic = profilePic;
    notifyListeners();
  }

  String get email => _email;
  void set email(String email) => _email = email;

  int get aiCredits => _aiCredits;
  void set aiCredits(int aiCredits) {
    _aiCredits = aiCredits;
    notifyListeners();
  }

  setNewUser(AppUser newUser) {
    uid = newUser.id;
    email = newUser.email;
    userName = newUser.userName ?? 'Guest';
    firstName = newUser.firstName ?? '';
    lastName = newUser.lastName ?? '';
    aiCredits = newUser.aiCredits ?? 0;
    profilePic = newUser.profilePic ?? '';
    notifyListeners();
  }

  updateNewUser(String username, firstname, lastname) {
    userName = username;
    firstName = firstname;
    lastName = lastname;
    notifyListeners();
  }
}
