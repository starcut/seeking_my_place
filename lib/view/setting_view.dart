import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/viewmodel/setting_view_model.dart';

class SettingView extends ConsumerWidget {
  SettingView({super.key});

  String _inputPurposeName = "";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(settingViewModelNotifierProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("設定"),
        ),
        body: model.when(
            data: (settingModel) => ListView.builder(
                itemCount: settingModel.purposeLists.length + 1,
                itemBuilder: (_, index) {
                  if (index < settingModel.purposeLists.length) {
                    final purpose = settingModel.purposeLists[index];
                    return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (DismissDirection direction) {
                          debugPrint("${purpose.id} ${purpose.purposeName}削除");
                          ref.read(
                              settingViewModelDeleteDataProvider(purpose.id));
                          ref.invalidate(settingViewModelNotifierProvider);
                        },
                        child: purposeListCell(purpose.purposeName));
                  } else {
                    return newPurposeRegisterCell(context, ref);
                  }
                }),
            error: (error, _) => const Center(child: Text('通信エラー')),
            loading: () => const Center(child: CircularProgressIndicator())));
  }

  Widget purposeListCell(String purposeName) => GestureDetector(
        child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    purposeName,
                    style: const TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ),
              ],
            )),
      );

  Widget newPurposeRegisterCell(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.grey, width: 1.0))),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "新しい使用目的を追加する",
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
            ],
          )),
      onTap: () {
        registerDialog(context, ref);
      },
    );
  }

  void registerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("使用目的を入力してください"),
            content: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "使用目的",
              ),
              onChanged: (text) {
                _inputPurposeName = text;
              },
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    ref.read(
                        settingViewModelInsertDataProvider(_inputPurposeName));
                    ref.invalidate(settingViewModelNotifierProvider);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.cyan,
                  ),
                  child: const Text("登録")),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.red,
                  ),
                  child: const Text("キャンセル"))
            ],
          );
        });
  }
}
