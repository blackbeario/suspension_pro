import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/setting.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  /// Settings collection stream.
  Stream<List<Setting>> streamSettings(String id) {
    var ref = _db.collection('users').document(id).collection('settings');
    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Setting.fromMap(doc)).toList());
  }

  Stream<User> streamUser(String id) {
    return _db
      .collection('users')
      .document(id)
      .snapshots()
      .map((snap) => User.fromMap(snap.data));
  }

  // Future<void> createCustomer(FirebaseUser user) {
  //   return _db
  //     .collection('customers')
  //     .document(user.uid)
  //     .setData(
  //       {
  //         'firstName': 'Ima',
  //         'lastName': 'Newcustomer',
  //         'email': 'ima@newcustomer.com'
  //       },
  //     );
  // }

  // Future<void> updateCustomer(
  //   String id, String firstName, String lastName, String email, String main, String mobile, String notes
  // ) async {
  //   var $now = DateTime.now();
  //   var updated = $now.millisecondsSinceEpoch;
  //   return await _db.collection('customers').document(id).updateData({
  //     'updated': updated, 'firstName': firstName, 'lastName': lastName, 
  //     'email': email  ?? '', 'main': main  ?? '', 'mobile': mobile ?? '',
  //     'notes': notes
  //   });
  // }
}
