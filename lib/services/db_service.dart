import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/models/fork.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/setting.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid = UserSingleton().id;

  /// Settings collection stream.
  Stream<List<Setting>> streamSettings(String bikeid) {
    var ref = _db.collection('users').doc(uid).collection('bikes').doc(bikeid).collection('settings');
    return ref.snapshots().map((list) => list.docs.map((doc) => Setting.fromFirestore(doc)).toList());
  }

  /// Bikes collection stream.
  Stream<List<Bike>> streamBikes() {
    // print('fetching bikes');
    var ref = _db.collection('users').doc(uid).collection('bikes').orderBy('index');
    return ref.snapshots().map((list) => list.docs.map((doc) => Bike.fromFirestore(doc)).toList());
  }

  Stream<AppUser> streamUser() {
    return _db.collection('users').doc(uid).snapshots().map((snap) => AppUser.fromSnapshot(snap.data()!));
  }

  Future<void> updateUser(String username, String email, String status) async {
    var $now = DateTime.now();
    var $updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).set({
      'updated': $updated,
      'username': username,
      'email': email,
      'role': status,
    }, SetOptions(merge: true));
  }

  Future<void> addSharePoints(int previousPoints, String role) async {
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

  Future<void> setProfilePic(String filePath) async {
    var $now = DateTime.now();
    var $updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).set({'updated': $updated, 'profilePic': filePath}, SetOptions(merge: true));
  }

  Future<void> setBikePic(String bikeid, String filePath) async {
    var $now = DateTime.now();
    var $updated = $now.millisecondsSinceEpoch;
    return await _db
        .collection('users')
        .doc(uid)
        .collection('bikes')
        .doc(bikeid)
        .set({'updated': $updated, 'bikePic': filePath}, SetOptions(merge: true));
  }

  /// Need to add required fork and shock fields with values.
  Future<void> addUpdateBike(Bike bike) async {
    var $now = DateTime.now();
    var $created = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).collection('bikes').doc(bike.id).set({
      'created': $created,
      'index': 0,
      'yearModel': bike.yearModel,
      if (bike.fork != null)
        'fork': {
          'year': bike.fork!.year,
          'travel': bike.fork!.travel,
          'damper': bike.fork!.damper,
          'offset': bike.fork!.offset,
          'wheelsize': bike.fork!.wheelsize,
          'brand': bike.fork!.brand,
          'model': bike.fork!.model,
          'spacers': bike.fork!.spacers,
          'spacing': bike.fork!.spacing
        },
      if (bike.shock != null)
        'shock': {
          'year': bike.shock!.year,
          'stroke': bike.shock!.stroke,
          'brand': bike.shock!.brand,
          'model': bike.shock!.model,
          'spacers': bike.shock!.spacers
        }
    }, SetOptions(merge: true));
  }

  Future<void> reorderBike(String bikeid, int index) async {
    return await _db.collection('users').doc(uid).collection('bikes').doc(bikeid).set({
      'index': index,
    }, SetOptions(merge: true));
  }

  Future<void> deleteBike(String bikeid) async {
    return await _db.collection('users').doc(uid).collection('bikes').doc(bikeid).delete();
  }

  Future<void> deleteSetting(String bikeid, String sid) async {
    return await _db.collection('users').doc(uid).collection('bikes').doc(bikeid).collection('settings').doc(sid).delete();
  }

  Future<void> updateFork(Fork fork) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).collection('bikes').doc(fork.bikeId).set({
      'fork': {
        'updated': updated,
        'year': fork.year,
        'travel': fork.travel,
        'damper': fork.damper,
        'offset': fork.offset,
        'wheelsize': fork.wheelsize,
        'brand': fork.brand,
        'model': fork.model,
        'spacers': fork.spacers,
        'spacing': fork.spacing,
        'serial': fork.serialNumber,
      }
    }, SetOptions(merge: true));
  }

  Future<void> updateShock(String bikeid, String year, String stroke, String brand, String model, String spacers, String serial) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).collection('bikes').doc(bikeid).set({
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

  Future<void> deleteField(String bikeid, String component) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    var ref = _db.collection('users').doc(uid).collection('bikes').doc(bikeid);
    // remove the provided value field from the document
    return await ref.update({
      'updated': updated,
      component: FieldValue.delete(),
    });
  }

  Future<void> updateSetting(bikeid, settingId, hscFork, lscFork, hsrFork, lsrFork, springFork, hscShock, lscShock, hsrShock,
      lsrShock, springShock, frontTire, rearTire, notes) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).collection('bikes').doc(bikeid).collection('settings').doc(settingId).set({
      'updated': updated,
      'fork': {'HSC': hscFork, 'LSC': lscFork, 'HSR': hsrFork, 'LSR': lsrFork, 'springRate': springFork},
      'shock': {'HSC': hscShock, 'LSC': lscShock, 'HSR': hsrShock, 'LSR': lsrShock, 'springRate': springShock},
      'frontTire': frontTire,
      'rearTire': rearTire,
      'notes': notes
    }, SetOptions(merge: true));
  }
}
