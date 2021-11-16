import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String? username;
  final String? profilePic;
  final String? email;
  final String? role;
  final int? points;
  final DateTime? created;

  AppUser(
      {required this.id,
      this.username,
      this.profilePic,
      this.email,
      this.role,
      this.points,
      this.created});

  factory AppUser.fromSnapshot(Map<String, dynamic> data) => AppUser(
        id: data['id'] ?? '',
        username: data['username'] ?? 'change me',
        profilePic: data['profilePic'] ?? '',
        email: data['email'] ?? '',
        role: data['role'] ?? 'newbie',
        points: data['points'] ?? 0,
        created: data['created'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['created'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'profilePic': profilePic,
        'email': email,
        'role': role,
        'points': points,
        'created': created?.millisecondsSinceEpoch
      };
}