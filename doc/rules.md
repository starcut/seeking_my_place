# Rules（AI仕様駆動開発・完成版）

---

# 0. Priority（最重要）

- 本ルールはAI生成コードの絶対仕様
- 例外は存在しない
- すべての層は「上位層からのみ呼び出される」

---

# 1. Architecture（アーキテクチャ）

## 依存方向

UI → Application → Domain → Infrastructure

- 逆方向のimport禁止
- DomainはFlutterに依存しない
- ApplicationはUIに依存しない

## レイヤー責務

- UI：表示・入力のみ（ロジック禁止）
- Application：状態管理・ユースケース制御
- Domain：ビジネスルール
- Infrastructure：外部アクセス（DB / Map / API）

---

# 2. Domain Layer

## Entityルール

- Entityは不変（immutable）
- ビジネスルールはEntityに持たせる
- UIロジック禁止

## ValueObject

- latitude / longitude はVOとして扱う
- 範囲チェックはVO内で行う

---

# 3. Application Layer

## UseCaseルール

- 1ユースケース = 1クラス
- UIはUseCaseのみ呼ぶ
- 複数Repositoryの統合はUseCaseで行う
- 副作用はUseCaseに閉じる

## State設計

- UI StateはView専用
- Domain Stateは禁止
- StateはImmutable classで管理

- Result型（Success / Failure）は全UseCaseで統一する
- Repositoryは例外を投げずFailureに変換する

---

# 4. Infrastructure Layer

## Repositoryルール

- 必ず interface + implementation を分離
- Infrastructureに実装を置く
- UI / Applicationは実装を知らない
- DBアクセスはRepositoryのみ
- QueryはRepository内部に閉じる
- transactionはRepository内で管理
- Repositoryはデータ取得・保存のみ
- 単純なフィルタ条件（id検索など）は許可
- 複雑な検索条件はUseCaseで構築

## Repositoryメソッド制限

- findById
- findByPlacename
- findByAddress
- findByDistance
- findByCategory
- findByPurposeId
- findAll
- insert
- update
- delete

---

## データアクセスルール

- SQL直書き禁止（Repository経由）
- DB操作はInfrastructure層のみ
- place_listへの直接更新禁止

---

# 5. Data Layer

- UI整形（フォーマット処理）はUI Modelで行う
- UseCaseはデータ取得とルール処理のみ

## DTO / Entity / UI Model（境界ルール）

- DTO：DB構造と完全一致するデータモデル
  - 目的：永続化・DB通信専用
  - ビジネスロジック禁止

- Entity：ドメインルールを持つ不変オブジェクト
  - 目的：アプリの中心概念
  - ビジネスルールを内包する
  - DB構造と完全一致する必要はない

- UI Model：画面表示専用データ
  - 目的：UI最適化（表示用変換済みデータ）
  - フォーマット済み文字列などを含む
  - Entityの直接使用は禁止
  - 文字列整形・表示用変換のみ許可
  - 表示専用の最終データ

---

## 禁止ルール

- DTOにビジネスロジックを書いてはいけない
- UI Modelにドメインロジックを書いてはいけない
- EntityはDB構造のコピーではなく「意味の単位」にする
- UseCaseでDTOを直接返すことは禁止
- UIでEntityを直接扱うことは禁止
- RepositoryがEntityを直接生成することは禁止（DTO経由のみ）
- UIからRepositoryを直接呼ぶことは禁止

---

## 変換ルール

- DTO ↔ Entity：Mapper経由のみ
- Entity ↔ UI Model：Mapper経由のみ
- UIでの変換処理は禁止

---

## Mapperルール

- MapperはData Layerにのみ配置する
- DTO ↔ Entity / Entity ↔ UI Model の変換のみ担当する
- 副作用を持たない純粋関数とする
- DB / UI / Domainロジックを含めてはいけない

---

## Result Flow

- Repository → Result<DTO>
- UseCase → Result<Entity>
- UI → Stateのみ参照（Result直接禁止）

---

# 6. Error Handling

- try-catchはRepository層で実施
- Infrastructure：例外発生元
- Repository：Exception → Failure変換
- UseCase：Failureをそのまま返す
- UI：表示のみ

---

# 7. State Management

- StateNotifier / AsyncNotifierを基本とする
- FutureProviderの多用禁止
- 状態は必ずimmutable
- loading / data / error の3状態を標準化
- Providerのネスト禁止
- ref.watch乱用禁止

---

# 8. UI Layer

## Widgetルール

- UIは表示のみ（ロジック禁止）
- StatelessWidget優先
- 1ファイル300行以内
- buildメソッド肥大化禁止
- 巨大Widget禁止
- setState禁止

## Navigation

- context.push / pop 直接禁止
- RouterService経由
- IDベース遷移（モデル禁止）
- Screen間でModelを渡さない
- Deep link対応可能構造

---

# 9. Performance

- build内で重い処理禁止
- const Widget優先
- ListView.builder必須
- rebuild最小化
- lazy load必須

---

# 10. Data Integrity

- latitude / longitudeは必ずバリデーション
- UUIDはアプリ生成禁止（DB / Infrastructure）
- nullは原則禁止（理由必須）
- VOで検証

---

# 11. Google Maps

- APIキーはコードに直書き禁止
- AndroidManifest / AppDelegateで管理
- MapControllerはProvider管理
- Marker生成はUseCaseでデータ変換後
- UIは描画のみ

---

# 12. Extensibility

- enumは禁止（master table優先）
- category / purpose はmaster table参照
- schema変更はmigration必須
- feature追加は既存コード改変最小化

---

# 13. Module Boundary

- feature単位でフォルダ分割
- cross-feature import禁止

---

# 14. Dart Rules

- null safety必須
- dynamic禁止
- any equivalent禁止

---

# 15. Naming Rules

- snake_case（ファイル）
- PascalCase（クラス）
- camelCase（変数）

---

# 16. Testing

- UseCaseは単体テスト対象
- Repositoryはmock可能設計
- UIテストはロジック検証しない

---

# 17. Strict Boundary Enforcement

- すべてのデータ変換はMapperを経由する
- Mapper以外での変換は禁止（UseCase / UI / Repository含む）
- データ構造変換とビジネスロジックは必ず分離する

---

# 18. Layer Data Ownership

- DTO：Infrastructureのみ所有
- Entity：Domainのみ所有
- UI Model：UI Layerのみ所有
- 他レイヤーは直接生成・編集してはいけない

---

# 19. Query Rule

- Repositoryはデータ取得・保存のみ
- 条件組み立ては禁止（複雑な検索条件はUseCase）
- Repositoryは以下のみ許可：
  - findById
  - findAll
  - insert
  - update
  - delete

---

# 20. Entity / DTO 判断ルール

- DB構造変更で影響 → DTO
- ビジネスルール変更で影響 → Entity
- UI表示変更で影響 → UI Model

---

# 21. Core Principle

データは「外側から内側へ変換して、内側ほど意味を持つ」