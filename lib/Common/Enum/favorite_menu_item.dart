enum FavoriteMenuItem {
  edit("編集"),
  copyUrl("URLをコピー"),
  openBrowser("ブラウザで開く"),
  delete("削除"),
  unknown("不明");

  const FavoriteMenuItem(this.name);

  final String name;

  static final Map<String, FavoriteMenuItem> _map = {
    for (final favoriteMenuItem in FavoriteMenuItem.values) favoriteMenuItem.name: favoriteMenuItem
  };

  static List<String> getUseableString() {
    List<String> cases = <String>[];
    for (final favoriteMenuItem in FavoriteMenuItem.values) {
      cases.add(favoriteMenuItem.name);
    }
    cases.removeLast();
    return cases;
  }

  static FavoriteMenuItem getFavoriteMenuItemFromString(String value) {
    return _map[value] ?? FavoriteMenuItem.unknown;
  }
}