import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:suspension_pro/imageActionSheet.dart';
import 'package:suspension_pro/models/user.dart';

class ProfilePic extends StatelessWidget {
  const ProfilePic({Key? key, required this.user}) : super(key: key);
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircleAvatar(
          backgroundColor: CupertinoColors.activeBlue,
          radius: 32,
          child: ClipOval(
            child: user.profilePic != '' && user.profilePic != null
                ? CachedNetworkImage(
                    imageUrl: user.profilePic!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CupertinoActivityIndicator(animating: true),
                    errorWidget: (context, url, error) => Image.asset('assets/genericUserPic.png'),
                  )
                : Icon(Icons.photo_camera),
          ),
        ),
      ),
      onTap: () =>
          showCupertinoModalPopup(useRootNavigator: true, context: context, builder: (context) => ImageActionSheet(uid: user.id)),
    );
  }
}
