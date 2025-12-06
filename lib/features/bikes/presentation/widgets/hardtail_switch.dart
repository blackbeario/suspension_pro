import 'package:flutter/material.dart';
import 'package:ridemetrx/core/services/haptic_service.dart';

/// Reusable hardtail switch widget for bike forms
class HardtailSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const HardtailSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: const Text(
        'Hardtail?',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        value
            ? 'Toggle off for full squishy'
            : 'Turn on if rocking a hardtail',
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      value: value,
      onChanged: (newValue) {
        HapticService.light();
        onChanged(newValue);
      },
    );
  }
}
