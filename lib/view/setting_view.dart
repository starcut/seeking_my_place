import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/view_model/setting_view_model.dart';

class SettingView extends ConsumerWidget {
  SettingView({super.key});

  String _inputPurposeName = "";

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final purposeListView = ref.watch(settingViewModelNotifierProvider).when(data: (purposeList) {
      if (purposeList.isEmpty) {
        return newPurposeRegisterCell(context, ref);
      }

      final listView = ListView.builder(
          itemCount: purposeList.length + 1,
          itemBuilder: (context, index) {
            if (index == purposeList.length) {
              return newPurposeRegisterCell(context, ref);
            }
            final purpose = purposeList[index];
            return Slidable(
                key: UniqueKey(),
                startActionPane: index == 0 ? null : ActionPane(motion: const ScrollMotion(),
                    extentRatio: 0.2,
                    children: [
                      SlidableAction(onPressed: (_) {
                        print("お気に入りデータピン留めする");
                      },
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.push_pin)
                    ]
                ),
                endActionPane: index == 0 ? null : ActionPane(motion: const ScrollMotion(),
                    extentRatio: 0.2,
                    children: [
                      SlidableAction(onPressed: (_) {
                        int deleteId = purpose.id;
                        ref.read(settingViewModelDeleteDataProvider(deleteId));
                      },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete)
                    ]
                ),
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text(purpose.purposeName))
                            ],
                    )
                )
            );
          }
      );

      // 取得したリストをListView.builderに渡す
      return listView;
    },
        error: (err, stack) {
          return Center(child: Text('Error: $err'));
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        }
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("設定"),
        ),
        body: purposeListView);
  }

  Widget purposeListCell(BuildContext context, WidgetRef ref, PurposeEntity entity) =>
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
                        entity.purposeName,
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
    controller.text = entity?.purposeName ?? "";

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
                      if (entity == null) {
                        ref.read(settingViewModelInsertDataProvider(_inputPurposeName));
                      } else {
                        print("entity: ${entity.purposeName}");
                        var purposeData = ref.read(settingViewModelSelectByIdNotifierProvider.notifier)
                            .getPurposeList(entity.id);
                        purposeData.then((selectedPurposeData) {
                          debugPrint("purposeData != null");
                          selectedPurposeData?.purposeName =
                              _inputPurposeName;
                          debugPrint(
                              "update to: ${selectedPurposeData?.purposeName}");
                          if (selectedPurposeData != null) {
                            ref.read(settingViewModelUpdateDataProvider(selectedPurposeData));
                          }
                        });
                      }
                    }
                    // ref.invalidate(settingViewModelNotifierProvider);
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
