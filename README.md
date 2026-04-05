# claude-ipl

Live IPL cricket scores on your Claude Code status line.

## What it shows

- **Live matches**: Score, overs, and current batsmen at crease with `*` on striker
- **Completed matches**: Winner and final scores
- **Upcoming matches**: Teams and schedule

```
[Opus | ctx 25%] IPL: LIVE: RCB 250/3 vs CSK 58/3 (4.5 ov) | Sarfaraz Khan* 36(17), Kartik Sharma 0(1)
```

## Install

### Option 1: Plugin marketplace (recommended)

```bash
# Add the marketplace
/plugin marketplace add Barath19/claude-plugins-marketplace

# Install the plugin
/plugin install claude-ipl@barath19-plugins
```

Restart Claude Code and you're done.

### Option 2: Clone and load locally

```bash
git clone https://github.com/Barath19/claude-ipl.git
claude --plugin-dir ./claude-ipl
```

### Option 3: Manual setup

1. Clone the repo:

```bash
git clone https://github.com/Barath19/claude-ipl.git ~/.claude/claude-ipl
```

2. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/claude-ipl/bin/statusline.sh"
  }
}
```

3. Restart Claude Code.

## Requirements

- [jq](https://jqlang.github.io/jq/) - JSON processor
- curl

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq
```

## How it works

- Fetches live scores from ESPN Cricinfo API
- Caches results for 60 seconds to keep the status line fast
- Prioritizes live matches over upcoming/completed ones
- Shows current batsmen at the crease with runs(balls) during live matches
- Works on macOS and Linux

## License

MIT
