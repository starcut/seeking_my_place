# AGENTS.md

## 基本ルール

Task実行時は、
Taskに必要なファイルのみ読むこと。

必要ファイルは tasks.md に記載する。

推測で全docを読まないこと。

---

## 実装ルール

- tasks.md を上から順に実行
- 1 Task 完了ごとに停止
- 推測実装禁止
- spec にない挙動は禁止
- 必要なファイルのみ読む
- 変更ファイルは最小限にする

---

## 禁止事項

- 過剰抽象化
- Generic/Baseクラス生成
- 未使用コード生成
- 将来拡張を前提とした実装
- tasks.md に存在しない実装

---

## 優先順位

1. architecture.md
2. db.md
3. spec.md
4. ui.md
5. rules.md
6. tasks.md

---

## 不明点

勝手に補完せず確認する