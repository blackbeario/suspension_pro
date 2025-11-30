import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridemetrx/features/bikes/domain/bikes_notifier.dart';
import 'package:ridemetrx/features/bikes/presentation/widgets/bikes_list.dart';
import 'package:ridemetrx/features/bikes/presentation/widgets/offline_bikes_list.dart';
import 'package:ridemetrx/features/connectivity/presentation/widgets/connectivity_widget_wrapper.dart';

class BikesListScreen extends ConsumerWidget {
  const BikesListScreen({Key? key, this.bike}) : super(key: key);

  final String? bike;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Bikes & Settings'),
        actions:  [
          SizedBox(
            width: 60,
            child: ConnectivityWidgetWrapper(
              alignment: Alignment.centerLeft,
              offlineWidget: Icon(Icons.wifi_off, size: 24, color: Colors.red),
              child: SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          image: const DecorationImage(
            image: AssetImage("assets/cupcake.png"),
            fit: BoxFit.none,
            alignment: Alignment.topCenter,
            opacity: 0.25,
          ),
        ),
        child: _BikesListStream()
      ),
    );
  }
}

/// Bikes list using BikesNotifier (ViewModel) - offline-first from Hive
class _BikesListStream extends ConsumerWidget {
  const _BikesListStream();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the BikesNotifier state (ViewModel)
    // This gives us offline-first data from Hive with smart merge
    final bikesState = ref.watch(bikesNotifierProvider);

    // Show loading only on initial load
    if (bikesState.isLoading && bikesState.bikes.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // Display bikes from Hive (source of truth)
    final bikes = bikesState.bikes;

    if (bikes.isEmpty) {
      return OfflineBikesList(bikes: bikes);
    }

    return BikesList(bikes: bikes);
  }
}
