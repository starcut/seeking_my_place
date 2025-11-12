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