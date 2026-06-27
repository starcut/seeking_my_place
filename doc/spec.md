# Spec

本ドキュメントはアプリの画面仕様および振る舞いを定義する。
UIの具体的なレイアウト構造（Widget構成）はui.mdに分離する。

---

# 1. Overview

## アプリ概要
- ローカルデータ管理アプリ（Place管理）
- 認証なし
- 外部APIなし
- 地図（Google Maps）を利用した位置ベース管理

---

# 2. Domain Model

## Entity
- Place
- Purpose

※詳細は db.md に準拠する

---

# 3. App Settings

## Overview

アプリ全体で永続的に保持されるユーザー設定。

ローカルストレージに保存され、アプリ再起動後も維持される。

UI Stateとは分離される。

---

## Settings Model

### AppSettings

- search_range: double
- is_search_enabled: bool
- items_per_page: int

---

## Persistence Rule

- すべての値はローカルストレージに保存される
- 変更時は即時保存される（auto-save）
- UseCase経由でのみ更新可能
- UIは直接更新不可

---

## Default Values

- search_range: 1000m
- is_search_enabled: true
- items_per_page: 50

---

## Allowed Values

### items_per_page
- 10
- 20
- 30
- 50
- 100
- 500
- 1000

---

## Data Access

- GetAppSettingsUseCase
- UpdateAppSettingsUseCase
- ObserveAppSettingsUseCase

---

# 4. Screen List

- HomeScreen
- PlaceDetailScreen
- AddPlaceScreen
- SettingScreen

---

# 5. Screen Overview

## 5.1. HomeScreen

---

### 5.1.1 Purpose

- MapとPlace一覧を統合し、地理的にPlaceを探索する
- Mapには現在地も表示させる
- 現在地からの指定した検索範囲ないのPlaceのみを表示する機能もつける
- 選択状態を中心にUIを同期させる

---

### 5.1.2 Data Sources

- GetPlaceListUseCase
- GetPlaceMapUseCase
- ObserveSelectedPlaceUseCase

---

### 5.1.3 State

#### Screen State (HomeScreenState)
- loading: bool
- places: List<Place>
- error: Failure?
- selected_place_id: String?

---

### 5.1.4 画面振る舞い

#### 検索範囲のルール
- Sliderで設定
  - 検索範囲は100m ~ 50km
- Switchで検索範囲のOn/Offを切り替える
  - Offの場合は検索範囲は無制限

#### フィルター適用時の挙動
- 検索範囲フィルター(Radius)またはキーワード検索(SearchBar)によって、現在選択中の `selected_place_id` が表示対象外（検索結果リスト外）となった場合、即座に `select(null)` を実行し、選択状態を解除すること。

---

#### 選択同期ルール

- Map上のmarker選択 → selected_place_idを更新
- Listのitem選択 → selected_place_idを更新

#### 選択状態変更時の挙動

selected_place_idが変更された場合：

##### Map側

- 対象Placeの位置へカメラ移動
- 対象markerを強調表示

##### List側

- 対象itemを強調表示
- 必要に応じてスクロール位置を調整

---

#### 状態の責務

- selected_place_idはApplication Layerが管理
- UIは購読のみ行い状態保持しない

---

### 5.1.5 ユーザー操作

- markerタップ → Place選択
- list itemタップ → Place選択
- list itemのボタン1 → Place選択のurlをクリップボードにコピー
- list itemのボタン2 → PlaceDetailScreenへ遷移（place_idベース）
- list itemを左スワイプ → item削除
- map長押し → 新規Place作成（位置初期値付き）
- FABタップ → Place作成画面
- sliderを動かす → 検索範囲を設定
- Switchをタップ → 検索範囲のOn/Offを切り替える

---

### 5.1.6 ナビゲーション

- AddPlaceScreenへ遷移（create mode）
- SettingScreenへ遷移（setting mode）

---

## 5.2. PlaceDetailScreen

---

### 5.2.1 Purpose

Placeの詳細情報を表示し、編集・削除・URLへのアクセスなどのアクションを提供する。

---

### 5.2.2 Data Source

- GetPlaceDetailUseCase(place_id)
- DeletePlaceUseCase

---

### 5.2.3 State
- AsyncValue<Place> (Riverpodで管理し、Loading/ErrorをUI層でハンドリングする)

---

### 5.2.4 画面振る舞い・表示仕様

#### 表示項目
- 以下の項目を適切なコンポーネントで表示する：
  - 場所の名前 (`placeName`)
  - 住所 (`address`)
  - 登録日時（フォーマットして表示）
  - メモ/詳細テキスト（未入力の場合はプレースホルダーを表示）

#### URLアクション
- 登録されたURLがある場合：
  - タップで外部ブラウザ（`url_launcher`等）を起動する。
  - または、クリップボードにコピーできるボタンを配置する（コピー成功時はスナックバーを表示）。

#### エッジケース対応
- **Loading状態**: データの取得中は、Shimmer等のローディングインジケーターを表示すること。
- **Error状態**: データの取得失敗時、または削除失敗時は、ユーザーフレンドリーなエラーメッセージと再試行ボタンを表示すること。

---

### 5.2.5 操作

- **編集ボタンタップ**: AddPlaceScreen（edit mode）へ遷移。
- **削除ボタンタップ**: 
  - 誤操作防止のため、削除確認ダイアログを表示する。
  - ダイアログ内の「削除」確定時、`DeletePlaceUseCase` を実行。
  - 削除成功時は、画面をポップして前の画面（HomeScreen）に戻る。

---

### 5.2.6 削除時の副作用

- 削除対象が `selected_place_id` と一致する場合：
  - `selected_place_id = null` に更新する（Application LayerのUseCaseまたはNotifier側で制御）。

---

### 5.2.7 コーディング規約 (本画面における絶対ルール)
- **L10nの徹底**: ダイアログ、スナックバー、プレースホルダーを含むすべての日本語文字列は `lib/l10n/app_ja.arb` に切り出すこと。コード内への直接のハードコードは一切禁止。
- **クリーンネーミング**: 単一文字（`p`, `ctx`, `e` など）や極端な略称の変数名・引数名は使用せず、一目で役割が理解できる明確な名称（`place`, `dialogContext`, `error` など）を使用すること。

---

## 5.3. AddPlaceScreen

---

### 5.3.1 Purpose

Placeの新規作成および編集

---

### 5.3.2 Mode

- create
- edit

---

### 5.3.3 Data Source

- edit時のみ GetPlaceDetailUseCase

---

### 5.3.4 Validation

- place_name: 必須
- latitude: -90〜90
- longitude: -180〜180
- latitude, longitudeはaddressから取得する

---

### 5.3.5 操作

#### 保存

- CreatePlaceUseCase または UpdatePlaceUseCaseを実行
- 成功時：
  - 画面を閉じる
  - selected_place_idを新規/更新IDに設定
  - placesを更新する
- 失敗時：
  - エラーダイアログを表示する
  - 文言はエラーの原因となる文言を表示する
  - ダイアログにはどじるボタン
---

### 5.4. SettingScreen

アプリ全体の処理の設定を編集・保存する

### 5.4.1. Purpose

- 一度に表示可能な件数を編集・保存する
- 検索範囲を編集・保存する

#### 一度に表示可能な件数のルール
- 表示件数（limit）
  - 許容値: 10, 20, 30, 50, 100, 500, 1000

#### 検索範囲のルール
- Sliderで設定
  - 検索範囲は100m ~ 50km
- Switchで検索範囲のOn/Offを切り替える
  - Offの場合は検索範囲は無制限

#### 保存

- 一度に表示可能な件数
- 検索範囲
- 検索範囲のOn/Off

#### キャンセル

- 前回保存した設定値に戻す

---

# 6. Route Definition

## Routes

- /home → HomeScreen
- /place/new → AddPlaceScreen (create mode)
- /place/:id → PlaceDetailScreen
- /place/:id/edit → AddPlaceScreen
- /settings → SettingScreen

# 7. Navigation Rules

- IDベース遷移のみ許可
- Entityの画面間受け渡し禁止
- RouterServiceを必ず使用する

---

# 8. Data Flow

UI
↓
UseCase
↓
Repository
↓
Infrastructure(DB)

---

# 9. State Management Rules

- places: 画面ローカル状態
- error: Failure型で管理
- loading: boolean

---

# 10. State Separation Rule

## AppSettings
- 永続状態（Local Storage）
- UIごとのStateとは独立

## ScreenState
- 画面単位の一時状態
- AppSettingsを直接保持しない
- UseCase経由で参照する

# 11. アーキテクチャルール

- UI層：表示のみ（ロジック禁止）
- Application層：状態管理・UseCase制御
- Domain層：ビジネスルール
- Infrastructure層：DB操作

---

# 12. 一貫性ルール

- selected_place_idは常に単一値
- Map/Listは同一状態を参照する
- UI間で状態のコピーは禁止

---

# 13. 非機能要件

- UIはロジックを持たない
- DBアクセスはRepositoryのみ
- UseCase経由でのみデータ操作可能
- 副作用はUseCaseに閉じる

---

# 14. Notes

- UI構造はui.mdに分離する
- spec.mdは「振る舞い・責務・状態定義」に限定する