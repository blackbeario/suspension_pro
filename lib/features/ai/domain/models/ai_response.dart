import 'package:flutter/material.dart';
import 'package:suspension_pro/features/bikes/domain/models/setting.dart';

class AiResponseWidget extends StatelessWidget {
  AiResponseWidget({required this.response, required this.forkName, this.shockName});

  final Setting response;
  final String forkName;
  final String? shockName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (forkName.isNotEmpty)
                Column(
                  children: [
                    Text(forkName),
                    Text('sag: ${response.fork?.sag}'),
                    Text('springRate: ${response.fork?.springRate}'),
                    // Text('preload: ${response.fork?.preload}'),
                    Text('spacers: ${response.fork?.volume_spacers}'),
                    Text('hsc: ${response.fork?.hsc}'),
                    Text('lsc: ${response.fork?.lsc}'),
                    Text('hsr: ${response.fork?.hsr}'),
                    Text('lsr: ${response.fork?.lsr}'),
                  ],
                ),
              if (shockName != null)
                Column(
                  children: [
                    Divider(),
                    Text(shockName!),
                    Text('sag: ${response.shock?.sag}'),
                    Text('springRate: ${response.shock?.springRate}'),
                    // Text('preload: ${response.shock?.preload}'),
                    Text('spacers: ${response.shock?.volume_spacers}'),
                    Text('hsc: ${response.shock?.hsc}'),
                    Text('lsc: ${response.shock?.lsc}'),
                    Text('hsr: ${response.shock?.hsr}'),
                    Text('lsr: ${response.shock?.lsr}'),
                  ],
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (response.frontTire!.isNotEmpty)
                Column(
                  children: [
                    Divider(),
                    Text('frontTire: ${response.frontTire}'),
                  ],
                ),
              if (response.rearTire!.isNotEmpty)
                Column(
                  children: [
                    Divider(),
                    Text('rearTire: ${response.rearTire}'),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
