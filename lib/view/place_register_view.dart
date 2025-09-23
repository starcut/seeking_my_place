import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:seeking_my_place/api/controller/provider/dio_provider.dart';
import 'package:seeking_my_place/entity/favorite_place_entity.dart';
import 'package:seeking_my_place/entity/purpose_entity.dart';
import 'package:seeking_my_place/view_model/place_register_view_model.dart';

enum InputItem {
  url("URL"),
  placeName("場所名"),
  address("住所"),
  category("カテゴリ"),
  purpose("用途"),
  visited("訪問済み"),
  other("不明");

  const InputItem(this.name);

  final String name;

  static final Map<String, InputItem> _map = {
    for (final inputItem in InputItem.values) inputItem.name: inputItem
  };

  static InputItem getInputNameFromString(String value) {
    return _map[value] ?? InputItem.other;
  }
}

class PlaceRegisterView extends ConsumerWidget {

  PlaceRegisterView({super.key, required this.purposeList});

  List<PurposeEntity> purposeList = [];
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(placeRegisterViewModelNotifierProvider);

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
                registerItemCellView(viewModel, InputItem.url, "https://"),
                registerItemCellView(viewModel, InputItem.placeName, ""),
                registerItemCellView(viewModel, InputItem.address, ""),
                registerItemCellView(viewModel, InputItem.category, ""),
                registerItemCellView(viewModel, InputItem.purpose, ""),
                registerItemCheckBoxCellView(viewModel, InputItem.visited),
                const SizedBox(height: 15),
                buttonArea(viewModel, context, ref)
              ],
            )))
    );
  }

  // 登録のセル
  Widget registerItemCellView(PlaceRegisterViewModel viewModel, InputItem inputItem, String hintText) {
    return Consumer(builder: (context, ref, _) {
      var textInput = "";
      switch (inputItem) {
        case InputItem.placeName:
          textInput = ref.watch(placeRegisterViewModelNotifierProvider).placeName;
          break;
        case InputItem.address:
          textInput = ref.watch(placeRegisterViewModelNotifierProvider).address;
          break;
        case InputItem.category:
          textInput = ref.watch(placeRegisterViewModelNotifierProvider).category;
          break;
        default:
          break;
      }
      final controller = TextEditingController(text: textInput);

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(inputItem.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme
                      .of(context)
                      .primaryColor,
                ),
              )),
          Consumer(builder: (context, ref, _) {
            if(inputItem == InputItem.purpose) {
              return TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: hintText,
                ),
                onTap: () {
                  // キーボードが出ないようにする
                  FocusScope.of(context).requestFocus(new FocusNode());
                  ref.watch(placeRegisterViewModelNotifierProvider).purpose;
                  showPicker(context, controller);
                },
                onChanged: (text) async {
                  ref.read(placeRegisterViewModelNotifierProvider).purpose = text;
                  print(text);
                },
              );
        } else {
          return TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hintText,
            ),
            onChanged: (text) async {
              ref.read(placeRegisterViewModelNotifierProvider).setFavoritePlaceData(inputItem, text);
              if (inputItem == InputItem.url) {
                final placeName = await ref.read(placeRegisterViewModelNotifierProvider).getPlaceDataFromHTML(viewModel.url, InputItem.placeName);
                ref
                    .read(placeRegisterViewModelNotifierProvider)
                    .placeName = placeName;
                final address = await ref.read(placeRegisterViewModelNotifierProvider).getPlaceDataFromHTML(viewModel.url, InputItem.address);
                ref
                    .read(placeRegisterViewModelNotifierProvider)
                    .address = address;
                final category = await ref.read(placeRegisterViewModelNotifierProvider).getPlaceDataFromHTML(viewModel.url, InputItem.category);
                ref
                    .read(placeRegisterViewModelNotifierProvider)
                    .category = category;
              }
            },
          );
        }
      }),
          const SizedBox(height: 15)
        ],
      );
    });
  }

  void showPicker(BuildContext context, TextEditingController controller) {
    final list = this.purposeList.map((item) {
      return Text(item.purposeText);
    }).toList();

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
            children: list,
            onSelectedItemChanged: (int index) {
              selectedIndex = index;
              print("selected: ${this.purposeList[index].purposeText}");
            },
          )
        ),
      );
    }).then((_) {
      controller.value = TextEditingValue(text: this.purposeList[selectedIndex].purposeText);
    });
  }

  Widget registerItemCheckBoxCellView(PlaceRegisterViewModel viewModel, InputItem inputItem) {
    return Consumer(builder: (context, ref, _) {
      final changeNotifier = ref.watch(changeNotifierProvider);

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
        return Checkbox(
            value: ref.read(placeRegisterViewModelNotifierProvider).isVisited,
            activeColor: Colors.green,
            onChanged: (_) {
              ref.read(placeRegisterViewModelNotifierProvider).isVisited = !ref.read(placeRegisterViewModelNotifierProvider).isVisited;
            });
      })
        ],
      );
    });
  }

  Widget buttonArea(PlaceRegisterViewModel viewModel, BuildContext context, WidgetRef ref) {
    const buttonSize = Size(150, 40);

    var registerButton = OutlinedButton(
        onPressed: () async {
          final viewModel = ref.watch(placeRegisterViewModelNotifierProvider);
          LatLng? latLng = await viewModel.getLatLngFromAddress(viewModel.address);

          final favoritePlaceData = FavoritePlaceEntity(placeName: viewModel.placeName,
              address: viewModel.address,
              latitude: latLng?.latitude,
              longitude: latLng?.longitude,
              url: viewModel.url,
              category: viewModel.category,
              purpose: 0,
              isVisited: viewModel.isVisited);

          ref.read(placeRegisterViewModelInsertDataProvider(favoritePlaceData));
          Navigator.pop(context);
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