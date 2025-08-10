Execute comprehensive SonarQube analysis for maintenance phase on main codebase using v0.2.0 features
1. Ensure currently on main branch (or switch to main)
2. Run `get-sonar-feedback metrics` to get overall health dashboard:
   - 🎯 循環的複雑度 and 🧠 認知的複雑度 trends
   - ⚡ 信頼性評価, 🔒 セキュリティ評価, 🏗️ 保守性評価
   - ⏱️ 技術的負債 accumulation
   - 💨 コードスメル, 🐛 バグ, 🔓 脆弱性 counts
   - 🔄 重複コード密度, 📄 コード行数 metrics
3. Run `get-sonar-feedback issues` for detailed issue analysis:
   - 総イシュー数 and 工数合計 calculation
   - 重要度別分類 (BLOCKER → CRITICAL → MAJOR → MINOR)
   - ルール別上位10件 pattern identification
   - 詳細イシュー一覧 with location-specific fixes
4. Combine metrics and issues data for maintenance roadmap
5. Prioritize by maintenance impact: BLOCKER > CRITICAL > technical debt hours
6. Create actionable improvement plan with effort estimates

## メンテフェーズ特有の重要な注意事項

**mainブランチ全体の品質向上を目的とした包括的な分析**

このコマンドは定期的なメンテナンス作業の一環として実行されるため、以下の観点を重視すること：

- **技術的負債の可視化**: ⏱️ 技術的負債の時間数から長期的影響を定量化
- **セキュリティファースト**: 🔒 セキュリティ評価「E」などの重大問題を最優先
- **コード品質トレンド**: 🧠 認知的複雑度や 💨 コードスメル の増加傾向を監視
- **優先度マトリックス**: BLOCKER (例: ハードコードされたパスワード) → CRITICAL → MAJOR の順で対応
- **工数ベースの計画**: issues サブコマンドの工数合計を基に現実的な改善計画を策定

すべての指摘に対して以下のアプローチを取ること：
- mainブランチの長期的な健全性を最優先に考える
- 開発チーム全体の生産性向上につながる改善を提案する
- 緊急度と重要度のマトリックスで優先順位を明確化する
- 段階的な改善計画を提示し、実行可能なアクションプランを作成する

## v0.2.0 活用例

実際に以下のように実行して包括的な分析を行う：

```bash
# Step 1: 全体メトリクスで健康状態把握
get-sonar-feedback metrics

# Step 2: 詳細イシュー分析で具体的問題特定  
get-sonar-feedback issues

# Step 3: 特定ブランチでの比較分析（必要に応じて）
get-sonar-feedback metrics -b develop
```

**分析結果の読み方:**
- 🔒 セキュリティ評価が「E」→ 即座に対応が必要
- ⏱️ 技術的負債が9時間超 → 段階的改善計画が必要
- BLOCKER/CRITICALイシュー → 次のリリース前に必ず修正
- 工数合計582分 → 約10時間の改善投資で品質向上可能