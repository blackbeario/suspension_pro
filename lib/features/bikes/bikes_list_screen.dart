import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:suspension_pro/features/bikes/firebase_bikes_list.dart';
import 'package:suspension_pro/features/bikes/hive_bikes_list.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/services/db_service.dart';

class BikesListScreen extends StatefulWidget {
  BikesListScreen({this.bike});

  final String? bike;

  @override
  State<BikesListScreen> createState() => _BikesListScreenState();
}

class _BikesListScreenState extends State<BikesListScreen> {
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Bikes & Settings'),
        actions: [
          SizedBox(
            width: 60,
            child: ConnectivityWidgetWrapper(
              alignment: Alignment.centerLeft,
              offlineWidget: Icon(Icons.wifi_off, size: 24, color: Colors.red),
            ),
          ),
        ],
      ),
      body: Container(
        key: ValueKey('settings'),
        padding: EdgeInsets.fromLTRB(4, 10, 4, 0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          image: DecorationImage(
            image: AssetImage("assets/cupcake.png"),
            fit: BoxFit.none,
            alignment: Alignment.topCenter,
            opacity: 0.25,
          ),
        ),
        child: ConnectivityWidgetWrapper(
          offlineWidget: ValueListenableBuilder(
            valueListenable: Hive.box<Bike>('bikes').listenable(),
            builder: (context, Box<Bike> box, _) {
              final bikesFromHive = box.values;
              List<Bike> bikes = [];
              for (Bike bike in bikesFromHive) bikes.add(bike);
              return HiveBikesList(bikes: bikes);
            },
          ),
          child: FirebaseBikesList(),
          stacked: false,
        ),
      ),
    );
  }
}
