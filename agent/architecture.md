# Architecture

## System Overview

```
iOS App  ──GET──▶  PHP Endpoints  ──pg_query──▶  PostgreSQL (bluffcitycup)
                                                          │
tvOS App ──GET──▶  (same endpoints)                      │
                                                          │
History Website ──GET──▶  api.php (single endpoint) ─────┘
                    (returns all data in one JSON payload)

iOS App ──POST──▶  server.py :5000  ──APNs──▶  Registered iOS devices
```

## Frontend (iOS)

**Active project:** `iOS/Bluff City Cup.xcodeproj` with source under `iOS/Bluff City Cup/`.

**Archived project:** `archive/iOS Redesign/` is preserved for reference only. Do not use it for active development.

**Root:** `ContainerViewController` — slide-out navigation host

**Main views (each is a UIViewController):**
| View | File | Role |
|------|------|------|
| ViewController | ViewController.swift | Login / tournament selection |
| ScoreEntryViewController | ScoreEntryViewController.swift | Hole-by-hole score input |
| ScoreboardViewController | ScoreboardViewController.swift | Live standings |
| MatchScorecardViewControllerNew | MatchScorecardViewControllerNew.swift | Per-match scorecard (landscape) |
| HoleMapViewController | HoleMapViewController.swift | GPS hole map |
| DrinkCartViewController | DrinkCartViewController.swift | Drink cart contact |
| CommishSettingsViewController | CommishSettingsViewController.swift | Commissioner controls |

**Data layer:** `Model.sharedInstance` — single singleton, all network calls live here.  
Load sequence on login: players → courses → rounds → scores → matches → holes → tournament

**Domain models:**
- `Tournament` — holds all matches, players, courses, rounds; contains static win-probability tables
- `Match` — format, 2–4 players, round/group/match numbers, hole winners, score string
- `Player` — name, handicap, team (Red/Blue), hole results by round
- `Course` — name, tees, slope/rating/par, array of `Hole`
- `Hole` — number, par, handicap, length, GPS coordinate

**URL encoding (critical):** before building any URL, apply:
- spaces → `!spa`
- `&` → `!amp`
- `.` → `!dot` (handicap values)

## Backend

**Pattern:** One PHP file per resource/action. GET params only.  
**Two generations of PHP:**
- **Legacy** (most files): `pg_connect` + `pg_query` with string-concatenated SQL
- **Modern** (`api.php`, `powerrankings/api.php`): `proc_open` + `psql` CLI, returns structured JSON

**UPSERT pattern (legacy):** `INSERT ... ON CONFLICT (...) DO UPDATE SET ...`

**Special endpoints:**
- `api.php` — single mega-endpoint used by history website; returns all tables in one JSON blob
- `match_probabilities/match_probabilities.php` — reads pre-computed probabilities from DB
- `powerrankings/api.php` — returns full power rankings dataset
- `server.py` (Flask, port 5000) — receives POST from iOS, broadcasts APNs to all tokens in DB

## Database

**Two layers:**
1. **Operational** (written by iOS app in real-time during tournament play)
   - tournaments, matches, players, scores, rounds, holes, courses
2. **Analytics/Reporting** (populated externally, used by history website)
   - bcc_match_results, bcc_match_summaries, bcc_player_bios, bcc_power_rankings, year_outcomes, matchprobabilities

**Key relationships:**
```
tournaments (tournament PK)
    └── matches (tournament, round, matchgroup, match PK)
    └── players (name, tournament, team PK)
    └── rounds  (tournament, round PK)
    └── scores  (player, tournament, round, hole PK)

holes (course, tees, holenumber PK)
courses (name, tees PK)

messages (id PK)
    └── reactions (message_id FK → messages)

tokens (token, username PK)  ← device push tokens
```

## Data Flow: Live Match Scoring

```
1. Commissioner creates tournament → update_tournament.php
2. Commissioner adds players       → update_players.php
3. Commissioner creates matches    → update_matches.php (with player assignments)
4. Scorekeeper enters hole score   → update_scores.php
5. Model.updateHoleScoreRecord()   → Match recalculates score locally
6. Match.updateMatch()             → update_matches.php (currentscore, scorestring, winningteam)
7. Match completes                 → sendMatchNotification() → POST server.py:5000 → APNs broadcast
```
