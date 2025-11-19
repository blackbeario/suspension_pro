import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suspension_pro/features/purchases/domain/purchase_notifier.dart';

class ConnectionCheckTile extends ConsumerWidget {
  const ConnectionCheckTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseNotifierProvider);

    if (purchaseState.loading) {
      return const Card(child: ListTile(title: Text('Trying to connect...')));
    }

    final Widget storeHeader = ListTile(
      leading: Icon(
        purchaseState.isAvailable ? Icons.check : Icons.block,
        color: purchaseState.isAvailable ? Colors.green : ThemeData.light().colorScheme.error,
      ),
      title: Text('The store is ${purchaseState.isAvailable ? 'available' : 'unavailable'}.'),
    );

    final List<Widget> children = <Widget>[storeHeader];

    if (!purchaseState.isAvailable) {
      children.addAll(<Widget>[
        const Divider(),
        ListTile(
          title: Text('Not connected', style: TextStyle(color: ThemeData.light().colorScheme.error)),
          subtitle: const Text(
            'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.',
          ),
        ),
      ]);
    }
    return Column(children: children);
  }
}
