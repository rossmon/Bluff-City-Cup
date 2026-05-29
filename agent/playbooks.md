# Playbooks

## Feature Development

### Add a new iOS screen
1. Create `*ViewController.swift` in `iOS/Bluff City Cup/`
2. Add enum case to `CurrentView` in `ContainerViewController.swift`
3. Wire navigation in `ContainerViewController.swift`
4. If it needs data: add fetch method to `Model.swift`, call from view

### Add a new API call (iOS → backend)
1. Add PHP file in `/var/www/html/bluffcitycup/` following existing pattern
2. In `Model.swift`: add a `fetchXxxJSON()` method following the `URLSession.dataTask` pattern
3. Apply URL encoding before building URL: `.replacingOccurrences(of: " ", with: "!spa")`
4. Parse response with `JSONSerialization.jsonObject` → `NSArray` → `NSDictionary` pattern

### Add a new tournament setting
1. Add column to `tournaments` table in PostgreSQL
2. Update `update_tournament.php` to accept and write the new param
3. Update `tournament.php` to return it in SELECT
4. Update `Tournament.swift` to store it
5. Update `Model.parseJSONtournament()` to parse it
6. Update `Model.updateTournament()` URL to include the new param

---

## Bug Fixing

### Score not saving
- Check `Model.updateHoleScoreRecord()` in `Model.swift:80`
- Check `update_scores.php` — verify `actualscore` column and UPSERT
- Verify URL encoding of player name and tournament name
- Confirm `scores` table PK: `(player, tournament, round, hole)`

### Match score showing wrong
- Check `Match.getMatchScore()` — local calculation in `Match.swift`
- Check `Model.updateMatch()` which writes `currentscore` and `scorestring`
- Verify `Match.refreshHoleWinners()` is called after data load

### Push notifications not arriving
- Check `server.py` is running: `ps aux | grep server.py` on server
- Verify token exists in `tokens` table for device
- Check APNs key file exists at `./AuthKey_TG772SA5W2.p8` on server
- Check `AppDelegate.swift:58` — `didRegisterForRemoteNotificationsWithDeviceToken`
- `Model.pushDeviceToken()` at `Model.swift:1062` sends token to `add_token.php`

### History website data wrong
- All data for the history site comes from `api.php` (single endpoint)
- Operational tables (matches, players, scores) are live tournament data
- Reporting tables (bcc_match_results, year_outcomes) are populated separately — check those directly in DB
- Player pictures: `/var/www/html/bluffcitycup/assets/Pics/` — naming: `{red|blue}_{first}_{last}.{ext}`

---

## API Changes

### Change what a read endpoint returns
1. SSH to server: `ssh -i ~/Downloads/LightsailDefaultKey-us-east-2.pem bitnami@3.149.108.246`
2. Edit file: `sudo nano /var/www/html/bluffcitycup/matches.php` (or vi/vim)
3. Update the SELECT query
4. Update `Model.parseJSONmatches()` in iOS to handle new fields

### Add a new endpoint
1. Create PHP file on server at `/var/www/html/bluffcitycup/newfile.php`
2. Use legacy pattern (pg_connect) for simple CRUD or modern pattern (proc_open+psql) for complex JSON
3. Add call in `Model.swift` following existing fetch patterns
4. No Apache config needed — all .php files auto-served

---

## Database Updates

### Add a column
```sql
-- Connect: sudo -u postgres psql bluffcitycup
ALTER TABLE matches ADD COLUMN new_field VARCHAR(50);
```
Then update corresponding PHP files (insert, update, select).

### Query live tournament data
```sql
SELECT * FROM matches WHERE TRIM(tournament) = 'Bluff City Cup 2025';
SELECT * FROM players WHERE TRIM(tournament) = 'Bluff City Cup 2025';
SELECT * FROM scores  WHERE TRIM(tournament) = 'Bluff City Cup 2025';
```
Note: character(50) columns pad with spaces — use TRIM() in WHERE clauses.

### Update reporting tables (bcc_match_results, year_outcomes, etc.)
These are NOT written by the iOS app. They are populated manually or by external scripts.
- `bcc_match_results`: one row per team per match, with win/loss/tie and points
- `year_outcomes`: one row per tournament year with final team scores
- `bcc_match_summaries`: AI-generated match narratives
- `bcc_player_bios`: AI-generated player bios with career stats
- `bcc_power_rankings`: complex multi-metric player rankings, populated externally

---

## UI Updates

### Change scoreboard layout
- `ScoreboardViewController.swift` — main standings view
- `MatchTableViewCell.swift` / `MatchTableViewCell9.swift` / `MatchTableViewCell18.swift` — cell variants by match length

### Change score entry flow
- `ScoreEntryViewController.swift` — hole input, handicap strokes, advance logic

### Change match scorecard
- `MatchScorecardViewControllerNew.swift` — landscape grid view
- `MatchScorecardCellNew.swift` — individual cell in the grid

### Change captain's corner / chat
- Server: `/var/www/html/bluffcitycup/captain/captainscorner.php`
- Messages: `messages.php`, `post_message.php`, `post_reaction.php`
- DB: `messages` table (with threaded replies via `parent_id`) and `reactions` table
