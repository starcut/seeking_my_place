import 'package:flutter/material.dart';

class RadiusFilterBar extends StatelessWidget {
  const RadiusFilterBar({
    super.key,
    required this.enabled,
    required this.radiusMeter,
    required this.onEnabledChanged,
    required this.onRadiusChanged,
  });

  final bool enabled;
  final double radiusMeter;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onRadiusChanged;

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
    return '${meters.toStringAsFixed(0)}m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: radiusMeter,
              min: 100,
              max: 50000,
              onChanged: enabled ? onRadiusChanged : null,
            ),
          ),
          Text(
            _formatDistance(radiusMeter),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 4),
          Switch(value: enabled, onChanged: onEnabledChanged),
        ],
      ),
    );
  }
}
