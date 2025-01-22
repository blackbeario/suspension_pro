import 'package:flutter/material.dart';
import 'package:suspension_pro/core/models/setting.dart';

class AiResponseWidget extends StatelessWidget {
  AiResponseWidget({required this.response, required this.forkName, required this.shockName});

  final Setting response;
  final String forkName;
  final String shockName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(response.bike ?? 'no bike'),
        if (forkName.isNotEmpty)
          Column(
            children: [
              Text(forkName),
              Text('sag: ${response.fork?.sag}'),
              // Text('preload: ${response.fork?.preload}'),
              Text('spacers: ${response.fork?.volume_spacers}'),
              Text('hsc: ${response.fork?.hsc}'),
              Text('lsc: ${response.fork?.lsc}'),
              Text('hsr: ${response.fork?.hsr}'),
              Text('lsr: ${response.fork?.lsr}'),
            ],
          ),
        
        if (shockName.isNotEmpty)
          Column(
            children: [
              Divider(),
              Text(shockName),
              Text('sag: ${response.shock?.sag}'),
              // Text('preload: ${response.shock?.preload}'),
              Text('spacers: ${response.shock?.volume_spacers}'),
              Text('hsc: ${response.shock?.hsc}'),
              Text('lsc: ${response.shock?.lsc}'),
              Text('hsr: ${response.shock?.hsr}'),
              Text('lsr: ${response.shock?.lsr}'),
            ],
          ),

          if (response.frontTire!.isNotEmpty) Column(
            children: [
              Divider(),
              Text('frontTire: ${response.frontTire}'),
            ],
          ),

          if (response.rearTire!.isNotEmpty) Column(
            children: [
              Divider(),
              Text('rearTire: ${response.rearTire}'),
            ],
          ),

          if (response.notes!.isNotEmpty) Column(
            children: [
              Divider(),
              Text('notes: ${response.notes}'),
            ],
          ),
      ],
    );
  }
}
