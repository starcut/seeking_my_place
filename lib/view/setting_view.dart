import 'package:flutter/material.dart';

class SettingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("設定"),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Text("設定画面"),
        )
    );
  }
}