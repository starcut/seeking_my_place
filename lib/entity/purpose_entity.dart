class PurposeEntity {
  final int id;
  String purposeText;

  PurposeEntity({
    required this.id,
    required this.purposeText,
  });

  factory PurposeEntity.fromData(dynamic data) {
    final int id = data['id'];
    final String purposeName = data['purpose_text'];

    final model = PurposeEntity(
        id: id,
        purposeText: purposeName);
    return model;
  }

  factory PurposeEntity.fromMap(Map<String, Object?> map) {
    final int id = map['id'] as int;
    final String purposeText = map['purpose_text'] as String;

    final entity = PurposeEntity(
        id: id,
        purposeText: purposeText);
    return entity;
  }
}
