import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:suspension_pro/features/bike_settings/setting_detail.dart';
import 'package:suspension_pro/models/fork.dart';
import 'package:suspension_pro/models/shock.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'package:suspension_pro/utilities/helpers.dart';

class ShareButton extends StatelessWidget {
  ShareButton({
    Key? key,
    required this.widget,
    required this.$fork,
    required this.$shock,
  }) : super(key: key);

  final SettingDetails widget;
  final Fork? $fork;
  final Shock? $shock;
  final UserSingleton _user = UserSingleton();

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text('Share'),
      icon: Icon(CupertinoIcons.share, size: 20),
      onPressed: () => share(context, _user.userName, widget.setting!, $fork, widget.fork, $shock, widget.shock,
          widget.frontTire, widget.rearTire),
    );
  }
}
