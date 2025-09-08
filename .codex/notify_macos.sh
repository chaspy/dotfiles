#!/bin/bash
# ~/.codex/notify_macos.sh

# JSONから最後のエージェント発言を抽出
LAST_MESSAGE=$(echo "$1" | jq -r '.["last-assistant-message"] // "Codex task completed"' 2>/dev/null || echo "Codex task completed")

# メッセージを最初の100文字に制限して特殊文字を除去
CLEAN_MESSAGE=$(echo "$LAST_MESSAGE" | head -c 100 | tr -d '"' | tr -d "'" | tr '\n' ' ')

# 空の場合はデフォルトメッセージ
if [ -z "$CLEAN_MESSAGE" ]; then
    CLEAN_MESSAGE="Codex task completed"
fi

# osascriptで通知表示（より安全な方法）
/usr/bin/osascript <<EOF
display notification "$CLEAN_MESSAGE" with title "Codex"
EOF

