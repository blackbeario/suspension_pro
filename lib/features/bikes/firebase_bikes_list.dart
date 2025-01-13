import 'package:flutter/material.dart';
import 'package:suspension_pro/features/bikes/bikes_list.dart';
import 'package:suspension_pro/features/forms/bikeform.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/services/db_service.dart';

class FirebaseBikesList extends StatelessWidget {
  const FirebaseBikesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = DatabaseService();
    // return Card(
    //   color: Colors.white,
    //   shadowColor: Colors.transparent,
    //   shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.only(topLeft: (Radius.circular(16)), topRight: (Radius.circular(16)))),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
         return StreamBuilder<List<Bike>>(
              stream: db.streamBikes(),
              builder: (context, snapshot) {
                List<Bike>? bikes = snapshot.data;
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator.adaptive());
                return BikesList(bikes: bikes!);
              });
          // SizedBox(height: 30),
          // ElevatedButton(
          //   child: Text('Add Bike'),
          //   onPressed: () =>
          //       Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (context) => BikeForm())),
          // ),
          // SizedBox(height: 20),
    //     ],
    //   ),
    // );
  }
}
