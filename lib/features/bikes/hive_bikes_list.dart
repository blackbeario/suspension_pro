import 'package:flutter/material.dart';
import 'package:suspension_pro/features/bikes/bikes_list.dart';
import 'package:suspension_pro/features/forms/bikeform.dart';
import 'package:suspension_pro/features/in_app_purchases/buy_credits.dart';
import 'package:suspension_pro/features/profile/profile.dart';
import 'package:suspension_pro/features/profile/profile_pic.dart';
import 'package:suspension_pro/models/bike.dart';
import 'package:suspension_pro/models/user_singleton.dart';

class HiveBikesList extends StatelessWidget {
  HiveBikesList({Key? key, required this.bikes}) : super(key: key);

  final List<Bike> bikes;
  final double profilePicSize = 60;
  final UserSingleton user = UserSingleton();

  @override
  Widget build(BuildContext context) {
    final String name = user.userName;
    if (bikes.isEmpty) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ProfilePic(size: profilePicSize),
            ),
            Padding(
              padding: EdgeInsets.only(top: profilePicSize / 3),
              child: Card(
                color: Colors.grey.withOpacity(0.10),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: (Radius.circular(16)), topRight: (Radius.circular(16)))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Text('Welcome $name!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      NewUserAction(
                          title: _isProfileComplete(user) ? 'Nice! Profile complete' : 'Complete your profile',
                          icon: Icon(Icons.edit_note),
                          screen: Profile(),
                          complete: _isProfileComplete(user)),
                      NewUserAction(
                        title: 'Add Your First Bike',
                        icon: Icon(Icons.pedal_bike),
                        screen: BikeForm(),
                      ),
                      NewUserAction(
                        title: 'Purchase AI Credits',
                        icon: Icon(Icons.money),
                        screen: BuyCredits(),
                      ),
                      SizedBox(height: 100)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return BikesList(bikes: bikes);
  }

  _isProfileComplete(UserSingleton user) {
    return user.uid.isNotEmpty && user.userName.isNotEmpty && user.profilePic.isNotEmpty && user.email.isNotEmpty && user.firstName.isNotEmpty && user.lastName.isNotEmpty;
  }
}

class NewUserAction extends StatelessWidget {
  NewUserAction({Key? key, required this.title, required this.icon, required this.screen, this.complete})
      : super(key: key);

  final String title;
  final Icon icon;
  final Widget screen;
  final bool? complete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: icon,
        title: Text(title),
        trailing: Icon(Icons.check_circle,
            size: 30, color: complete != null && complete! ? Colors.green : Colors.grey.shade50),
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (context) => screen)),
      ),
    );
  }
}
