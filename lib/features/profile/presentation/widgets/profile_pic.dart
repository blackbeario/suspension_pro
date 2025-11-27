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
        child: ProfilePic(size: 100, showBorder: true),
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
  ProfilePic({Key? key, required this.size, this.backgroundColor, required this.showBorder}) : super(key: key);

  final double size;
  final Color? backgroundColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    return Container(
      decoration: showBorder ? BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black38,
          width: size * 0.025,
        ),
      ) : null,
      child: CircleAvatar(
        backgroundColor: backgroundColor ?? Colors.white,
        radius: size / 2,
        child: ClipOval(
          child: userState.profilePic.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: userState.profilePic,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CupertinoActivityIndicator(animating: true),
                  errorWidget: (context, url, error) => Image.asset('assets/genericUserPic.png'),
                )
              : Icon(Icons.account_circle_outlined),
        ),
      ),
    );
  }
}
