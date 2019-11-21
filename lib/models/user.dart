class User {
  final String id;
  final String username;
  final String role;
  final DateTime created;
  final List bikes;

  User({ this.id, this.username, this.role, this.created, this.bikes});

  factory User.fromMap(Map data) {
    return User(
      id: data['id'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      created: data['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['created']) : null,
      bikes: data['bikes'] != null ? List.from(data['bikes']) : null
    );
  }

  Map<String, dynamic> toJson() =>
    {
      'username' : username,
      'role' : role,
      'created' : created?.millisecondsSinceEpoch,
      'bikes' : bikes
    };
}