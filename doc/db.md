# Database

## place_list

| 論理名 | 物理名 | Dart型 | DB型 | NULL | UNIQUE | DEFAULT | 説明 |
|---|---|---|---|---|---|---|---|
| 場所ID | place_id | String | uuid | NO |  | gen_random_uuid() | PK |
| 場所名 | place_name | String | varchar(255) | NO | NO |  |  |
| 住所 | address | String | text | NO | NO |  |  |
| 緯度 | latitude | double | double precision | NO | NO |  | -90〜90 |
| 経度 | longitude | double | double precision | NO | NO |  | -180~180 |
| URL | url | String | varchar(2048) | NO | NO |  |  |
| カテゴリ | category | String | varchar(255) | NO | NO |  | 将来的にmaster_table_categoryを追加 |
| 訪問済みか | is_visited | bool | boolean | NO | NO | false | true=訪問済み |
| 登録日 | created_at | DateTime | timestamp with time zone | NO | NO | CURRENT_TIMESTAMP |  |
| 更新日 | updated_at | DateTime | timestamp with time zone | NO | NO | CURRENT_TIMESTAMP | Triggerで自動更新 |

## master_table_purpose

| 論理名 | 物理名 | Dart型 | DB型 | NULL | UNIQUE | DEFAULT | 説明 |
|---|---|---|---|---|---|---|---|
| 使用目的ID | purpose_id | String | uuid | NO |  | gen_random_uuid() | PK |
| 使用目的名 | purpose_name | String | varchar(255) | NO | YES |  | 例: カフェ / 作業 / 誰かと会う |

## relation_place_purpose

| 論理名 | 物理名 | Dart型 | DB型 | NULL | UNIQUE | DEFAULT | 説明 |
|---|---|---|---|---|---|---|---|
| 場所ID | place_id | String | uuid | NO | NO |  | FK(place_list.place_id) |
| 使用目的ID | purpose_id | String | uuid | NO | NO |  | FK(master_table_purpose.purpose_id) |

## 制約

#### place_list

- PRIMARY KEY (place_id)
- CHECK (latitude BETWEEN -90 AND 90)
- CHECK (longitude BETWEEN -180 AND 180)

#### master_table_purpose

- PRIMARY KEY (purpose_id)
- UNIQUE (purpose_name)

## relation_place_purpose

- PRIMARY KEY (place_id, purpose_id)
- FOREIGN KEY (place_id)
  REFERENCES place_list(place_id)
  ON DELETE CASCADE
- FOREIGN KEY (purpose_id)
  REFERENCES master_table_purpose(purpose_id)
  ON DELETE CASCADE

## リレーション

place_list 1:N relation_place_purpose N:1 master_table_purpose

## 接続管理 (Connection Management)

SQLiteの複数コネクションによるロック (`database is locked`) およびアプリ起動時の二重初期化（レースコンディション）を防ぐため、データベースの接続管理は以下のルールを厳守する。

### 1. シングルトンパターンの適用
- `DatabaseHelper` は外部から直接インスタンス化できないよう、コンストラクタをプライベート化（`DatabaseHelper._()`）する。
- アプリ全体で唯一のインスタンス（`_instance`）を使い回す。

### 2. 初期化時のレースコンディション対策
- アプリ起動直後に複数のデータソースから同時に `initialize()` が呼び出された場合、二重に接続が開かれるのを防ぐため、初期化中の `Future` を `_initFuture` に保持する。
- 先行して走っている初期化処理がある場合は、後続の呼び出しはその `Future` の完了を待つ設計とする。

### 3. 外部キー制約の強制有効化
- SQLiteのデフォルト仕様では外部キー制約がオフになっているため、`openDatabase` の `onConfigure` コールバックにて、必ず `PRAGMA foreign_keys = ON;` を実行する。