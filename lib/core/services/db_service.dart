import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:ridemetrx/features/bikes/domain/models/bike.dart';
import 'package:ridemetrx/features/bikes/domain/models/fork.dart';
import 'package:ridemetrx/features/bikes/domain/models/shock.dart';
import 'package:ridemetrx/features/bikes/domain/models/setting.dart';
import 'dart:async';
import 'package:ridemetrx/features/auth/domain/models/user.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  DatabaseService({required this.uid});

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

  Stream<AppUser> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) => AppUser.fromSnapshot(snap.data()!));
  }

  Future<void> updateUser(String username, String firstName, String lastName, String email) async {
    var $now = DateTime.now();
    var $updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).set({
      'updated': $updated,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
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
          'spacing': bike.fork!.spacing,
          'serialNumber': bike.fork!.serialNumber
        },
      if (bike.shock != null)
        'shock': {
          'year': bike.shock!.year,
          'stroke': bike.shock!.stroke,
          'brand': bike.shock!.brand,
          'model': bike.shock!.model,
          'spacers': bike.shock!.spacers,
          'serialNumber': bike.shock!.serialNumber
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

  Future<void> updateFork(String bikeid, Fork fork) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).collection('bikes').doc(bikeid).set({
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
        'serialNumber': fork.serialNumber,
      }
    }, SetOptions(merge: true));
  }

  Future<void> updateShock(String bikeid, Shock shock) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('users').doc(uid).collection('bikes').doc(bikeid).set({
      'shock': {
        'updated': updated,
        'year': shock.year,
        'stroke': shock.stroke,
        'brand': shock.brand,
        'model': shock.model,
        'spacers': shock.spacers,
        'serialNumber': shock.serialNumber,
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

  Future<void> updateSetting(Setting setting) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    if (await ConnectivityWrapper.instance.isConnected) {
      try {
        return await _db.collection('users').doc(uid).collection('bikes').doc(setting.bike).collection('settings').doc(setting.id).set({
        'updated': updated,
        'fork': {'HSC': setting.fork?.hsc, 'LSC': setting.fork?.lsc, 'HSR': setting.fork?.hsr, 'LSR': setting.fork?.lsr, 'springRate': setting.fork?.springRate},
        'shock': {'HSC': setting.shock?.hsc, 'LSC': setting.shock?.lsc, 'HSR': setting.shock?.hsr, 'LSR': setting.shock?.lsr, 'springRate': setting.shock?.springRate},
        'frontTire': setting.frontTire,
        'rearTire': setting.rearTire,
        'notes': setting.notes
      }, SetOptions(merge: true));
      } catch (e) {
        throw e;
      }
    } else {
      // TODO: Add to workmanager background tasks
      debugPrint('offline - try later');
    }
  }
}
