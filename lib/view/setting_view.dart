import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/view_model/setting_view_model.dart';

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
            data: (purposeLists) => ListView.builder(
                itemCount: purposeLists.length + 1,
                itemBuilder: (_, index) {
                  if (index < purposeLists.length) {
                    final purpose = purposeLists[index];
                    return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (DismissDirection direction) {
                          debugPrint("${purpose.id} ${purpose.purposeText}削除");
                          ref.read(
                              settingViewModelDeleteDataProvider(purpose.id));
                          ref.invalidate(settingViewModelNotifierProvider);
                        },
                        child: purposeListCell(context, ref, purpose));
                  } else {
                    return newPurposeRegisterCell(context, ref);
                  }
                }),
            error: (error, _) => const Center(child: Text('通信エラー')),
            loading: () => const Center(child: CircularProgressIndicator())));
  }

  Widget purposeListCell(
          BuildContext context, WidgetRef ref, PurposeEntity entity) =>
      GestureDetector(
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
                  child: Row(
                    children: [
                      Text(
                        entity.purposeText,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 16.0),
                      ),
                      IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () =>
                              {registerDialog(context, ref, entity)}),
                    ],
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
        registerDialog(context, ref, null);
      },
    );
  }

  void registerDialog(
      BuildContext context, WidgetRef ref, PurposeEntity? entity) {
    final TextEditingController controller = TextEditingController();
    controller.text = entity?.purposeText ?? "";

    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("使用目的を入力してください"),
            content: TextField(
              controller: controller,
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
                    if (_inputPurposeName.isNotEmpty) {
                      if (entity != null) {
                        var purposeData = ref
                            .read(settingViewModelSelectByIdNotifierProvider
                                .notifier)
                            .getPurposeList(entity.id);
                        purposeData.then((selectedPurposeData) {
                          debugPrint(
                              "entity1:::: ${selectedPurposeData}");
                          debugPrint("purposeData != null");
                          selectedPurposeData?.purposeText =
                              _inputPurposeName;
                          debugPrint(
                              "update to: ${selectedPurposeData?.purposeText}");
                          if (selectedPurposeData != null) {
                            ref.read(settingViewModelUpdateDataProvider(
                                selectedPurposeData));
                          }
                        });
                      }
                    } else {
                      ref.read(settingViewModelInsertDataProvider(
                          _inputPurposeName));
                    }
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
