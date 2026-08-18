# 場所管理アプリ

お気に入りの場所を登録・管理するFlutterアプリです。
場所ごとにカテゴリや目的を設定し、登録した場所の検索・絞り込みなどを行えます。

## 主な機能

- 場所の登録・編集・削除
- 場所の検索・絞り込み
- カテゴリ・目的による場所の管理
- 地図上での場所の確認
- Google Mapsとの連携
- 外部サービスからの店舗情報取得
- JSON / TXTによるデータのエクスポート
- JSONデータのインポート
- アプリ設定

## 技術スタック

- Flutter / Dart
- Riverpod
- GoRouter
- Freezed
- Google Maps
- Clean Architecture

## アーキテクチャ

機能単位で責務を分離するfeature-based構成を採用し、
各機能を `data` / `domain` / `presentation` のレイヤーに分離しています。

```text
lib/
├── features/
│   └── place/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── routes/
├── shared/
├── l10n/
└── main.dart

