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
- infrastructure

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

      infrastructure/
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
      infrastructure/

    auth/
      presentation/
      application/
      domain/
      infrastructure/

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