import 'package:dio/dio.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider((ref) => Dio());

final ProviderListenable<dynamic> changeNotifierProvider =
ChangeNotifierProvider((ref) {
  return ChangeNotifier();
});
