class FavoritePlaceEntity {
  final int? id;
  final String placeName;
  final String address;
  final double latitude;
  final double longitude;
  final String url;
  final String category;
  final int purpose;
  final bool isVisited;
  final DateTime? registerAt;
  final DateTime? updateAt;

  FavoritePlaceEntity(
      {this.id,
      required this.placeName,
      required this.address,
      required this.latitude,
      required this.longitude,
      required this.url,
      required this.category,
      required this.purpose,
      required this.isVisited,
      this.registerAt,
      this.updateAt});

  factory FavoritePlaceEntity.fromData(dynamic data) {
    final int id = data['id'];
    final String placeName = data['place_name'];
    final String address = data['address'];
    final double latitude = data['latitude'];
    final double longitude = data['longitude'];
    final String url = data['url'];
    final String category = data['category'];
    final int purpose = data['purpose'];
    final bool isVisited = (data['is_visited'] > 0);
    final DateTime registerAt = DateTime.parse(data['register_at']);
    final DateTime updateAt = DateTime.parse(data['update_at']);

    final model = FavoritePlaceEntity(
        id: id,
        placeName: placeName,
        address: address,
        latitude: latitude,
        longitude: longitude,
        url: url,
        category: category,
        purpose: purpose,
        isVisited: isVisited,
        registerAt: registerAt,
        updateAt: updateAt);
    return model;
  }
}
