import 'package:flutter/material.dart';

import 'package:seeking_my_place/gen_l10n/app_localizations.dart';

/// ItemsPerPageFilterBar: 表示件数の選択ドロップダウン。
///
/// RadiusFilterBar と同じ行に並べて配置するため、余白を抑えたコンパクトな
/// レイアウトにしている。
class ItemsPerPageFilterBar extends StatelessWidget {
  const ItemsPerPageFilterBar({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<int?> options;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: DropdownButton<int?>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem<int?>(
            value: option,
            child: Text(
              option != null
                  ? '$option${l10n.itemsPerPageUnit}'
                  : l10n.itemsPerPageUnlimited,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
