import 'package:ridemetrx/features/auth/domain/models/user.dart';

/// Represents the current user state in the application
class UserState {
  final String uid;
  final String email;
  final String userName;
  final String firstName;
  final String lastName;
  final String profilePic;
  final int aiCredits;
  final bool isAuthenticated;

  const UserState({
    this.uid = '',
    this.email = '',
    this.userName = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePic = '',
    this.aiCredits = 0,
  }) : isAuthenticated = uid != '';

  /// Create UserState from AppUser model
  factory UserState.fromAppUser(AppUser user) {
    return UserState(
      uid: user.id,
      email: user.email,
      userName: user.userName ?? 'Guest',
      firstName: user.firstName ?? '',
      lastName: user.lastName ?? '',
      profilePic: user.profilePic ?? '',
      aiCredits: user.aiCredits ?? 0,
    );
  }

  /// Empty/logged out state
  factory UserState.empty() => const UserState();

  /// Check if profile is complete
  bool get isProfileComplete {
    return uid.isNotEmpty &&
        userName.isNotEmpty &&
        profilePic.isNotEmpty &&
        email.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty;
  }

  /// Profile completion message
  String get profileCompletionMessage {
    return isProfileComplete ? 'Nice! Profile complete' : 'Complete your profile';
  }

  /// Copy with method for immutable updates
  UserState copyWith({
    String? uid,
    String? email,
    String? userName,
    String? firstName,
    String? lastName,
    String? profilePic,
    int? aiCredits,
  }) {
    return UserState(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePic: profilePic ?? this.profilePic,
      aiCredits: aiCredits ?? this.aiCredits,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserState &&
        other.uid == uid &&
        other.email == email &&
        other.userName == userName &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.profilePic == profilePic &&
        other.aiCredits == aiCredits;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      email,
      userName,
      firstName,
      lastName,
      profilePic,
      aiCredits,
    );
  }
}
