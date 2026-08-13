import 'package:flutter/material.dart';
import 'package:seeking_my_place/features/place/domain/enums/purpose_icon.dart';
import 'package:seeking_my_place/features/place/presentation/widgets/home/items_per_page_filter_bar.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';

/// [FilterDialog] が「適用」「リセット」で返す絞り込み条件。
typedef FilterResult = ({
  int? itemsPerPage,
  Set<VisitStatus> visitStatuses,
  String category,
  Set<PurposeIcon> purposes,
});

/// 訪問状態の絞り込み条件。
enum VisitStatus { visited, notVisited }

/// 訪問状態チップに表示する日本語ラベル。
const Map<VisitStatus, String> _visitStatusLabels = {
  VisitStatus.visited: '訪問済み',
  VisitStatus.notVisited: '未訪問',
};

/// 目的チップに表示する日本語ラベル。[PurposeIcon.fromPurposeName] の
/// switch-case にある表記に合わせる。
const Map<PurposeIcon, String> _purposeLabels = {
  PurposeIcon.work: '作業',
  PurposeIcon.meal: '食事',
  PurposeIcon.rest: '休憩',
  PurposeIcon.scenery: '景色',
  PurposeIcon.meetPeople: '人と会う',
  PurposeIcon.date: 'デート',
};

/// 検索条件の絞り込みダイアログ。
///
/// レイアウトのみを実装したもの。ここでの選択・入力は検索処理へ反映されない
/// （ローカル表示用の一時的な状態のみを保持する）。
class FilterDialog extends StatefulWidget {
  const FilterDialog({
    super.key,
    required this.itemsPerPageOptions,
    required this.initialItemsPerPage,
    required this.defaultItemsPerPage,
    required this.initialVisitedStatuses,
    required this.initialCategory,
    required this.initialSelectedPurposes,
  });

  final List<int?> itemsPerPageOptions;
  final int? initialItemsPerPage;
  final int? defaultItemsPerPage;
  final Set<VisitStatus> initialVisitedStatuses;
  final String initialCategory;
  final Set<PurposeIcon> initialSelectedPurposes;

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late int? _selectedItemsPerPage = widget.initialItemsPerPage;
  late final Set<VisitStatus> _visitedStatuses = Set.of(
    widget.initialVisitedStatuses,
  );
  late final TextEditingController _categoryController = TextEditingController(
    text: widget.initialCategory,
  );
  late final Set<PurposeIcon> _selectedPurposes = Set.of(
    widget.initialSelectedPurposes,
  );

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = (MediaQuery.sizeOf(context).width * 0.9).clamp(
      280.0,
      480.0,
    );
    final dialogMaxHeight = MediaQuery.sizeOf(context).height * 0.8;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FilterDialogHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ItemsPerPageSection(
                            options: widget.itemsPerPageOptions,
                            value: _selectedItemsPerPage,
                            onChanged: (value) =>
                                setState(() => _selectedItemsPerPage = value),
                          ),
                          const Divider(height: 1),
                          _VisitStatusSection(
                            selectedStatuses: _visitedStatuses,
                            onChanged: (status, value) {
                              setState(() {
                                if (value) {
                                  _visitedStatuses.add(status);
                                } else {
                                  _visitedStatuses.remove(status);
                                }
                              });
                            },
                          ),
                          const Divider(height: 1),
                          _CategorySection(controller: _categoryController),
                          const Divider(height: 1),
                          _PurposeSection(
                            selectedPurposes: _selectedPurposes,
                            onChanged: (purpose, value) {
                              setState(() {
                                if (value) {
                                  _selectedPurposes.add(purpose);
                                } else {
                                  _selectedPurposes.remove(purpose);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilterDialogActions(
                    onReset: () {
                      Navigator.of(context).pop<FilterResult>((
                        itemsPerPage: widget.defaultItemsPerPage,
                        visitStatuses: const <VisitStatus>{},
                        category: '',
                        purposes: const <PurposeIcon>{},
                      ));
                    },
                    onApply: () {
                      Navigator.of(context).pop<FilterResult>((
                        itemsPerPage: _selectedItemsPerPage,
                        visitStatuses: _visitedStatuses,
                        category: _categoryController.text,
                        purposes: _selectedPurposes,
                      ));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDialogActions extends StatelessWidget {
  const _FilterDialogActions({required this.onReset, required this.onApply});

  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReset,
            child: Text(l10n.resetButton),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onApply,
            child: Text(l10n.applyButton),
          ),
        ),
      ],
    );
  }
}

class _FilterDialogHeader extends StatelessWidget {
  const _FilterDialogHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.filterDialogTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsPerPageSection extends StatelessWidget {
  const _ItemsPerPageSection({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<int?> options;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              l10n.itemsPerPageLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            ItemsPerPageFilterBar(
              options: options,
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PurposeSection extends StatelessWidget {
  const _PurposeSection({
    required this.selectedPurposes,
    required this.onChanged,
  });

  final Set<PurposeIcon> selectedPurposes;
  final void Function(PurposeIcon purpose, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.purposeMultiSelectLabel,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: _purposeLabels.entries.map((entry) {
            final purpose = entry.key;
            final selected = selectedPurposes.contains(purpose);
            return ChoiceChip(
              avatar: Icon(purpose.icon, size: 18),
              showCheckmark: false,
              label: Text(entry.value),
              selected: selected,
              side: selected
                  ? BorderSide(color: Theme.of(context).colorScheme.primary)
                  : null,
              onSelected: (value) => onChanged(purpose, value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(l10n.category, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _VisitStatusSection extends StatelessWidget {
  const _VisitStatusSection({
    required this.selectedStatuses,
    required this.onChanged,
  });

  final Set<VisitStatus> selectedStatuses;
  final void Function(VisitStatus status, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _visitStatusLabels.entries.map((entry) {
            final status = entry.key;
            final selected = selectedStatuses.contains(status);
            return ChoiceChip(
              showCheckmark: false,
              label: Text(entry.value),
              selected: selected,
              side: selected
                  ? BorderSide(color: Theme.of(context).colorScheme.primary)
                  : null,
              onSelected: (value) => onChanged(status, value),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
