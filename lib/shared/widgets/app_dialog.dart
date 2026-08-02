import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// [AppDialog] のボタン1つ分の情報。呼び出し側はラベルと押下時の処理のみ指定し、
/// 実際のボタンウィジェット（[TextButton] / [CupertinoDialogAction]）は
/// [AppDialog] がプラットフォームに応じて組み立てる。
class AppDialogAction {
  const AppDialogAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;
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
          TextButton(onPressed: action.onPressed, child: Text(action.label)),
      ],
    );
  }
}
