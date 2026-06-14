# Architecture

## 技術スタック
- Flutter
- Riverpod
- GoRouter
- Freezed

## アーキテクチャ
Clean Architecture採用

## レイヤ構成
- presentation
- application
- domain
- data

## ディレクトリ構成

- Riverpodはapplication/stateに配置し、UIロジックと分離する
- providersはUseCaseのみを呼び出し、ビジネスロジックを持たない
- stateはUI専用のimmutable状態（loading / data / error）を定義する
- datasourceは外部アクセスのみを担当し、ビジネスロジックを持たない

lib/
  features/
    place/
      presentation/
        screens/
        widgets/

      application/
        usecases/
        providers/
        state/

      domain/
        entities/
        value_objects/
        repositories/   // interface only

      data/
        datasources/
          local/
          remote/
        dto/
        mappers/
        repositories/   // implementation

    map/
      presentation/
      application/
      domain/
      data/

    auth/
      presentation/
      application/
      domain/
      data/

  core/
    error/
    utils/
    constants/
    di/
    config/

  shared/
    widgets/
    extensions/
    themes/

  routes/
    app_router.dart

## 状態管理
Riverpod

## ルーティング
GoRouter

## API通信
現時点ではAPIは使用しない

## モデル生成
Freezed + json_serializable

## 起動時初期化と同期的DI（Dependency Injection）

### 方針
`runApp()` 実行前に、外部リソース（SQLite / SharedPreferences）の非同期初期化を完了させる。  
これにより、Riverpod プロバイダーは初期化済みのシングルトンインスタンスを **同期的に** 返すことができる。

### 初期化シーケンス（main.dart）
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.initialize();
  await SharedPreferencesSingleton.initialize();
  runApp(const ProviderScope(child: App()));
}
```

### Repositoryプロバイダーの定義規則
- プロバイダーの戻り値は `Future<T>` ではなく `T`（インターフェース型）とする。
- `DatabaseHelper.instance` / `SharedPreferencesSingleton.instance` は同期ゲッターであり、初期化未完了の場合は `StateError` を throw する。
- UseCase側は `ref.read(placeRepositoryProvider)` で即座にインスタンスを取得でき、`.future` 等の非同期待ちは不要。

### 禁止事項
- プロバイダー内で `await` / `FutureProvider` を使った遅延初期化
- `ref.watch(xxxRepositoryProvider.future)` による非同期解決
- Repositoryの二重初期化