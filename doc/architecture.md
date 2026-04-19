# アーキテクチャ概要

本プロジェクトは Clean Architecture + Feature First 構成を採用する

---

# 使用技術

- Flutter
- Riverpod（状態管理）
- go_router（ルーティング）
- REST API（外部API）
- ローカルDB（キャッシュ用）
- Google API（位置情報など）

---

# レイヤー構成

## 1. presentation
- UI（Widget）
- 状態管理（Riverpod Provider）

## 2. domain
- Entity
- UseCase（ビジネスロジック）
- Repository（抽象）

## 3. data
- Repository実装
- API通信
- ローカルDB操作

---

# ディレクトリ構成

lib/
 ├─ features/
 │   ├─ auth/
 │   │   ├─ presentation/
 │   │   │   ├─ screens/
 │   │   │   └─ providers/
 │   │   ├─ domain/
 │   │   │   ├─ entities/
 │   │   │   ├─ usecases/
 │   │   │   └─ repositories/
 │   │   └─ data/
 │   │       ├─ models/
 │   │       ├─ repositories/
 │   │       ├─ datasources/
 │   │
 │   ├─ profile/
 │   ├─ matching/
 │   └─ chat/
 │
 ├─ core/
 │   ├─ router/
 │   ├─ network/
 │   ├─ db/
 │   └─ utils/

---

# 状態管理ルール（Riverpod）

- Providerはpresentation層に配置
- ビジネスロジックはUseCaseに書く
- ProviderからUseCaseを呼び出す

---

# ルーティング（go_router）

- すべてのルートは core/router に集約
- 画面遷移は go_router 経由のみ

例：
- /login
- /home
- /profile

---

# データ取得ルール

- UI → Provider → UseCase → Repository → DataSource

---

# Repositoryルール

- domain：抽象定義
- data：実装

---

# API / DB

## API
- REST形式
- Dioを使用

## ローカルDB
- キャッシュ用途
- API優先、DBは補助

---

# Google API

- 位置情報取得に使用
- core配下にラップして配置

---

# 命名規則

- screen：xxx_screen.dart
- provider：xxx_provider.dart
- usecase：xxx_usecase.dart
- repository：xxx_repository.dart

---

# 禁止事項

- UIにビジネスロジックを書く
- Repositoryを直接UIから呼ぶ
- Providerにロジックを書きすぎる

---

# 依存関係ルール

presentation → domain → data の一方向のみ
逆依存は禁止