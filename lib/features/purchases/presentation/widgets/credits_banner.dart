import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/purchases/domain/purchase_notifier.dart';

class CreditsBanner extends ConsumerWidget {
  const CreditsBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final String count = purchaseState.credits.toString();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.warning_amber, color: Colors.amber, size: 36),
        title: Text(
          'You may generate 3 free AI suggestions. Afterwards, you must purchase an AI Pack. You have $count free credits remaining.',
          style: const TextStyle(color: Colors.black54),
        ),
        tileColor: Colors.amber.shade50,
      ),
    );
  }
}
