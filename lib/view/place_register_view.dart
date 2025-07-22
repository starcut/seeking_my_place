import 'package:flutter/material.dart';

class PlaceRegisterView extends StatefulWidget {
  PlaceRegisterView({super.key});

  @override
  _PlaceRegisterViewState createState() => _PlaceRegisterViewState();
}

class _PlaceRegisterViewState extends State<PlaceRegisterView> {
  bool isVisited = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: const Text("場所の登録"),
        ),
        body: Container( //SizedBoxでも可
            height: 639,
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                registerItemCellView("URL", "https://"),
                registerItemCellView("場所名", ""),
                registerItemCellView("住所", ""),
                registerItemCellView("カテゴリ", ""),
                registerItemCellView("用途", ""),
                registerItemCheckBoxCellView("訪問済み"),
                const SizedBox(height: 15),
                buttonArea()
          ],
        ))
    );
  }

  // 登録のセル
  Widget registerItemCellView(String itemName, String hintText) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(itemName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ),
        )),
        TextField(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hintText,
          ),
        ),
        const SizedBox(height: 15)
      ],
    );
  }

  Widget registerItemCheckBoxCellView(String itemName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(itemName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            )),
        Checkbox(
          value: isVisited,
          activeColor: Colors.green,
          onChanged: (bool? value) {
            setState(() {
              isVisited = value ?? false;
            });
          }
        ),
      ],
    );
  }

  Widget buttonArea() {
    const buttonSize = Size(150, 40);

    var registerButton = OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
          debugPrint("登録ボタン押下");
          },
        style: OutlinedButton.styleFrom(
            minimumSize: buttonSize,
            backgroundColor: Colors.white10,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.black26,
            disabledForegroundColor:  Colors.black54
        ),
        child: Text("登録",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ))
    );

    var continueToRegisterButton = OutlinedButton(
        onPressed: () {
          // データベース登録
        },
        style: OutlinedButton.styleFrom(
            minimumSize: buttonSize,
            backgroundColor: Colors.white10,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.black26,
            disabledForegroundColor:  Colors.black54
        ),
        child: Text("続けて登録",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ))
    );

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          registerButton,
          const SizedBox(width: 30),
          continueToRegisterButton
        ]
    );
  }
}