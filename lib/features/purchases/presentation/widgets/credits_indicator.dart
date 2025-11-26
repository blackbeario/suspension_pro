import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';

class CreditsIndicator extends ConsumerWidget {
  const CreditsIndicator({Key? key}) : super(key: key);

  Color _setIndicatorColor(int credits) {
    if (credits < 10) return Colors.redAccent;
    if (credits <= 20 && credits > 10) return Colors.amber;
    if (credits > 20) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final String credits = purchaseState.credits.toString();

    return Container(
      alignment: Alignment.center,
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        color: _setIndicatorColor(purchaseState.credits),
        shape: BoxShape.circle,
      ),
      child: Text(credits, style: const TextStyle(color: Colors.white)),
    );
  }
}
