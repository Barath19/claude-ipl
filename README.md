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

### As a Claude Code plugin

```bash
claude plugin install claude-ipl
```

Or test locally:

```bash
claude --plugin-dir /path/to/claude-ipl
```

### Manual setup

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/path/to/claude-ipl/bin/statusline.sh"
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
- Shows current batsmen at the crease with runs(balls) during live matches
- Works on macOS and Linux

## Plugin structure

```
claude-ipl/
├── .claude-plugin/
│   └── plugin.json      # Plugin manifest
├── bin/
│   └── statusline.sh    # Status line script
├── settings.json        # Auto-configures statusLine
├── package.json
├── README.md
└── LICENSE
```

## License

MIT
