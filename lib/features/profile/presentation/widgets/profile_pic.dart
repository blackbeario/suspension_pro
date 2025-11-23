import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suspension_pro/features/auth/domain/user_notifier.dart';
import 'package:suspension_pro/core/utilities/imageActionSheet.dart';

class ProfilePicEditor extends StatelessWidget {
  ProfilePicEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ProfilePic(size: 100),
      onTap: () => showAdaptiveDialog(
        useRootNavigator: true,
        context: context,
        builder: (context) => ImageActionSheet(),
      ),
    );
  }
}

class ProfilePic extends ConsumerWidget {
  ProfilePic({Key? key, required this.size}) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black38,
            width: size * 0.025,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: CupertinoColors.activeBlue,
          radius: size / 2,
          child: ClipOval(
            child: userState.profilePic.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: userState.profilePic,
                        width: size,
                        height: size,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CupertinoActivityIndicator(animating: true),
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/genericUserPic.png'),
                  )
                : Icon(Icons.person_add),
          ),
        ),
      ),
    );
  }
}
