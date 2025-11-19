import 'package:connectivity_checker/connectivity_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:suspension_pro/features/bikes/domain/models/bike.dart';
import 'package:suspension_pro/features/bikes/domain/bikes_notifier.dart';
import 'package:suspension_pro/features/bikes/presentation/widgets/bikes_list.dart';
import 'package:suspension_pro/features/bikes/presentation/widgets/offline_bikes_list.dart';

class BikesListScreen extends ConsumerWidget {
  const BikesListScreen({Key? key, this.bike}) : super(key: key);

  final String? bike;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Bikes & Settings'),
        actions: const [
          SizedBox(
            width: 60,
            child: ConnectivityWidgetWrapper(
              alignment: Alignment.centerLeft,
              offlineWidget: Icon(Icons.wifi_off, size: 24, color: Colors.red),
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
        child: ConnectivityWidgetWrapper(
          // Offline widget - shows bikes from Hive
          offlineWidget: ValueListenableBuilder(
            valueListenable: Hive.box<Bike>('bikes').listenable(),
            builder: (context, Box<Bike> box, _) {
              final bikesFromHive = box.values.toList();
              return OfflineBikesList(bikes: bikesFromHive);
            },
          ),
          // Online widget - shows bikes from Firebase with Riverpod
          child: const _OnlineBikesList(),
          stacked: false,
        ),
      ),
    );
  }
}

/// Online bikes list using Riverpod stream
class _OnlineBikesList extends ConsumerWidget {
  const _OnlineBikesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikesStreamAsync = ref.watch(bikesStreamProvider);

    return bikesStreamAsync.when(
      data: (bikes) {
        return bikes.isNotEmpty
            ? BikesList(bikes: bikes)
            : OfflineBikesList(bikes: bikes);
      },
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      error: (error, stack) {
        // Log error and show offline bikes
        debugPrint('Error loading bikes: $error');
        final offlineBikes = ref.watch(offlineBikesProvider);
        return OfflineBikesList(bikes: offlineBikes);
      },
    );
  }
}
