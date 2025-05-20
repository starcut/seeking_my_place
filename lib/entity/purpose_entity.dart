class PurposeEntity {
  final int id;
  final String purposeName;
  final DateTime registerAt;
  final DateTime updateAt;

  PurposeEntity({
    required this.id,
    required this.purposeName,
    required this.registerAt,
    required this.updateAt,
  });

  factory PurposeEntity.fromData(dynamic data) {
    final int id = data['id'];
    final String purposeName = data['purpose_name'];
    final DateTime registerAt = DateTime.parse(data['register_at']);
    final DateTime updateAt = DateTime.parse(data['updated_at']);

    final model = PurposeEntity(
        id: id,
        purposeName: purposeName,
        registerAt: registerAt,
        updateAt: updateAt);
    return model;
  }

  factory PurposeEntity.fromMap(Map<String, Object?> map) {
    final int id = map['id'] as int;
    final String purposeName = map['purpose_name'] as String;
    final DateTime registerAt = DateTime.parse(map['register_at'] as String);
    final DateTime updateAt = DateTime.parse(map['updated_at'] as String);

    final entity = PurposeEntity(
        id: id,
        purposeName: purposeName,
        registerAt: registerAt,
        updateAt: updateAt);
    return entity;
  }
}
