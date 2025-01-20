import 'package:flutter/material.dart';
import 'package:suspension_pro/features/bike_settings/setting_detail.dart';
import 'package:suspension_pro/models/user_singleton.dart';
import 'package:suspension_pro/utilities/helpers.dart';

class ShareButton extends StatelessWidget {
  ShareButton({
    Key? key,
    required this.widget,
    this.forkProduct,
    this.shockProduct,
  }) : super(key: key);

  final SettingDetails widget;
  final UserSingleton _user = UserSingleton();
  final String? forkProduct;
  final String? shockProduct;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      label: Text('Share'),
      icon: Icon(Icons.share, size: 20),
      onPressed: () => share(
        context,
        widget.bike!.id,
        _user.userName,
        widget.name!,
        forkProduct ?? null,
        widget.fork,
        shockProduct ?? null,
        widget.shock,
        widget.frontTire,
        widget.rearTire,
      ),
    );
  }
}
