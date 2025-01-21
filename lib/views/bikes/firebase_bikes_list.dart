import 'package:flutter/material.dart';
import 'package:suspension_pro/views/bikes/bikes_list.dart';
import 'package:suspension_pro/views/bikes/hive_bikes_list.dart';
import 'package:suspension_pro/core/models/bike.dart';
import 'package:suspension_pro/core/services/db_service.dart';

class FirebaseBikesList extends StatelessWidget {
  const FirebaseBikesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();
    return StreamBuilder<List<Bike>>(
        stream: db.streamBikes(),
        builder: (context, snapshot) {
          List<Bike> bikes = [];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasData) {
            for (Bike bike in snapshot.data!) {
              bikes.add(bike);
            }
          }
          return bikes.isNotEmpty ? BikesList(bikes: bikes) : HiveBikesList(bikes: bikes);
        });
  }
}
