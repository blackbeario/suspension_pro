import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:suspension_pro/features/settings/setting_detail.dart';
import 'package:suspension_pro/models/user.dart';
import 'package:suspension_pro/utilities/helpers.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    Key? key,
    required this.widget,
    required this.$fork,
    required this.$shock,
  }) : super(key: key);

  final SettingDetails widget;
  final Map? $fork;
  final Map? $shock;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
        stream: db.streamUser(),
        builder: (context, snapshot) {
          AppUser? myUser = snapshot.data;

          if (myUser == null) {
            return Center(child: CupertinoActivityIndicator(animating: true));
          }

          return TextButton.icon(
            label: Text('Share'),
            icon: Icon(CupertinoIcons.share, size: 20),
            onPressed: () => share(context, myUser.username!, myUser.role!, myUser.points!, widget.setting!, $fork, widget.fork, $shock, widget.shock, widget.frontTire, widget.rearTire),
          );
        });
  }
}