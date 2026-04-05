# claude-ipl

Live IPL cricket scores on your Claude Code status line.

![Status Line Example](https://img.shields.io/badge/IPL-LIVE:%20RCB%20250%2F3%20vs%20CSK%2058%2F3-red)

## What it shows

- **Live matches**: Score, overs, and current batsmen at crease with `*` on striker
- **Completed matches**: Winner and final scores
- **Upcoming matches**: Teams and schedule

```
[Opus | ctx 25%] IPL: LIVE: RCB 250/3 vs CSK 58/3 (4.5 ov) | Sarfaraz Khan* 36(17), Kartik Sharma 0(1)
```

## Install

```bash
npm install -g claude-ipl
```

## Setup

Run the setup command to configure Claude Code:

```bash
claude-ipl-setup
```

Then restart Claude Code.

### Manual setup

Add this to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "claude-ipl"
  }
}
```

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
- Shows current batsmen at the crease with their score(balls) during live matches
- Works on macOS and Linux

## License

MIT
