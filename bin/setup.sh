#!/bin/bash
# claude-ipl-setup - Configure Claude Code to use IPL status line

SETTINGS_FILE="$HOME/.claude/settings.json"
SCRIPT_PATH=$(which claude-ipl 2>/dev/null)

if [ -z "$SCRIPT_PATH" ]; then
    echo "Error: claude-ipl not found in PATH. Make sure the package is installed globally."
    exit 1
fi

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "  macOS:  brew install jq"
    echo "  Ubuntu: sudo apt install jq"
    exit 1
fi

# Check for curl dependency
if ! command -v curl &> /dev/null; then
    echo "Error: curl is required but not installed."
    exit 1
fi

# Create settings directory if needed
mkdir -p "$HOME/.claude"

# Update or create settings.json
if [ -f "$SETTINGS_FILE" ]; then
    # Add statusLine to existing settings
    UPDATED=$(jq --arg cmd "$SCRIPT_PATH" '.statusLine = {"type": "command", "command": $cmd}' "$SETTINGS_FILE" 2>/dev/null)
    if [ -n "$UPDATED" ]; then
        echo "$UPDATED" > "$SETTINGS_FILE"
    else
        echo "Error: Failed to parse existing $SETTINGS_FILE"
        exit 1
    fi
else
    cat > "$SETTINGS_FILE" <<EOF
{
  "statusLine": {
    "type": "command",
    "command": "$SCRIPT_PATH"
  }
}
EOF
fi

echo "claude-ipl setup complete!"
echo ""
echo "Status line configured at: $SETTINGS_FILE"
echo "Script path: $SCRIPT_PATH"
echo ""
echo "Restart Claude Code to see live IPL scores in your status line."
