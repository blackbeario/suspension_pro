import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:suspension_pro/core/services/analytics_service.dart';
import 'package:suspension_pro/core/services/hive_service.dart';
import 'package:suspension_pro/views/bikes/bikes_bloc.dart';
import 'package:suspension_pro/views/bikes/bikes_list.dart';
import 'package:suspension_pro/views/bikes/offline_todo_list.dart';
import 'package:suspension_pro/core/models/bike.dart';
import 'package:suspension_pro/core/services/db_service.dart';

class FirebaseBikesList extends StatelessWidget {
  FirebaseBikesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Bike> bikes = [];
    final DatabaseService _db = DatabaseService();
    return StreamBuilder<List<Bike>>(
      stream: _db.streamBikes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          Analytics().logError("_db.streamBikes", snapshot.error!);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.hasData) {
          for (Bike bike in snapshot.data!) {
            bikes.add(bike);
            HiveService().putIntoBox('bikes', bike.id, bike);
            BikesBloc().putBikeSettingsIntoHive(bike.id);
          }
        }
        return bikes.isNotEmpty ? BikesList(bikes: bikes) : OfflineToDoList(bikes: bikes);
      },
    );
  }
}
