# Security

## APIキー管理

Google Maps APIキーは外部公開禁止とする。

- Gitリポジトリに含めない
- .env または OS 環境変数で管理する
- Android/iOSビルド時に注入する

## 外部通信

本アプリはGoogle Maps SDKのみ外部通信を行う。

## データ管理

ローカルDBに保存され、クラウド同期は行わない。