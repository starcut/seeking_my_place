import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// [AppDialogAction] の見た目のスタイル。
///
/// iOS の [CupertinoDialogAction.isDefaultAction] /
/// [CupertinoDialogAction.isDestructiveAction] に対応する。
enum AppDialogActionStyle {
  /// 通常のボタン。
  defaultStyle,

  /// 削除など破壊的な操作を表す警告色のボタン。
  destructive,
}

/// [AppDialog] のボタン1つ分の情報。呼び出し側はラベルと押下時の処理のみ指定し、
/// 実際のボタンウィジェット（[TextButton] / [CupertinoDialogAction]）は
/// [AppDialog] がプラットフォームに応じて組み立てる。
class AppDialogAction {
  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.actionStyle = AppDialogActionStyle.defaultStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppDialogActionStyle actionStyle;
}

/// アプリ共通のアラートダイアログ。
///
/// Android では [AlertDialog] + [TextButton]、iOS では [CupertinoAlertDialog] +
/// [CupertinoDialogAction] を表示する。呼び出し側はプラットフォームを意識せず
/// title / message / actions を指定するだけでよい。
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<AppDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          for (final action in actions)
            CupertinoDialogAction(
              onPressed: action.onPressed,
              isDestructiveAction:
                  action.actionStyle == AppDialogActionStyle.destructive,
              child: Text(action.label),
            ),
        ],
      );
    }

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        for (final action in actions)
          TextButton(
            onPressed: action.onPressed,
            child: Text(
              action.label,
              style: action.actionStyle == AppDialogActionStyle.destructive
                  ? const TextStyle(color: Colors.red)
                  : null,
            ),
          ),
      ],
    );
  }
}
