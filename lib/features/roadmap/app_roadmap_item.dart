import 'package:flutter/material.dart';

class AppRoadmapItem extends StatelessWidget {
  const AppRoadmapItem({Key? key, required this.value}) : super(key: key);
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: Text('* $value'),
    );
  }
}