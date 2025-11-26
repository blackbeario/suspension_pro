import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/bikes/presentation/screens/setting_detail.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/core/utilities/helpers.dart';

class ShareButton extends ConsumerWidget {
  ShareButton({
    Key? key,
    required this.widget,
    this.forkProduct,
    this.shockProduct,
  }) : super(key: key);

  final SettingDetails widget;
  final String? forkProduct;
  final String? shockProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    return TextButton.icon(
      label: Text('Share'),
      icon: Icon(Icons.share, size: 20),
      onPressed: () => share(
        context,
        widget.bike!.id,
        userState.userName,
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
