import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:suspension_pro/features/bikes/bikes_list.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/models/user_singleton.dart';

class HiveBikesList extends StatelessWidget {
  const HiveBikesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String username = UserSingleton().username;
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('bikes').listenable(),
      builder: (context, box, widget) {
        final bikesFromHive = box.values;
        List<Bike> bikes = [];
        for (Bike bike in bikesFromHive) {
          bikes.add(bike);
        }

        if (bikes.isEmpty) return Center(child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text('Welcome $username! Add your first bike!'),
        ));
        return BikesList(bikes: bikes);
      },
    );
  }
}