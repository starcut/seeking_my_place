import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/provider//setting_provider.dart';

class SettingView extends ConsumerWidget {
  SettingView({super.key});

  String _inputPurposeName = "";

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("設定"),
        ),
        body:  Expanded(
            child:Column(
              children: [
                countSettingWidget(context, ref),
                rangeSettingWidget(context, ref),
                purposeListWidget(context, ref)
              ],
            )
        )
    );
  }

  Widget countSettingWidget(BuildContext context, WidgetRef ref) {
    var count = ref.watch(listCountSettingProvider);
    var controller = TextEditingController(text: count.listCount.toString());

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text("表示件数"),
          SizedBox(
            width: 180,
            child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onTap: () {
              // キーボードが出ないようにする
              FocusScope.of(context).requestFocus(new FocusNode());
              showPicker(context, ref, controller);
            },
          ),),
          const Text("件")
          ]
    );
  }

  void showPicker(BuildContext context, WidgetRef ref, TextEditingController controller) {
    final countList = [1, 10, 20, 30, 50, 75, 100, 200, 300, 500];
    final list = countList.map((item) {
      return Text(item.toString());
    }).toList();

    showCupertinoModalPopup<void>(context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 216,
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CupertinoPicker(
                  backgroundColor: Colors.white,
                  itemExtent: 32,
                  children: list,
                  onSelectedItemChanged: (int index) {
                    ref.read(listCountSettingProvider.notifier).updateListCount(countList[index], index);
                  },
                )
            ),
          );
        }).then((_) {
          final countSetting = ref.read(listCountSettingProvider);
          controller.value = TextEditingValue(text: countSetting.toString());
    });
  }

  Widget rangeSettingWidget(BuildContext context, WidgetRef ref) {
    var range = ref.watch(rangeSettingProvider);

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("検索範囲[km]: "),
              Text(range.toStringAsFixed(2))
            ],
          ),
          SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.green,
                inactiveTrackColor: Colors.grey,
                trackHeight: 8.0,
                thumbColor: Colors.white,
                overlayColor: Colors.blue,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
              ),
              child: Slider(value: range,
                  min: 1,
                  max: 100,
                  onChanged: (rangeValue) async {
                double rangeValueAbout = double.parse(rangeValue.toStringAsFixed(2));
                await ref.read(rangeSettingProvider.notifier).updateRange(rangeValueAbout);
              })
          )
        ],
      );
  }

  Widget purposeListWidget(BuildContext context, WidgetRef ref) {
    final purposeList = ref.watch(purposeListSettingProvider);

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
                      ref.read(purposeListSettingProvider.notifier).deletePurpose(deleteId);
                    },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete)
                  ]
              ),
              child: GestureDetector(
                  onTap: () {
                    if (index == 0) {
                      return;
                    }
                    registerDialog(context, ref, purpose);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
                      ),
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: 50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(purpose.purposeName))
                        ],
                      )
                  )
              )
          );
        }
    );

    return Expanded(
        child: listView
    );
  }

  Widget purposeListCell(BuildContext context, WidgetRef ref, PurposeEntity entity) =>
      GestureDetector(
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
          ),
          width: MediaQuery.of(context).size.width,
          height: 65,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0))
            ),
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
      ));

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
                  onPressed: () async {
                    if (_inputPurposeName.isNotEmpty) {
                      if (entity == null) {
                        ref.read(purposeListSettingProvider.notifier).insertPurpose(_inputPurposeName);
                      } else {
                        var purposeData = await ref.read(purposeListSettingProvider.notifier).getPurposeEntity(entity.id);
                        purposeData?.purposeName = _inputPurposeName;
                        if (purposeData != null) {
                          ref.read(purposeListSettingProvider.notifier).updatePurpose(purposeData);
                        }
                      }
                    }
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
