import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:suspension_pro/views/bikes/bikes_list.dart';
import 'package:suspension_pro/views/bikes/new_user_action.dart';
import 'package:suspension_pro/views/forms/bikeform.dart';
import 'package:suspension_pro/features/purchases/presentation/screens/buy_credits.dart';
import 'package:suspension_pro/views/profile/profile.dart';
import 'package:suspension_pro/views/profile/profile_pic.dart';
import 'package:suspension_pro/features/bikes/domain/models/bike.dart';
import 'package:suspension_pro/core/models/user_singleton.dart';

class OfflineToDoList extends StatefulWidget {
  OfflineToDoList({Key? key, required this.bikes}) : super(key: key);

  final List<Bike> bikes;

  @override
  State<OfflineToDoList> createState() => _OfflineToDoListState();
}

class _OfflineToDoListState extends State<OfflineToDoList> {
  final double profilePicSize = 50;
  final UserSingleton _user = UserSingleton();
  bool finished = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    Future.delayed(Duration.zero, () {
      setState(() => finished = !finished);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bikes.isEmpty) {
      return SafeArea(
        child: AnimatedSlide(
          offset: finished ? Offset.zero : Offset(0, 1),
          duration: Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: (profilePicSize / 3) - 8.0),
                  child: Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(0),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: (Radius.circular(16)), topRight: (Radius.circular(16)))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
                            child: Text('Welcome ${_user.userName}!', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text('Add your first bike to hide these tasks',
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                          NewUserAction(
                              title: UserSingleton().profileString(_user),
                              icon: Icon(Icons.edit_note),
                              screen: Profile(),
                              complete: UserSingleton().isProfileComplete(_user)),
                          NewUserAction(
                            title: 'Add Your First Bike',
                            icon: Icon(Icons.pedal_bike),
                            screen: BikeForm(),
                          ),
                          ConnectivityWidgetWrapper(
                            offlineWidget: SizedBox(),
                            stacked: false,
                            child: NewUserAction(
                              title: 'Purchase AI Credits',
                              icon: Icon(Icons.monetization_on_outlined),
                              screen: BuyCredits(),
                            ),
                          ),
                          SizedBox(height: 20)
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: ProfilePic(size: profilePicSize),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return BikesList(bikes: widget.bikes);
  }
}
