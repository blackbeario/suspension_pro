class UserSingleton {
  // Private constructor to prevent direct instantiation
  UserSingleton._internal();

  // Static instance variable
  static final UserSingleton _instance = UserSingleton._internal();
  factory UserSingleton() => _instance;

  // User information fields
  late String _username;
  late String _id;
  // late String _profilePic;
  late String _email;
  late String _role;
  late String? _points;

  // Getter and setter methods for user information
  String get username => _username;
  void set username(String username) => _username = username;

  String get id => _id;
  void set setId(String id) => _id = id;

  // String get profilePic => _profilePic;
  // void set profilePic(String profilePic) => _profilePic = profilePic;

  String get email => _email;
  void set setEmail(String email) => _email = email;

  String get role => _role;
  void set role(String age) => _role = role;

  String get points => _points ?? '0';
  void set points(String age) => _points = points;
}
