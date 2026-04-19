# タスクリスト

---

# フェーズ1：プロジェクト初期設定

- [ ] router設定（go_router）
- [ ] アプリのエントリーポイント設定（main.dart）
- [ ] 基本テーマ設定（Material）

---

# フェーズ2：認証（auth）

## UI
- [ ] login_screen作成

## 状態管理
- [ ] auth_provider作成

## ドメイン
- [ ] login_usecase作成
- [ ] auth_repository（抽象）作成

## データ
- [ ] auth_repository_impl作成
- [ ] auth_api_datasource作成

---

# フェーズ3：ユーザー（profile）

## UI
- [ ] profile_screen作成
- [ ] edit_profile_screen作成

## 状態管理
- [ ] user_provider作成

## ドメイン
- [ ] get_user_usecase作成
- [ ] update_user_usecase作成
- [ ] user_repository（抽象）作成

## データ
- [ ] user_repository_impl作成
- [ ] user_api_datasource作成

---

# フェーズ4：マッチング（matching）

## UI
- [ ] match_list_screen作成

## 状態管理
- [ ] user_list_provider作成

## ドメイン
- [ ] get_users_usecase作成

## データ
- [ ] user_list_repository_impl作成

---

# フェーズ5：チャット（chat）

## UI
- [ ] chat_screen作成（ダミー）

---

# フェーズ6：ローカルDB

- [ ] DB初期設定
- [ ] ユーザーデータキャッシュ処理

---

# フェーズ7：Google API（位置情報）

- [ ] 位置情報取得サービス作成
- [ ] 権限処理実装

---

# フェーズ8：統合・調整

- [ ] ログイン後の画面遷移
- [ ] エラーハンドリング
- [ ] ローディング処理

---

# 実装ルール

- 1タスクごとに実装する
- 必ずarchitecture.mdに従う
- rules.mdを厳守する
- 1タスクで複数ファイルを作成してよいが責務を守る