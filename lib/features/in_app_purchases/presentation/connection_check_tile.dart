import 'package:flutter/material.dart';
import 'package:suspension_pro/features/in_app_purchases/in_app_bloc.dart';

class ConnectionCheckTile extends StatelessWidget {
  const ConnectionCheckTile();

  @override
  Widget build(BuildContext context) {
    final InAppBloc _bloc = InAppBloc();
    return ListenableBuilder(
        listenable: _bloc,
        builder: (context, widget) {
          if (_bloc.loading) {
            return const Card(child: ListTile(title: Text('Trying to connect...')));
          }
          final Widget storeHeader = ListTile(
            leading: Icon(_bloc.isAvailable ? Icons.check : Icons.block,
                color: _bloc.isAvailable ? Colors.green : ThemeData.light().colorScheme.error),
            title: Text('The store is ${_bloc.isAvailable ? 'available' : 'unavailable'}.'),
          );

          final List<Widget> children = <Widget>[storeHeader];

          if (!_bloc.isAvailable) {
            children.addAll(<Widget>[
              const Divider(),
              ListTile(
                title: Text('Not connected', style: TextStyle(color: ThemeData.light().colorScheme.error)),
                subtitle: const Text(
                    'Unable to connect to the payments processor. Has this app been configured correctly? See the example README for instructions.'),
              ),
            ]);
          }
          return Column(children: children);
        });
  }
}
