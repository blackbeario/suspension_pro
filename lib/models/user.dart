class AppUser {
  final String id;
  final String? username;
  final String? profilePic;
  final String? email;
  final DateTime? created;
  final bool? proAccount;

  AppUser({
    required this.id,
    this.username,
    this.profilePic,
    this.email,
    this.created,
    this.proAccount,
  });

  factory AppUser.fromSnapshot(Map<String, dynamic> data) => AppUser(
        id: data['id'] ?? '',
        username: data['username'] ?? 'change me',
        profilePic: data['profilePic'] ?? '',
        email: data['email'] ?? '',
        proAccount: data['proAccount'] ?? false,
        created: data['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['created']) : null,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'profilePic': profilePic,
        'email': email,
        'proAccount': proAccount,
        'created': created?.millisecondsSinceEpoch
      };
}
