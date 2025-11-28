import 'package:flutter/material.dart';

class AppRoadmapItem extends StatelessWidget {
  const AppRoadmapItem({Key? key, required this.value, this.icon, this.color}) : super(key: key);
  final String value;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: icon != null ? Icon(icon, color: color) : null,
        title: Text(value),
      ),
    );
  }
}