# Swing Flix

Flix で実装した 15 パズルゲーム。Swing GUI + Flix のエフェクトシステムを活用。

## 必要環境

- devbox（推奨）

## 実行方法

```bash
devbox shell
flix run
```

## テスト

```bash
flix test
```

## プロジェクト構造

```
src/
  Main.flix        - エントリーポイント
  Game.flix        - ゲームループ（Game エフェクト定義）
  PuzzleLogic.flix - パズルロジック（Datalog で隣接判定）
  SwingLayer.flix  - Swing GUI 実装
```

## 特徴

- **エフェクトシステム**: `Game` エフェクトで UI 操作を抽象化
- **Datalog**: 隣接判定に Flix の Datalog を活用
