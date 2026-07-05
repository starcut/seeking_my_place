import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBarDefault extends StatelessWidget implements PreferredSizeWidget {
  const AppBarDefault({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.isModal = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  /// true の場合、leading に × ボタンを配置する（モーダル遷移用）。
  final bool isModal;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: showBackButton && !isModal,
      leading: isModal
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  router.pop();
                }
              },
            )
          : null,
      actions: actions,
    );
  }
}
