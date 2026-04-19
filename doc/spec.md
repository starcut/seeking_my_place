# 1. 概要
<!--
このアプリの目的と提供価値を簡潔に説明する

例：
社会人が自然に会話できる場を提供するマッチングアプリ
-->

---

# 2. ターゲットユーザー
<!--
- 年齢層：
- 属性（例：会社員 / 学生）：
- 利用シーン：
-->

---

# 3. ユースケース
ユーザーがどのように使うか

<!--
## UC-01：ログイン
1. ユーザーがアプリを起動
2. ログイン情報を入力
3. ログイン成功

## UC-02：マッチング
1. ユーザー一覧を見る
2. 気になる相手を選択
3. マッチ成立
-->

---

# 4. 機能一覧（機能単位で分解）
<!--
## 認証（auth）
- ログイン
- ログアウト

## プロフィール（profile）
- プロフィール作成
- 編集
- 表示

## マッチング（matching）
- ユーザー一覧表示
- マッチ処理

## チャット（chat）
- メッセージ送信
- メッセージ受信
-->

---

# 5. 画面一覧（UI単位）

## auth
- login_screen

## profile
- profile_screen
- edit_profile_screen

## matching
- match_list_screen

## chat
- chat_screen

---

# 6. データ構造（重要）
<!--
## User
- id: String
- name: String
- age: int
- bio: String

## Message
- id: String
- senderId: String
- content: String
- createdAt: DateTime
-->

---

# 7. API仕様（簡易でOK）

<!--
## POST /login
- request:
  - email
  - password
- response:
  - token

## GET /users
- response:
  - User[]
-->

---

# 8. 状態管理（Riverpod前提）
<!--
- authProvider：認証状態
- userProvider：ユーザー情報
- chatProvider：チャット状態
-->

---

# 9. アーキテクチャ

- Clean Architecture
- layers:
  - presentation
  - domain
  - data

---

# 10. ディレクトリ構成（AI用に明示）
<!--
lib/
 ├─ features/
 │   ├─ auth/
 │   │   ├─ presentation/
 │   │   ├─ domain/
 │   │   └─ data/
 │   ├─ profile/
 │   ├─ matching/
 │   └─ chat/
 └─ core/
-->

---

# 11. 制約（重要）

- Flutter + Riverpod を使用
- 1ファイル1責務
- UIとロジックを分離
- 不要な依存を追加しない

---

# 12. 非機能要件

- パフォーマンス：軽量に動作
- 可読性：高く保つ
- 拡張性：機能追加しやすい

---

# 13. 未決事項（Optional）
<!--
- 認証方式（Firebase or 独自API）
- デザイン方針
-->