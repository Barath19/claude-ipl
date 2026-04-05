#!/bin/bash
# claude-ipl - Live IPL Score Status Line for Claude Code
# Fetches scores from ESPN Cricinfo API and displays in the status line

# Read Claude Code session JSON from stdin
input=$(cat)

# Extract session info
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# --- IPL Score Fetching with Cache ---
CACHE_FILE="/tmp/claude-ipl-cache"
CACHE_MAX_AGE=60  # refresh every 60 seconds

cache_is_stale() {
    if [ ! -f "$CACHE_FILE" ]; then
        return 0
    fi
    local file_mod
    if [[ "$OSTYPE" == "darwin"* ]]; then
        file_mod=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
    else
        file_mod=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
    fi
    [ $(($(date +%s) - file_mod)) -gt $CACHE_MAX_AGE ]
}

fetch_ipl_scores() {
    local scoreboard
    scoreboard=$(curl -s --max-time 5 "https://site.api.espn.com/apis/site/v2/sports/cricket/8048/scoreboard" 2>/dev/null)

    if [ -z "$scoreboard" ] || [ "$scoreboard" = "null" ]; then
        echo ""
        return
    fi

    # Get the most relevant match (live > pre > post)
    local event_id state
    event_id=$(echo "$scoreboard" | jq -r '
        [.events[]? | select(.status.type.state == "in" or .status.type.state == "post" or .status.type.state == "pre")] |
        sort_by(if .status.type.state == "in" then 0 elif .status.type.state == "pre" then 1 else 2 end) |
        .[0].id // empty')

    if [ -z "$event_id" ]; then
        echo ""
        return
    fi

    state=$(echo "$scoreboard" | jq -r --arg id "$event_id" '.events[]? | select(.id == $id) | .status.type.state')

    # Build score line from scoreboard
    local score_line
    score_line=$(echo "$scoreboard" | jq -r --arg id "$event_id" '
        .events[]? | select(.id == $id) |
        {
            state: .status.type.state,
            detail: .status.type.detail,
            competitors: [.competitions[0].competitors[]? | {
                team: .team.abbreviation,
                score: (.score // "-"),
                winner: (.winner // false)
            }]
        } |
        if .state == "in" then
            def simplify_score:
                if test("\\(") then
                    capture("^(?<runs>[^ ]+) \\((?<ov>[0-9.]+)") |
                    .runs + " (" + .ov + " ov)"
                else . end;
            "LIVE: " + (.competitors[0].team) + " " + (.competitors[0].score | simplify_score) + " vs " + (.competitors[1].team) + " " + (.competitors[1].score | simplify_score)
        elif .state == "post" then
            (.competitors | map(select(.winner == true))[0].team // "TBD") + " won | " + (.competitors[0].team) + " " + (.competitors[0].score) + " vs " + (.competitors[1].team) + " " + (.competitors[1].score)
        elif .state == "pre" then
            "Next: " + (.competitors[0].team) + " vs " + (.competitors[1].team) + " | " + .detail
        else empty end
    ' 2>/dev/null)

    # For live matches, fetch batsman details from summary API
    local batsmen_line=""
    if [ "$state" = "in" ]; then
        local summary_file="/tmp/claude-ipl-summary.json"
        curl -s --max-time 5 "https://site.api.espn.com/apis/site/v2/sports/cricket/8048/summary?event=$event_id" > "$summary_file" 2>/dev/null
        local summary_size
        if [[ "$OSTYPE" == "darwin"* ]]; then
            summary_size=$(stat -f %z "$summary_file" 2>/dev/null || echo 0)
        else
            summary_size=$(stat -c %s "$summary_file" 2>/dev/null || echo 0)
        fi

        if [ "$summary_size" -gt 10 ]; then
            local batting_team_id
            batting_team_id=$(jq -r '.header.competitions[0].status.battingTeamId // empty' "$summary_file" 2>/dev/null)

            if [ -n "$batting_team_id" ]; then
                batsmen_line=$(jq -r --arg btid "$batting_team_id" '
                    [.rosters[] |
                    select((.team.id | tostring) == ($btid | tostring)) |
                    .roster[]? |
                    select(.active == true) |
                    (.athlete.shortName) as $name |
                    ([.linescores[].linescores[].statistics.categories[].stats[] | select(.name == "runs")][0].displayValue // "0") as $runs |
                    ([.linescores[].linescores[].statistics.categories[].stats[] | select(.name == "ballsFaced")][0].displayValue // "0") as $balls |
                    {name: $name, runs: $runs, balls: $balls}] |
                    if length == 2 then "\(.[0].name)* \(.[0].runs)(\(.[0].balls)), \(.[1].name) \(.[1].runs)(\(.[1].balls))"
                    elif length == 1 then "\(.[0].name)* \(.[0].runs)(\(.[0].balls))"
                    else empty end
                ' "$summary_file" 2>/dev/null)
            fi
        fi
    fi

    if [ -n "$batsmen_line" ]; then
        echo "${score_line} | ${batsmen_line}"
    else
        echo "$score_line"
    fi
}

if cache_is_stale; then
    SCORES=$(fetch_ipl_scores)
    if [ -n "$SCORES" ]; then
        echo "$SCORES" > "$CACHE_FILE"
    fi
fi

SCORES=$(cat "$CACHE_FILE" 2>/dev/null)

# --- Display ---
if [ -n "$SCORES" ]; then
    echo "[$MODEL | ctx ${PCT}%] IPL: $SCORES"
else
    echo "[$MODEL | ctx ${PCT}%] IPL: No live matches"
fi
