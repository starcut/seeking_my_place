import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    required double searchRange,
    required bool isSearchEnabled,
    required int itemsPerPage,
  }) = _AppSettings;
}
