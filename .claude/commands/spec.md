# 仕様書作成

要求事項から詳細な仕様書を段階的に作成し、実装の指針となる文書を生成します。

## 仕様書の構成要素

1. **機能仕様**
   - ユーザーストーリー
   - ユースケース
   - 機能要件一覧
   - 非機能要件

2. **技術仕様**
   - システムアーキテクチャ
   - API仕様
   - データモデル
   - インターフェース定義

3. **実装仕様**
   - 詳細設計
   - アルゴリズム
   - エラーハンドリング
   - セキュリティ考慮事項

4. **運用仕様**
   - デプロイメント
   - 監視項目
   - パフォーマンス基準
   - 保守手順

## 作成プロセス

1. **要求収集**
   - ユーザーからの要求を整理
   - 曖昧な点を明確化
   - 優先順位の確認
   - スコープの定義

2. **分析と設計**
   - 既存システムとの整合性確認
   - 技術的実現可能性の検証
   - 制約条件の洗い出し
   - リスクの特定

3. **詳細化**
   - 各機能の詳細定義
   - データフローの明確化
   - 状態遷移の定義
   - エッジケースの考慮

4. **検証と承認**
   - 仕様の一貫性確認
   - テスト可能性の確認
   - レビューポイントの整理
   - 承認プロセス

## 出力形式

```markdown
# [機能名] 仕様書

## 1. 概要
### 1.1 目的
[この機能の目的と背景]

### 1.2 スコープ
- 含まれるもの: [...]
- 含まれないもの: [...]

## 2. 機能要件
### 2.1 ユーザーストーリー
- As a [ユーザー種別], I want [機能] so that [価値]

### 2.2 機能一覧
| ID | 機能名 | 説明 | 優先度 |
|----|--------|------|--------|
| F01 | [...] | [...] | 高/中/低 |

## 3. 技術仕様
### 3.1 アーキテクチャ
```mermaid
[アーキテクチャ図]
```

### 3.2 API仕様
#### エンドポイント: [パス]
- メソッド: [GET/POST/PUT/DELETE]
- リクエスト:
  ```json
  {
    "field": "type"
  }
  ```
- レスポンス:
  ```json
  {
    "field": "type"
  }
  ```

### 3.3 データモデル
```mermaid
erDiagram
[ERダイアグラム]
```

## 4. 実装詳細
### 4.1 処理フロー
1. [ステップ1]
2. [ステップ2]

### 4.2 エラーハンドリング
| エラーコード | 説明 | 対処法 |
|-------------|------|--------|
| E001 | [...] | [...] |

## 5. テスト計画
### 5.1 単体テスト
- [テストケース1]
- [テストケース2]

### 5.2 統合テスト
- [シナリオ1]
- [シナリオ2]

## 6. 承認
- 作成者: Claude
- 作成日: [日付]
- レビュー: [ ]
- 承認: [ ]
```

## 段階的な詳細化

仕様書は段階的に詳細化されます：
1. 初期ドラフト（概要レベル）
2. 詳細設計（実装可能レベル）
3. 最終仕様（完全な仕様）

各段階でレビューと承認を行います。