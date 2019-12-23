import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String role;
  final DateTime created;

  User({ this.id, this.username, this.role, this.created});

  factory User.fromMap(Map data) => User(
    id: data['id'] ?? '',
    username: data['username'] ?? '',
    role: data['role'] ?? '',
    created: data['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['created']) : null,
  );

  Map<String, dynamic> toJson() =>
    {
      'username' : username,
      'role' : role,
      'created' : created?.millisecondsSinceEpoch
    };
}

class Bike {
  final String id;
  final Map fork;
  final Map shock;

  Bike({this.id, this.fork, this.shock});

  factory Bike.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Bike(
      id: doc.documentID,
      fork: data["fork"] ?? null,
      shock: data["shock"] ?? null,
    );
  }

  Map<dynamic, dynamic> toJson() => {
    "fork": fork,
    "shock": shock,
  };
}