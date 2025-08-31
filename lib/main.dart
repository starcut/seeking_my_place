import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/api/controller/database/database_manager.dart';

import 'package:seeking_my_place/view/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseManager.shared.initDatabase();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeView(),
    );
  }
}
