import 'package:flutter/material.dart';

class UserSingleton extends ChangeNotifier {
  // Private constructor to prevent direct instantiation
  UserSingleton._internal();

  // Static instance variable
  static final UserSingleton _instance = UserSingleton._internal();
  factory UserSingleton() => _instance;

  // User information fields
  String _username = '';
  String _uid = '';
  late String _profilePic;
  late String _email;
  late String _role;
  bool _proAccount = false;

  // Getter and setter methods for user information
  String get username => _username;
  void set username(String username) => _username = username;

  String get uid => _uid;
  void set uid(String uid) {
    _uid = uid;
    notifyListeners();
  }

  String get profilePic => _profilePic;
  void set profilePic(String profilePic) => _profilePic = profilePic;

  String get email => _email;
  void set email(String email) => _email = email;

  String get role => _role;
  void set role(String age) => _role = role;

  bool get proAccount => _proAccount;
  void set proAccount(bool proAccount) {
    _proAccount = proAccount;
    notifyListeners();
  }
}
