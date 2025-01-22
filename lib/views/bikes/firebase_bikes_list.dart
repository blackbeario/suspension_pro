import 'package:flutter/material.dart';
import 'package:suspension_pro/core/services/analytics_service.dart';
import 'package:suspension_pro/core/services/hive_service.dart';
import 'package:suspension_pro/views/bikes/bikes_list.dart';
import 'package:suspension_pro/views/bikes/offline_todo_list.dart';
import 'package:suspension_pro/core/models/bike.dart';
import 'package:suspension_pro/core/services/db_service.dart';

class FirebaseBikesList extends StatelessWidget {
  FirebaseBikesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Bike> bikes = [];
    
    final DatabaseService db = DatabaseService();
    return StreamBuilder<List<Bike>>(
        stream: db.streamBikes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Analytics().logError("streamBikes", snapshot.error!);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasData) {
            for (Bike bike in snapshot.data!) {
              bikes.add(bike);
              // Sync bikes from FB into local Hive db
              HiveService().putIntoBox('bikes', bike.id, bike);
            }
          }
          return bikes.isNotEmpty ? BikesList(bikes: bikes) : OfflineToDoList(bikes: bikes);
        });
  }
}
