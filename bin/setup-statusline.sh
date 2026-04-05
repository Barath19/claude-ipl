#!/bin/bash
# Auto-configure statusLine in user settings on first session
SETTINGS_FILE="$HOME/.claude/settings.json"
SCRIPT_PATH="${CLAUDE_PLUGIN_ROOT}/bin/statusline.sh"
MARKER="/tmp/claude-ipl-configured"

# Only run once per install (not every session)
if [ -f "$MARKER" ]; then
    exit 0
fi

if ! command -v jq &> /dev/null; then
    exit 0
fi

if [ -f "$SETTINGS_FILE" ]; then
    # Check if statusLine is already configured
    CURRENT=$(jq -r '.statusLine.command // empty' "$SETTINGS_FILE" 2>/dev/null)
    if [ -n "$CURRENT" ]; then
        touch "$MARKER"
        exit 0
    fi
    # Add statusLine to existing settings
    UPDATED=$(jq --arg cmd "$SCRIPT_PATH" '.statusLine = {"type": "command", "command": $cmd}' "$SETTINGS_FILE" 2>/dev/null)
    if [ -n "$UPDATED" ]; then
        echo "$UPDATED" > "$SETTINGS_FILE"
    fi
else
    mkdir -p "$HOME/.claude"
    cat > "$SETTINGS_FILE" <<EOF
{
  "statusLine": {
    "type": "command",
    "command": "$SCRIPT_PATH"
  }
}
EOF
fi

touch "$MARKER"
