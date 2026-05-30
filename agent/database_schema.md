# Database Schema

**Database:** `bluffcitycup` on localhost:5432  
**User:** `bcc_admin` (password: memphis)  
**Connect:** `sudo -u postgres psql bluffcitycup`

---

## Operational Tables (written by active iOS app during tournaments)

The active iOS app lives under `iOS/Bluff City Cup/`. The archived
`archive/iOS Redesign/` project is preserved for reference only and is not a
schema consumer to update during normal development.

### tournaments
Primary key: `(tournament, owner, commissioner)`  
Written by: `update_tournament.php`

| Column | Type | Notes |
|--------|------|-------|
| tournament | char(50) | Name, e.g. "Bluff City Cup 2025" — padded with spaces |
| owner | char(50) | Owner name |
| commissioner | char(50) | Commissioner name (same as owner) |
| matchlength | integer | Default match length (9 or 18) |
| numberofmatches | integer | Number of rounds |
| drinkcartavailable | integer | 0/1 flag |
| drinkcartnumber | char(20) | Phone number for drink cart |
| currentround | integer | Active round number |
| maxhandicap | integer | Handicap cap for tournament |
| commishpassword | varchar(20) | Commissioner password (plaintext) |

### matches
Primary key: `(tournament, round, matchgroup, match)`  
Written by: `update_matches.php`

| Column | Type | Notes |
|--------|------|-------|
| tournament | char(50) | |
| round | integer | Round number (1-based) |
| matchgroup | integer | Group within round |
| match | integer | Match number within group |
| course | char(50) | Course name |
| format | char(50) | "Match" (singles) or "Alternate Shot" (doubles) |
| scorekeeper | char(50) | Scorekeeper player name |
| points | numeric(10,2) | Points value for this match |
| numofplayers | integer | 2 or 4 |
| startinghole | integer | Starting hole (1–18) |
| currenthole | integer | Current hole being played |
| currentscore | integer | Score as integer (holes up) |
| scorestring | char(20) | Human-readable: "3 UP", "AS", "2 DOWN" |
| winningteam | char(50) | "Blue", "Red", or "AS" |
| completed | integer | 0 = in progress, 1 = finished |
| player1–4 | char(50) | Player names (player1+player3 = Blue, player2+player4 = Red) |
| player1–4team | char(50) | Team name for each player |
| tees | varchar(15) | Tees played (e.g. "White", "Blue") |
| matchlength | integer | 9 or 18 holes |

### players
Primary key: `(name, tournament, team)`  
Written by: `update_players.php`

| Column | Type | Notes |
|--------|------|-------|
| name | char(50) | Player name |
| tournament | char(50) | |
| team | char(25) | "Red" or "Blue" |
| handicap | numeric | Course handicap index |

### scores
Primary key: `(player, tournament, round, hole)`  
Written by: `update_scores.php`

| Column | Type | Notes |
|--------|------|-------|
| player | char(50) | Player name |
| tournament | char(50) | |
| round | integer | |
| course | char(50) | |
| hole | integer | Hole number (1–18) |
| actualscore | integer | Gross strokes |

### rounds
Primary key: `(tournament, round)`  
Written by: `update_rounds.php`

| Column | Type | Notes |
|--------|------|-------|
| tournament | char(50) | |
| round | integer | |
| course | char(50) | Course assigned to this round |

### holes
Primary key: `(course, tees, holenumber)`  
Written by: `update_holes.php`

| Column | Type | Notes |
|--------|------|-------|
| course | char(50) | Course name |
| holenumber | integer | 1–18 |
| handicap | integer | Hole handicap (stroke index) |
| par | integer | 3, 4, or 5 |
| length | integer | Yards |
| green_cen_lat | double | GPS latitude of green center |
| green_cen_long | double | GPS longitude of green center |
| tees | varchar(15) | |

### courses
Primary key: `(name, tees)`  
Written by: `update_courses.php`

| Column | Type | Notes |
|--------|------|-------|
| name | varchar(25) | Course name |
| tees | varchar(15) | |
| slope | integer | USGA slope rating |
| rating | numeric | Course rating |
| par | numeric | Total par |

### tokens
Primary key: `(token, username)`

| Column | Type | Notes |
|--------|------|-------|
| token | varchar(200) | APNs device token |
| username | varchar(50) | Device name (UIDevice.current.name) |

---

## Reporting / Analytics Tables (populated externally)

### bcc_match_results
One row per team per match (2 rows per match). Populated manually after each tournament.

| Column | Type | Notes |
|--------|------|-------|
| id | bigint | Auto-increment PK |
| player1–4 | text | Player names |
| team | text | "Red" or "Blue" (CHECK constraint) |
| round | integer | |
| match | integer | |
| year | integer | Tournament year |
| format | text | "Singles", "Alternate Shot", etc. |
| win_or_loss | text | "Win", "Loss", or "Tie" (CHECK constraint) |
| points | numeric(4,1) | Points earned |
| score | text | Score string |

### year_outcomes
One row per year. Final team scores.

| Column | Type | Notes |
|--------|------|-------|
| year | integer | PK |
| location | varchar(100) | Tournament location |
| blue_team_score | numeric(5,2) | Final Blue team points |
| red_team_score | numeric(5,2) | Final Red team points |

### bcc_match_summaries
AI-generated narrative for each match.

| Column | Type | Notes |
|--------|------|-------|
| year, round, match | text | Composite PK |
| match_uid | text | Unique ID for dedup |
| matchgroup | text | |
| format | text | |
| summary | text | AI-generated narrative |
| word_count | integer | |
| model | text | AI model used |

### bcc_player_bios
AI-generated bio with career statistics.

| Column | Type | Notes |
|--------|------|-------|
| player_name | text | PK |
| team | text | Indexed |
| first_name, last_name | text | |
| career_matches, wins, losses, ties | integer | Career stats |
| points | numeric(10,2) | Career points |
| bio | text | AI-generated bio |
| model | text | AI model used |

### bcc_power_rankings
Multi-metric player ranking system, per year.

Key columns: `ranking_year`, `player_name`, `team_2025`, `season_team`, `yearly_rank`, `cumulative_rank`, `yearly_power_score`, `cumulative_power_score`, `handicap_index`, `avatar_url`, `line_color`

Full column list includes: score performance (raw/adj), score index, win percentages (weighted/overall/singles), rounds played, matches played, weighted match units — all for both yearly and cumulative.

### matchprobabilities
Pre-computed win probabilities per hole state.

| Column | Type | Notes |
|--------|------|-------|
| tournament, round, matchgroup, match, hole_number, score_difference, tees | — | Composite unique |
| blue_win_probability, red_win_probability, tie_probability | double | |

---

## Support Tables

### messages
Tournament chat with threading support.

| Column | Type | Notes |
|--------|------|-------|
| id | integer | PK |
| tournament | varchar(255) | |
| user_identifier | varchar(255) | |
| content | text | |
| type | varchar(50) | Message type |
| parent_id | integer | FK → messages(id) for replies |
| media_url | text | Optional media |

### reactions
Emoji reactions to messages.

| Column | Type | Notes |
|--------|------|-------|
| id | integer | PK |
| message_id | integer | FK → messages |
| user_identifier | varchar(255) | |
| reaction | varchar(50) | |

### users
User profiles (identifier = device/login ID).

| Column | Type | Notes |
|--------|------|-------|
| identifier | varchar(255) | PK |
| first_name, last_name | varchar(255) | |
| email | varchar(255) | |

### passwords
Tournament creation passwords.

| Column | Type | Notes |
|--------|------|-------|
| password | varchar(20) | PK |
| active | varchar(1) | "Y" or "N" |

---

## Important Query Notes

- `character(N)` columns are **right-padded with spaces**. Always use `TRIM()` in WHERE clauses:  
  `WHERE TRIM(tournament) = 'Bluff City Cup 2025'`
- Tournament year extracted via regex: `substring(BTRIM(tournament) from '([0-9]{4})$')`
- Team Blue = player1 + player3; Team Red = player2 + player4 (doubles)
- Singles: only player1 (Blue) and player2 (Red)
