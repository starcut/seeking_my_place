import 'package:flutter/material.dart';
import 'package:seeking_my_place/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/database_helper.dart';
import 'package:seeking_my_place/features/place/data/datasources/local/settings_local_data_source.dart';

import 'routes/router_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Repositoryプロバイダーが同期的にインスタンスを取得できるよう、
  // runApp 前に非同期初期化を完了させる。
  await DatabaseHelper.initialize();
  await SharedPreferencesSingleton.initialize();

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
