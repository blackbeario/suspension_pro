import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/setting.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  /// Settings collection stream.
  Stream<List<Setting>> streamSettings(String uid) {
    var ref = _db.collection('users').document(uid).collection('settings');
    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Setting.fromFirestore(doc)).toList());
  }

  /// Single setting stream.
  // Stream<Setting> streamSetting(String uid, String sid) {
  //   return _db.collection('users').document(uid).collection('settings')
  //   .document(sid).snapshots().map((snap) => Setting.fromFirestore(snap));
  // }

  /// Bikes collection stream.
  Stream<List<Bike>> streamBikes(String uid) {
    var ref = _db.collection('users').document(uid).collection('bikes');
    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Bike.fromFirestore(doc)).toList());
  }

  Stream<User> streamUser(String id) {
    return _db
      .collection('users')
      .document(id)
      .snapshots()
      .map((snap) => User.fromMap(snap.data));
  }

  Future<void> updateUser(
    String uid, String username, String role, String email, Map bikes
  ) async {
    var $now = DateTime.now();
    var $updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').document(uid).setData({
      'updated': $updated, 'username': username, 
      'email': email  ?? '', 'bikes': {bikes}
    }, merge: true);
  }

  Future<void> updateBike(
    String uid, String bikeid
  ) async {
    return await _db.collection('users').document(uid).setData({
      'bikes': { bikeid: {}}
    }, merge: true);
  }

  Future<void> deleteBike(
    String uid, String bikeid
  ) async {
    return await _db.collection('users').document(uid).updateData({
      'bikes': FieldValue.delete()
    });
  }

  Future<void> updateFork(
    String uid, String bikeid, String year, String travel, String damper, String offset, String wheelsize
  ) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').document(uid).collection('bikes').document(bikeid).setData({
      'fork': {
        'updated': updated, 'year': year, 'travel': travel, 
        'damper': damper  ?? '', 'offset': offset  ?? '', 'wheelsize': wheelsize ?? ''
      }
    }, merge: true);
  }

  Future<void> updateShock(
    String uid, String bikeid, String year, String travel, String stroke
  ) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').document(uid).collection('bikes').document(bikeid).setData({
      'shock': {
        'updated': updated, 'year': year, 'travel': travel, 
        'stroke': stroke  ?? ''
      }
    }, merge: true);
  }

  Future<void> updateSetting(
    String uid, String id, String bikeid, String hscFork, String lscFork, String hsrFork, String lsrFork, String springFork,
    String hscShock, String lscShock, String hsrShock, String lsrShock, String springShock,
  ) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').document(uid).collection('settings').document(id).setData({
      'updated': updated,
      'bike': bikeid,
      'fork': {'HSC': hscFork, 'LSC': lscFork, 'HSR': hsrFork, 'LSR': lsrFork, 'springRate': springFork},
      'shock': {'HSC': hscShock ?? '', 'LSC': lscShock, 'HSR': hsrShock, 'LSR': lsrShock, 'springRate': springShock}
    }, merge: true);
  }
}
