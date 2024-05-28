import 'package:flutter/material.dart';
import 'package:suspension_pro/models/user.dart';

class UserPoints extends StatelessWidget {
  const UserPoints({Key? key, required this.user}) : super(key: key);
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.stars, color: Colors.blue),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Level: ' + user.role!, style: TextStyle(color: Colors.black87)),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(user.points.toString() + 'pts', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Text(
            'Share settings with others to raise your skill level! Move up from NEWBIE to PRO simply by sharing your suspension settings.',
          ),
        ),
      ],
    );
  }
}
