import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:suspension_pro/models/bike.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/setting.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Settings collection stream.
  Stream<List<Setting>> streamSettings(String uid, String bikeid) {
    var ref = _db
        .collection('users')
        .doc(uid)
        .collection('bikes')
        .doc(bikeid)
        .collection('settings');
    return ref.snapshots().map(
        (list) => list.docs.map((doc) => Setting.fromFirestore(doc)).toList());
  }

  /// Bikes collection stream.
  Stream<List<Bike>> streamBikes(String uid) {
    // print('fetching bikes');
    var ref = _db.collection('users').doc(uid).collection('bikes').orderBy('index');
    return ref.snapshots().map(
        (list) => list.docs.map((doc) => Bike.fromFirestore(doc)).toList());
  }

  Stream<AppUser> streamUser(String id) {
    return _db
        .collection('users')
        .doc(id)
        .snapshots()
        .map((snap) => AppUser.fromSnapshot(snap.data()!));
  }

  Future<void> updateUser(
      String uid, String username, String email, String status) async {
    var $now = DateTime.now();
    var $updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).set({
      'updated': $updated,
      'username': username,
      'email': email,
      'role': status,
    }, SetOptions(merge: true));
  }

  Future<void> addSharePoints(
      String uid, int previousPoints, String role) async {
    var $now = DateTime.now();
    var $updated = $now.millisecondsSinceEpoch;
    String status = '';
    int newPoints = previousPoints + 1;
    if (role == 'admin')
      status = 'admin';
    else if (newPoints < 5)
      status = 'newbie';
    else if (newPoints >= 5)
      status = 'Cat 3';
    else if (newPoints >= 10)
      status = 'Cat 2';
    else if (newPoints >= 25)
      status = 'Cat 1';
    else if (newPoints >= 50) status = 'Pro';
    return await _db.collection('users').doc(uid).set({
      'updated': $updated,
      'points': newPoints,
      'role': status,
    }, SetOptions(merge: true));
  }

  Future<void> setProfilePic(String uid, String filePath) async {
    var $now = DateTime.now();
    var $updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).set(
        {'updated': $updated, 'profilePic': filePath}, SetOptions(merge: true));
  }

  Future<void> setBikePic(String uid, String bikeid, String filePath) async {
    var $now = DateTime.now();
    var $updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).collection('bikes').doc(bikeid).set(
        {'updated': $updated, 'bikePic': filePath}, SetOptions(merge: true));
  }

  /// Need to add required fork and shock fields with values.
  Future<void> addUpdateBike(
      String uid, String bikeid, Map? fork, Map? shock) async {
    var $now = DateTime.now();
    var $created = $now.millisecondsSinceEpoch;
    return await _db
        .collection('users')
        .doc(uid)
        .collection('bikes')
        .doc(bikeid)
        .set({
      'created': $created,
      'index': 0,
      if (fork != null)
        'fork': {
          'year': fork['year'],
          'travel': fork['travel'],
          'damper': fork['damper'],
          'offset': fork['offset'],
          'wheelsize': fork['wheelsize'],
          'brand': fork['brand'],
          'model': fork['model'],
          'spacers': fork['spacers'],
          'spacing': fork['spacing']
        },
      if (shock != null)
        'shock': {
          'year': shock['year'],
          'stroke': shock['stroke'],
          'brand': shock['brand'],
          'model': shock['model'],
          'spacers': shock['spacers']
        }
    }, SetOptions(merge: true));
  }

  Future<void> reorderBike(String uid, String bikeid, int index) async {
    return await _db
        .collection('users')
        .doc(uid)
        .collection('bikes')
        .doc(bikeid)
        .set({
      'index': index,
    }, SetOptions(merge: true));
  }

  Future<void> deleteBike(String uid, String bikeid) async {
    return await _db
        .collection('users')
        .doc(uid)
        .collection('bikes')
        .doc(bikeid)
        .delete();
  }

  Future<void> deleteSetting(String uid, String bikeid, String sid) async {
    return await _db
        .collection('users')
        .doc(uid)
        .collection('bikes')
        .doc(bikeid)
        .collection('settings')
        .doc(sid)
        .delete();
  }

  Future<void> updateFork(
      String uid,
      String bikeid,
      String year,
      String travel,
      String damper,
      String offset,
      String wheelsize,
      String brand,
      String model,
      String spacers,
      String spacing,
      String serial) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db
        .collection('users')
        .doc(uid)
        .collection('bikes')
        .doc(bikeid)
        .set({
      'fork': {
        'updated': updated,
        'year': year,
        'travel': travel,
        'damper': damper,
        'offset': offset,
        'wheelsize': wheelsize,
        'brand': brand,
        'model': model,
        'spacers': spacers,
        'spacing': spacing,
        'serial': serial,
      }
    }, SetOptions(merge: true));
  }

  Future<void> updateShock(String uid, String bikeid, String year,
      String stroke, String brand, String model, String spacers, String serial) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db
        .collection('users')
        .doc(uid)
        .collection('bikes')
        .doc(bikeid)
        .set({
      'shock': {
        'updated': updated,
        'year': year,
        'stroke': stroke,
        'brand': brand,
        'model': model,
        'spacers': spacers,
        'serial': serial,
      }
    }, SetOptions(merge: true));
  }

  Future<void> deleteField(String uid, String bikeid, String component) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    var ref = _db.collection('users').doc(uid).collection('bikes').doc(bikeid);
    // remove the provided value field from the document
    return await ref.update({
      'updated': updated,
      component: FieldValue.delete(),
    });
  }

  Future<void> updateSetting(
    String uid,
    String bikeid,
    String settingId,
    String hscFork,
    String lscFork,
    String hsrFork,
    String lsrFork,
    String springFork,
    String hscShock,
    String lscShock,
    String hsrShock,
    String lsrShock,
    String springShock,
    String frontTire,
    String rearTire
  ) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db
        .collection('users')
        .doc(uid)
        .collection('bikes')
        .doc(bikeid)
        .collection('settings')
        .doc(settingId)
        .set({
      'updated': updated,
      'fork': {
        'HSC': hscFork,
        'LSC': lscFork,
        'HSR': hsrFork,
        'LSR': lsrFork,
        'springRate': springFork
      },
      'shock': {
        'HSC': hscShock,
        'LSC': lscShock,
        'HSR': hsrShock,
        'LSR': lsrShock,
        'springRate': springShock
      },
      'frontTire': frontTire,
      'rearTire': rearTire
    }, SetOptions(merge: true));
  }
}
