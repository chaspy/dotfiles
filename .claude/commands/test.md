# テスト実行

プロジェクトのテストを実行し、結果を分析します。

## プロセス

1. **テストフレームワークの検出**
   - package.json、Gemfile、go.mod などから使用言語を特定
   - テスト実行コマンドを特定（npm test、go test、pytest など）

2. **テストの実行**
   - 適切なテストコマンドを実行
   - エラーや失敗を記録

3. **結果の分析**
   - 失敗したテストの詳細を分析
   - 修正案を提案
   - 必要に応じてコードを修正

## 注意事項

- CIの設定がある場合は、それに従う
- カバレッジレポートがある場合は確認
- テストが無い場合は、その旨を報告