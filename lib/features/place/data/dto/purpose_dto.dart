import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';

class PurposeDto {
  final String purposeId;
  final String purposeName;

  const PurposeDto({
    required this.purposeId,
    required this.purposeName,
  });

  factory PurposeDto.fromRow(Map<String, dynamic> row) {
    return PurposeDto(
      purposeId: row[DatabaseHelper.colPurposeId] as String,
      purposeName: row[DatabaseHelper.colPurposeName] as String,
    );
  }

  Map<String, dynamic> toRow() {
    return {
      DatabaseHelper.colPurposeId: purposeId,
      DatabaseHelper.colPurposeName: purposeName,
    };
  }
}
