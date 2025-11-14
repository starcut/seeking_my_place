enum FavoriteListSortType {
  placeName('場所'),
  address('住所'),
  category('カテゴリ'),
  purpose('使用目的'),
  isVisited('訪問済み');

  const FavoriteListSortType(this.name);

  final String name;

  static final Map<String, FavoriteListSortType> _map = {
    for (final favoriteMenuItem in FavoriteListSortType.values) favoriteMenuItem.name: favoriteMenuItem
  };

  static List<String> getUseableString() {
    List<String> cases = <String>[];
    for (final favoriteMenuItem in FavoriteListSortType.values) {
      cases.add(favoriteMenuItem.name);
    }
    cases.removeLast();
    return cases;
  }

  static FavoriteListSortType getFavoriteMenuItemFromString(String value) {
    return _map[value] ?? FavoriteListSortType.address;
  }
}