import 'package:flutter/material.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';

class SettingView extends StatelessWidget {
  SettingView({super.key, required this.purposeList});

  late List<PurposeEntity> purposeList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("設定"),
        ),
        body: ListView.builder(
            itemCount: purposeList.length + 1,
            itemBuilder: (_, index) {
              if (index < purposeList.length) {
                final purpose = purposeList[index];
                return PurposeListCell(purpose.purposeName);
              } else {
                return NewPurposeRegisterCell(context);
              }
            }));
  }

  Widget PurposeListCell(String purposeName) => GestureDetector(
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

  Widget NewPurposeRegisterCell(BuildContext context) {
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
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text("使用目的を入力してください"),
                content: const TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "使用目的",
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        print("登録処理");
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
      },
    );
  }
}
