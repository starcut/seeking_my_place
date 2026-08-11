import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

enum PurposeIcon {
  work(Symbols.laptop_mac),
  meal(Symbols.restaurant),
  rest(Symbols.coffee),
  scenery(Symbols.night_sight_auto),
  meetPeople(Symbols.groups),
  date(Symbols.favorite),
  unspecified(Symbols.more_horiz);

  const PurposeIcon(this.icon);

  final IconData icon;

  static PurposeIcon? fromPurposeName(String purposeName) {
    switch (purposeName) {
      case '作業':
        return PurposeIcon.work;
      case '食事':
        return PurposeIcon.meal;
      case '休憩':
        return PurposeIcon.rest;
      case '景色':
        return PurposeIcon.scenery;
      case '人と会う':
        return PurposeIcon.meetPeople;
      case 'デート':
        return PurposeIcon.date;
      case '':
        return PurposeIcon.unspecified;
      default:
        return null;
    }
  }
}
