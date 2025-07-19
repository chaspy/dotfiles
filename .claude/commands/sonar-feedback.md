Execute get-sonar-feedback command and analyze the results
1. Run get-sonar-feedback $ARGUMENTS
2. Parse and summarize code quality issues
3. Prioritize critical and high severity findings
4. Suggest fixes for identified issues
5. Create actionable improvement plan

## 重要な注意事項

**絶対にチェックを通すためだけに ignore したり処理を削除したりしないこと。**

様々な非機能特性（パフォーマンス、セキュリティ、保守性、可読性、テスタビリティなど）を熟慮した上で、この指摘は許容することが良いと判断される場合でも、ユーザーの承認が得られるまで無視したり実装を除去することは禁止されている。

すべての指摘に対して以下のアプローチを取ること：
- 問題の本質的な解決を優先する
- 安易な回避策ではなく、コード品質の向上につながる修正を提案する
- トレードオフがある場合は、その詳細をユーザーに説明し、判断を仰ぐ