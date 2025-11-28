import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/core/utilities/imageActionSheet.dart';

class ProfilePicEditor extends StatelessWidget {
  ProfilePicEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ProfilePic(picSize: 100, showBorder: true),
      ),
      onTap: () => showAdaptiveDialog(
        useRootNavigator: true,
        context: context,
        builder: (context) => ImageActionSheet(),
      ),
    );
  }
}

class ProfilePic extends ConsumerWidget {
  ProfilePic({Key? key, required this.picSize, this.backgroundColor, required this.showBorder, this.proIconSize}) : super(key: key);

  final double picSize;
  final double? proIconSize;
  final Color? backgroundColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    final isPro = userState.isPro;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(right: proIconSize != null ? 8 : 0),
          decoration: showBorder ? BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black38,
              width: picSize * 0.025,
            ),
          ) : null,
          child: CircleAvatar(
            backgroundColor: backgroundColor ?? Colors.white,
            radius: picSize / 2,
            child: ClipOval(
              child: userState.profilePic.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: userState.profilePic,
                      width: picSize,
                      height: picSize,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CupertinoActivityIndicator(animating: true),
                      errorWidget: (context, url, error) => Image.asset('assets/genericUserPic.png'),
                    )
                  : Icon(Icons.account_circle_outlined),
            ),
          ),
        ),
        if (isPro)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(picSize * 0.04),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: picSize * 0.02,
                ),
              ),
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: proIconSize != null ? picSize * proIconSize! : picSize * 0.2,
              ),
            ),
          ),
      ],
    );
  }
}
