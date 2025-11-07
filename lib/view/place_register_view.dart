import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:seeking_my_place/Common/Enum/input_item.dart';
import 'package:seeking_my_place/provider/place_register_provider.dart';

import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/provider/setting_provider.dart';

class PlaceRegisterView extends ConsumerWidget {

  PlaceRegisterView({super.key});

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(purposeListSettingProvider.notifier).getPurposeListAll();
    });

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: const Text("場所の登録"),
        ),
        body: SingleChildScrollView(
            child: Container( //SizedBoxでも可
                height: 639,
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    registerItemCellView(ref, context, InputItem.url, "https://"),
                    registerItemCellView(ref, context, InputItem.placeName, ""),
                    registerItemCellView(ref, context, InputItem.address, ""),
                    registerItemCellView(ref, context, InputItem.category, ""),
                    registerItemCellView(ref, context, InputItem.purpose, ""),
                    registerItemCheckBoxCellView(ref, InputItem.visited),
                    const SizedBox(height: 15),
                    buttonArea(ref, context)
                  ],
                )
            )
        )
    );
  }

  // 登録のセル
  Widget registerItemCellView(WidgetRef ref, BuildContext context, InputItem inputItem, String hintText) {
    var text = "";
    switch (inputItem) {
      case InputItem.url:
        text = ref.watch(urlTextFieldProvider);
        break;
      case InputItem.placeName:
        text = ref.watch(placeNameTextFieldProvider);
        break;
      case InputItem.address:
        text = ref.watch(addressTextFieldProvider);
        break;
      case InputItem.category:
        text = ref.watch(categoryTextFieldProvider);
        break;
      case InputItem.purpose:
        text = ref.watch(purposeTextFieldProvider).purposeName;
        break;
      default:
        break;
    }

    final controller = TextEditingController(text: text);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(inputItem.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).primaryColor,
              ),
            )),
          (inputItem == InputItem.purpose) ?
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hintText,
              ),
              onTap: () {
                // キーボードが出ないようにする
                FocusScope.of(context).requestFocus(new FocusNode());
                showPicker(context, ref, controller);
              },
              onChanged: (text) async {
                ref.read(purposeTextFieldProvider).purposeName = text;
              },
            ) : TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hintText,
              ),
              onChanged: (text) async {
                switch (inputItem) {
                  case InputItem.url:
                    ref.read(urlTextFieldProvider.notifier).updateText(text);
                    final placeName = await ref.watch(placeNameTextFieldProvider.notifier).getPlaceDataFromHTML(text, InputItem.placeName);
                    ref.read(placeNameTextFieldProvider.notifier).updateText(placeName);
                    final address = await ref.watch(addressTextFieldProvider.notifier).getPlaceDataFromHTML(text, InputItem.address);
                    ref.read(addressTextFieldProvider.notifier).updateText(address);
                    final category = await ref.watch(categoryTextFieldProvider.notifier).getPlaceDataFromHTML(text, InputItem.category);
                    ref.read(categoryTextFieldProvider.notifier).updateText(category);
                    break;
                  case InputItem.placeName:
                    ref.read(placeNameTextFieldProvider.notifier).updateText(text);
                    break;
                  case InputItem.address:
                    ref.read(addressTextFieldProvider.notifier).updateText(text);
                    break;
                  case InputItem.category:
                    ref.read(categoryTextFieldProvider.notifier).updateText(text);
                    break;
                  default:
                    break;
                }
              },
            )
      ],
    );
  }

  void showPicker(BuildContext context, WidgetRef ref, TextEditingController controller) {
    final purposeList = ref.read(purposeListSettingProvider);
    final purposeTextList = <Text>[];
    for (PurposeEntity purpose in purposeList) {
      purposeTextList.add(Text(purpose.purposeName));
    }

    showCupertinoModalPopup<void>(context: context,
        builder: (BuildContext context) {
      return Container(
        height: 216,
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            itemExtent: 32,
            children: purposeTextList,
            onSelectedItemChanged: (int index) {
              ref.read(purposeTextFieldProvider.notifier).updateText(purposeList[index].id);
            },
          )
        ),
      );
    }).then((_) {
      controller.value = TextEditingValue(text: purposeList[selectedIndex].purposeName);
    });
  }

  Widget registerItemCheckBoxCellView(WidgetRef ref, InputItem inputItem) {
    return Consumer(builder: (context, ref, _) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(inputItem.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme
                    .of(context)
                    .primaryColor,
              )),
      Consumer(builder: (context, ref, _) {
        final result = ref.watch(isVisitedTextFieldProvider);
        final notifier = ref.watch(isVisitedTextFieldProvider.notifier);

        return Checkbox(
            value: result,
            activeColor: Colors.green,
            onChanged: (isChecked) {
              if (isChecked == null) {
                notifier.updateText(false);
              } else {
                notifier.updateText(isChecked);
              }
            });
      })
        ],
      );
    });
  }

  Widget buttonArea(WidgetRef ref, BuildContext context) {
    const buttonSize = Size(150, 40);

    var registerButton = OutlinedButton(
        onPressed: () async {
          final url = ref.watch(urlTextFieldProvider);
          final placeName = ref.watch(placeNameTextFieldProvider);
          final address = ref.watch(addressTextFieldProvider);
          final category = ref.watch(categoryTextFieldProvider);
          final purpose = ref.watch(purposeTextFieldProvider).purposeName;
          final isVisited = ref.watch(isVisitedTextFieldProvider);

          LatLng? latLng = await ref.read(placeNameTextFieldProvider.notifier).getLatLngFromAddress(address);

          final favoritePlaceData = FavoritePlaceEntity(placeName: placeName,
              address: address,
              latitude: latLng?.latitude,
              longitude: latLng?.longitude,
              url: url,
              category: category,
              purpose: purpose,
              isVisited: isVisited);

          ref.read(placeRegisterNotifier.notifier).insertFavoriteData(favoritePlaceData);

          ref.read(urlTextFieldProvider.notifier).updateText("");
          ref.read(placeNameTextFieldProvider.notifier).updateText("");
          ref.read(addressTextFieldProvider.notifier).updateText("");
          ref.read(categoryTextFieldProvider.notifier).updateText("");
          ref.read(purposeTextFieldProvider.notifier).updateText(0);
          ref.read(isVisitedTextFieldProvider.notifier).updateText(false);
          
          Navigator.pop(context, true);
        },
        style: OutlinedButton.styleFrom(
            minimumSize: buttonSize,
            backgroundColor: Colors.white10,
            foregroundColor: Colors.black,
            disabledBackgroundColor: Colors.black26,
            disabledForegroundColor: Colors.black54
        ),
        child: Text("登録",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme
                  .of(context)
                  .primaryColor,
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
            disabledForegroundColor: Colors.black54
        ),
        child: Text("続けて登録",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme
                  .of(context)
                  .primaryColor,
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