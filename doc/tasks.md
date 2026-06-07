# Tasks

## 共通ルール

- 変更ファイルは最小限
- 1 Task = 1 Commit粒度
- 1 Task 完了後は停止
- TODOコメント禁止
- debug print禁止
- mock実装禁止
- サンプルコード禁止
- 推測実装禁止

---

## Phase 1. Project Setup

### Task 1-1a
Flutter Clean Architecture directory structure 作成

#### 必読ファイル
- architecture.md
- prompt.md

#### 内容
- lib directory structure 作成
- features directory 作成
- shared directory 作成
- core directory 作成
- routes directory 作成

#### 完了条件
- architecture.md の構成に一致
- 空directoryのみ作成
- 不要ファイルが存在しない

#### 禁止
- provider作成
- feature実装
- sample code追加
- Generic/Baseクラス追加

---

### Task 1-1b
Flutter package 初期設定

#### 必読ファイル
- architecture.md
- prompt.md

#### 内容
- flutter_riverpod 導入
- go_router 導入
- freezed 導入
- build_runner 設定
- pubspec.yaml 更新

#### 完了条件
- flutter pub get 成功
- build_runner 実行可能

#### 禁止
- feature実装
- state実装
- mock実装
- 過剰wrapper追加

---

### Task 1-1c
Routing初期構築

#### 必読ファイル
- architecture.md
- prompt.md

#### 内容
- app_router.dart作成
- router_service.dart作成
- main.dart作成
- MaterialApp.router設定

#### 完了条件
- app_router.dart存在
- RouterService存在
- 起動可能

#### 禁止
- route大量追加
- 認証制御追加
- navigation abstraction追加

---

### Task 1-2
共通UI作成

#### 必読ファイル
- ui.md
- architecture.md
- prompt.md

#### 内容
- AppBarDefault
- PrimaryButton
- SecondaryButton
- DangerButton

#### 完了条件
- shared/widgets に配置
- Theme対応済み
- StatelessWidgetのみ使用

#### 禁止
- business logic追加
- 巨大Widget化

---

## Phase 2. Domain Layer

### Task 2-1
Place Entity作成

#### 内容
- Place Entity
- Purpose Entity

#### 参照
- db.md

#### 完了条件
- freezed生成完了
- immutable対応

---

### Task 2-2 [x]
Repository Interface作成

#### 内容
- PlaceRepository
- SettingsRepository

#### 完了条件
- domain/repositories に配置

---

## Phase 3. Infrastructure Layer

### Task 3-1
Local DB 基盤 ＆ Settingsデータ層作成

#### 内容
- ローカルDBの初期化処理（テーブル作成含む）
- SettingsLocalDataSource の作成（Read/Write）
- SettingsRepositoryImpl の作成

#### 完了条件
- 設定の読み書きがデータ層として独立して動作すること

---

### Task 3-2
Place Local DB datasource作成

#### 内容
- PlaceLocalDataSource の作成（CRUD）
- PlaceRepositoryImpl の作成（CRUD）

#### 完了条件
- datasource分離済み
- Repository実装済み

---

## Phase 4. Application Layer

### Task 4-1: Place系 UseCase 作成
- GetPlaceListUseCase
- GetPlaceMapUseCase
- GetPlaceDetailUseCase

### Task 4-2: Place操作 UseCase 作成
- CreatePlaceUseCase
- UpdatePlaceUseCase
- DeletePlaceUseCase

### Task 4-3: AppSettings系 UseCase 作成
- GetAppSettingsUseCase
- UpdateAppSettingsUseCase
- ObserveAppSettingsUseCase

### Task 4-4: SelectedPlaceState 作成
- 内容: 選択された場所のID（`selected_place_id`）を管理する状態管理クラスの作成
- 責務: 選択状態の保持、更新（`select(String? id)`）、クリア

#### 完了条件
- `@riverpod` アノテーションを使用したモダンな Notifier 形式で実装
- `part 'selected_place_state.g.dart';` を含めること
- `build_runner` により正常にコード生成が行われること
- UIが直接Repositoryを触らず、状態管理クラスを介して参照すること

---

## Phase 5. Presentation Layer

### Task 5-1
HomeScreen作成

#### 内容
- `lib/features/place/presentation/screens/home_screen.dart` の作成
- 以下のコンポーネントの配置と統合：
  - GoogleMap（地図表示、マーカー制御）
  - PlaceList（場所の一覧表示、スクロール・ハイライト、スワイプ削除）
  - SearchBar（キーワード検索）
  - RadiusFilter（範囲フィルター：100m〜50km、On/Off切り替え）

#### 参照
- spec.md
- ui.md

#### 完了条件
- **1. 双方向同期 (Map ⇔ List)**:
  - `ref.watch(selectedPlaceStateProvider)` を監視し、状態変更時にマップとリストを同期させること。
  - マーカーまたはリスト項目タップ時に `ref.read(selectedPlaceStateProvider.notifier).select(id)` を実行。
  - マーカー選択時：該当座標へカメラアニメーション移動、マーカー強調。
  - リスト選択時：該当項目を強調表示、必要に応じて自動スクロール。

- **2. 状態のクリア (Selection Clearing)**:
  - 地図上の空きスペースタップ時、または選択解除操作時に `select(null)` を実行し、選択状態を完全にクリアすること。
  - PlaceDetailScreen等で削除操作が行われた場合も `select(null)` が適切に発火すること。

- **3. フィルター連動 (Filter Synchronization)**:
  - RadiusFilter や SearchBar の操作により、現在選択中の `selected_place_id` が検索結果リストから除外される場合、不整合を防ぐために自動的に `select(null)` を実行すること。

- **4. ユーザー操作の実装**:
  - リスト項目ボタン：URLコピー機能の実装。
  - リスト項目ボタン：PlaceDetailScreen への遷移。
  - マップ長押し：新規作成モードで AddPlaceScreen への遷移（座標初期値保持）。
  - FAB：新規作成モードで AddPlaceScreen への遷移。


---

### Task 5-2
AddPlaceScreen作成

### Task 5-3
PlaceDetailScreen作成

### Task 5-4
SettingScreen作成

---

## Phase 6. Routing

### Task 6-1
GoRouter設定

#### 内容
- /home
- /place/new
- /place/:id
- /place/:id/edit
- /settings

#### 完了条件
- RouterService経由のみ遷移

---

## Phase 7. Validation

### Task 7-1
フォームバリデーション実装

#### 内容
- place_name required
- latitude range
- longitude range
- url validation

---

## Phase 8. State Management

### Task 8-1
HomeScreenState実装

### Task 8-2
AddPlaceScreenState実装

### Task 8-3
SettingScreenState実装

#### 完了条件
- loading/data/error 分離
- immutable state

---

## Phase 9. Testing

### Task 9-1
UseCaseテスト

### Task 9-2
Repositoryテスト

### Task 9-3
Widgetテスト