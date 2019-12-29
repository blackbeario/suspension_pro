import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/setting.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  /// Settings collection stream.
  Stream<List<Setting>> streamSettings(String uid, String bikeid) {
    var ref = _db.collection('users').document(uid).collection('bikes').document(bikeid).collection('settings');
    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Setting.fromFirestore(doc)).toList());
  }

  /// Bikes collection stream.
  Stream<List<Bike>> streamBikes(String uid) {
    var ref = _db.collection('users').document(uid).collection('bikes').orderBy('created');
    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Bike.fromFirestore(doc)).toList());
  }

  Stream<User> streamUser(String id) {
    return _db.collection('users').document(id).snapshots().map((snap) => User.fromMap(snap.data));
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

  /// Need to add required fork and shock fields with values.
  Future<void> addUpdateBike(
    String uid, String bikeid, Map fork, Map shock 
  ) async {
    var $now = DateTime.now();
    var $created = $now.millisecondsSinceEpoch;
    return await _db.collection('users').document(uid).collection('bikes').document(bikeid).setData({
      'created': $created, 
      'fork': {
        'year': fork['year'], 'travel': fork['travel'], 'damper': fork['damper'], 'offset': fork['offset'], 
        'wheelsize': fork['wheelsize'], 'brand': fork['brand'], 'model': fork['model'], 'spacers': fork['spacers'], 'spacing': fork['spacing']
      },
      'shock': {
        'year': shock['year'], 'stroke': shock['stroke'],
        'brand': shock['brand'], 'model': shock['model'], 'spacers': shock['spacers']
      }
    }, merge: true);
  }

  Future<void> deleteBike(
    String uid, String bikeid
  ) async {
    return await _db.collection('users').document(uid).collection('bikes').document(bikeid).delete();
  }

  Future<void> deleteSetting(
    String uid, String bikeid, String sid
  ) async {
    return await _db.collection('users').document(uid).collection('bikes').document(bikeid).collection('settings').document(sid).delete();
  }

  Future<void> updateFork(
    String uid, String bikeid, String year, String travel, String damper, String offset, String wheelsize,
    String brand, String model, String spacers, String spacing
  ) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').document(uid).collection('bikes').document(bikeid).setData({
      'fork': {
        'updated': updated, 'year': year, 'travel': travel, 'damper': damper  ?? '', 'offset': offset  ?? '', 'wheelsize': wheelsize ?? '',
        'brand': brand, 'model': model  ?? '', 'spacers': spacers  ?? '', 'spacing': spacing ?? ''
      }
    }, merge: true);
  }

  Future<void> updateShock(
    String uid, String bikeid, String year, String stroke,
    String brand, String model, String spacers
  ) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').document(uid).collection('bikes').document(bikeid).setData({
      'shock': {
        'updated': updated, 'year': year, 'stroke': stroke  ?? '',
        'brand': brand, 'model': model  ?? '', 'spacers': spacers  ?? ''
      }
    }, merge: true);
  }

  Future<void> updateSetting(
    String uid, String id, String bikeid, String hscFork, String lscFork, String hsrFork, String lsrFork, String springFork,
    String hscShock, String lscShock, String hsrShock, String lsrShock, String springShock,
  ) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').document(uid).collection('bikes').document(bikeid).collection('settings').document(id).setData({
      'updated': updated,
      'fork': {'HSC': hscFork, 'LSC': lscFork, 'HSR': hsrFork, 'LSR': lsrFork, 'springRate': springFork},
      'shock': {'HSC': hscShock, 'LSC': lscShock, 'HSR': hsrShock, 'LSR': lsrShock, 'springRate': springShock}
    }, merge: true);
  }
}