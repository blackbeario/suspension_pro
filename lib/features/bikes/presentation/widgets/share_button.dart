import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/bikes/presentation/screens/setting_detail.dart';

/// Share button placeholder - will be replaced with Community share feature
/// TODO: Implement community sharing when community database is ready
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon: Share to Community'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      label: const Text('Share'),
      icon: const Icon(Icons.share, size: 20),
      onPressed: () => _showComingSoon(context),
    );
  }
}
