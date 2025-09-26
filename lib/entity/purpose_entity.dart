class PurposeEntity {
  final int id;
  String purposeName;

  PurposeEntity({
    required this.id,
    required this.purposeName,
  });

  factory PurposeEntity.fromData(dynamic data) {
    final int id = data['id'];
    final String purposeName = data['purpose_name'];

    final model = PurposeEntity(id: id, purposeName: purposeName);
    return model;
  }

  factory PurposeEntity.fromMap(Map<String, Object?> map) {
    final int id = map['id'] as int;
    final String purposeName = map['purpose_name'] as String;

    final entity = PurposeEntity(id: id, purposeName: purposeName);
    return entity;
  }
}
