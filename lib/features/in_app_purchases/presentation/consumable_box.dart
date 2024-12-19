import 'package:flutter/material.dart';
import 'package:suspension_pro/features/in_app_purchases/in_app_bloc.dart';
import 'package:suspension_pro/services/in_app_service.dart';

class PreviousConsumablePurchases extends StatelessWidget {
  const PreviousConsumablePurchases();

  @override
  Widget build(BuildContext context) {
    final InAppBloc _bloc = InAppBloc();
    final InAppPurchaseService _service = InAppPurchaseService();

    return ListenableBuilder(
        listenable: _bloc,
        builder: (context, widget) {
          if (_bloc.loading) {
            return const Card(
                child: ListTile(leading: CircularProgressIndicator(), title: Text('Fetching consumables...')));
          }
          if (!_bloc.isAvailable || _bloc.notFoundIds.contains('30_ai_credits')) {
            return const Center(child: ListTile(title: Text('No previous purchases')));
          }
          const ListTile consumableHeader = ListTile(title: Text('Previous Purchases'));
          final List<Widget> tokens = _bloc.consumables.map((String id) {
            return GridTile(
              child: IconButton(
                icon: const Icon(
                  Icons.stars,
                  size: 42.0,
                  color: Colors.orange,
                ),
                splashColor: Colors.yellowAccent,
                onPressed: () => _service.consume(id),
              ),
            );
          }).toList();
          return Card(
              child: Column(children: <Widget>[
            consumableHeader,
            const Divider(),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              padding: const EdgeInsets.all(16.0),
              children: _bloc.consumables.isNotEmpty ? tokens : [Text('No purchased consumables')],
            )
          ]));
        });
  }
}
