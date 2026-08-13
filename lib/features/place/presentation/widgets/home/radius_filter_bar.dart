import 'package:flutter/material.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';

class RadiusFilterBar extends StatelessWidget {
  const RadiusFilterBar({
    super.key,
    required this.radiusMeter,
    required this.onRadiusChanged,
  });

  final double radiusMeter;
  final ValueChanged<double> onRadiusChanged;

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
    return '${meters.toStringAsFixed(0)}m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.searchRangeLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDistance(radiusMeter),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Slider(
            value: radiusMeter,
            min: 100,
            max: 50000,
            onChanged: onRadiusChanged,
            padding: const EdgeInsets.symmetric(vertical: 6),
          ),
        ],
      ),
    );
  }
}
