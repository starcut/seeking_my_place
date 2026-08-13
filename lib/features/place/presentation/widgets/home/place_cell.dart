import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';

import 'package:seeking_my_place/features/place/domain/entities/place.dart';
import 'package:seeking_my_place/features/place/domain/enums/purpose_icon.dart';

class PlaceCell extends StatelessWidget {
  const PlaceCell({
    super.key,
    required this.place,
    required this.isSelected,
    required this.onTap,
    required this.onCopyUrl,
    required this.onDeleteRequested,
    required this.onDetailTap,
  });

  final Place place;
  final bool isSelected;

  /// セルタップ時 (選択状態にする)
  final VoidCallback onTap;

  /// URLコピー用アイコン押下時
  final VoidCallback onCopyUrl;

  /// 削除アクション押下時。Slidable.of(context) が必要なため、
  /// SlidableAction の onPressed が渡す BuildContext をそのまま引き渡す。
  final void Function(BuildContext context) onDeleteRequested;

  /// 詳細画面遷移用アイコン押下時
  final VoidCallback onDetailTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Slidable(
      key: ValueKey(place.placeId),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: onDeleteRequested,
            // 削除は確認ダイアログとAPI呼び出しを挟む非同期処理のため、
            // 完了前に自動でSlidableを閉じさせない。
            autoClose: false,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: l10n.delete,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: isSelected
              ? const Color(0xFFFFF2B8)
              : Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        if (place.category.isNotEmpty)
                          Text(
                            place.category,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        const Spacer(),
                        if (place.isVisited)
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                      ],
                    ),
                    if (place.purposes.isNotEmpty)
                      Row(
                        children: [
                          for (final purpose in place.purposes)
                            if (PurposeIcon.fromPurposeName(
                                  purpose.purposeName,
                                ) !=
                                null)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  PurposeIcon.fromPurposeName(
                                    purpose.purposeName,
                                  )!.icon,
                                  size: 18,
                                ),
                              ),
                        ],
                      ),
                    Text(
                      place.placeName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      place.address,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Platform.isIOS ? Icons.ios_share : Icons.share, size: 25),
                onPressed: onCopyUrl,
                tooltip: l10n.copyUrlTooltip,
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 25),
                onPressed: onDetailTap,
                tooltip: l10n.detailTooltip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
