# AI開発ルール

## 基本的ルール

必ず以下のファイルを読み込んでから実装すること

1. doc/api.md
2. doc/architecture.md
3. doc/db.md
4. doc/deploy.md
5. doc/prompt.md
6. doc/rules.md
7. doc/security.md
8. doc/spec.md
9. doc/tasks.md
10. doc/test.md
11. doc/ui.md

- tasks.mdに記載されたタスクを上から順に実行する
- 1タスクごとに完了を確定してから次へ進む
- 推測実装は禁止（specにない挙動は追加しない）

## 優先順位

各ファイル間で矛盾がある場合は以下の優先順位に従

1. architecture.md（最優先の設計原則）
2. db.md（データ構造）
3. spec.md（振る舞い定義）
4. ui.md（表示仕様）
5. rules.md（制約）
6. tasks.md（実行手順）
7. その他ドキュメント

## 不明点に関して

勝手に補完せず、前提を保持したまま実装する