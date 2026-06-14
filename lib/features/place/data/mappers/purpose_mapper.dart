import 'package:seeking_my_place/features/place/data/dto/purpose_dto.dart';
import 'package:seeking_my_place/features/place/domain/entities/purpose.dart';

extension PurposeDtoMapper on PurposeDto {
  Purpose toEntity() {
    return Purpose(
      purposeId: purposeId,
      purposeName: purposeName,
    );
  }
}

extension PurposeEntityMapper on Purpose {
  PurposeDto toDto() {
    return PurposeDto(
      purposeId: purposeId,
      purposeName: purposeName,
    );
  }
}
