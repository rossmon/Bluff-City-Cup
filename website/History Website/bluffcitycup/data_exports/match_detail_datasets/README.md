# Match Detail Datasets

Generated from the live Bluff City Cup API plus app projection logic.

## Join Keys

- Primary key for match-level joins: `match_uid`
- Recommended cross-file join columns: `year`, `round`, `match`, `matchgroup`, `match_uid`

## Files

- `matches.csv`: one row per historical match with popup-level metadata (participants, location, course, tees, length, score, winner)
- `match_participants.csv`: participants for each match, including handicap index and derived course handicaps
- `match_team_handicaps.csv`: team handicap calculations and relative match strokes for team-handicap formats
- `match_holes.csv`: one row per match-hole with hole metadata, team actual/net scores, and hole winners
- `match_hole_player_scores.csv`: player-level actual/net scores per hole (all formats)
- `match_hole_popup_rows.csv`: scorecard rows as displayed in the popup (team rows for team formats, player rows for player-display formats)
- `match_probabilities_chart.csv`: hole-by-hole projection chart points using app static probability tables
- `match_probabilities_summary.csv`: final summary probabilities shown under the chart
- `data_quality_issues.csv`: missing metadata/lookup/projection issues encountered during export

## Net Scoring Logic

Net scores are computed using:

- player handicap by year from `players`
- hole handicap from `holes`
- course slope/rating/par from `courses`
- tournament `maxhandicap` from `tournaments`

The handicap and projection formulas mirror the logic in the iPhone app (`Tournament.swift` / `Player.swift`).
