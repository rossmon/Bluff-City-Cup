# Backend Map

## Server
- **Host:** bitnami@3.149.108.246 (AWS Lightsail, us-east-2)
- **SSH:** `ssh -i ~/Downloads/LightsailDefaultKey-us-east-2.pem bitnami@3.149.108.246`
- **Web root:** `/var/www/html/bluffcitycup/`
- **Base URL:** `https://glizzyattheturn.app/bluffcitycup`

---

## Endpoint Reference

All legacy endpoints use GET params only. Spaces encoded as `!spa`, `&` as `!amp`.

### READ Endpoints

| File | Params | Returns |
|------|--------|---------|
| `tournament.php` | `?tournament=NAME` (optional) | Array of tournament records |
| `matches.php` | `?tournament=NAME` | All matches for tournament |
| `players.php` | `?tournament=NAME[&player=NAME]` | Players (all or one) |
| `scores.php` | `?tournament=NAME` | All hole scores for tournament |
| `rounds.php` | `?tournament=NAME` | Round → course assignments |
| `holes.php` | _(none)_ | All holes for all courses |
| `courses.php` | _(none)_ | All courses with slope/rating/par |
| `scorekeeper_matches.php` | `?tournament=NAME&scorekeeper=NAME` | Matches assigned to scorekeeper |
| `player_in_match.php` | `?tournament=NAME&player=NAME` | Non-empty array if player in active match |
| `check_create_password.php` | `?password=PASS` | Non-empty array if password valid |
| `get_user.php` | `?identifier=ID` | User profile record |
| `messages.php` | `?tournament=NAME` | Chat messages for tournament |
| `match_probabilities/match_probabilities.php` | `?tournament=NAME&round=N&match=N` | Win probability per hole |
| `powerrankings/api.php` | _(none)_ | Full power rankings dataset + users |
| `api.php` | _(none)_ | All historical data (see below) |

### WRITE Endpoints

| File | Key Params | DB Operation |
|------|-----------|--------------|
| `update_tournament.php` | `tournament, owner, commissioner, numberofmatches, currentround, maxhandicap, commishpassword, drinkcartavailable, drinkcartnumber` | UPSERT tournaments |
| `update_matches.php` | `tournament, round, matchgroup, match, course, format, scorekeeper, player1–4, player1–4team, tees, matchlength, currentscore, scorestring, winningteam, completed, startinghole, currenthole, points, numofplayers` | UPSERT matches |
| `update_scores.php` | `tournament, player, round, course, hole, actualscore` | UPSERT scores |
| `update_players.php` | `tournament, name, team, handicap` (handicap uses `!dot` for `.`) | UPSERT players |
| `update_rounds.php` | `tournament, round, course` | UPSERT rounds |
| `update_holes.php` | `course, holenumber, handicap, par, length, lat, long, tees` | UPSERT holes |
| `update_courses.php` | `course, tees, lat` (lat = slope — naming quirk) | UPSERT courses |
| `add_token.php` | `token, username` | UPSERT tokens |
| `post_message.php` | `tournament, user_identifier, content, type[, parent_id]` | INSERT messages |
| `post_reaction.php` | `message_id, user_identifier, reaction` | UPSERT reactions |
| `upsert_user.php` | `identifier, first_name, last_name, email` | UPSERT users |

### DELETE Endpoints

| File | Params | Action |
|------|--------|--------|
| `delete_matches.php` | `?tournament=NAME` | DELETE all matches for tournament |
| `delete_match.php` | `?tournament&round&matchgroup&match` | DELETE single match |
| `delete_scores.php` | `?tournament=NAME` | DELETE all scores for tournament |
| `delete_score.php` | `?tournament&player&round&hole` | DELETE single score |
| `delete_player.php` | `?tournament&player&team` | DELETE player |
| `delete_hole.php` | `?course&holenumber&tees` | DELETE hole |
| `delete_tournament.php` | `?tournament=NAME` | DELETE tournament record |

---

## api.php — History Website Mega-Endpoint

Returns one JSON object with all keys:

```json
{
  "success": true,
  "rows": [...],            // bcc_match_results — one row per team per match
  "yearOutcomes": [...],    // year_outcomes — final scores by year
  "matchCourses": [...],    // matches table — course/tees/length per match
  "holes": [...],           // holes table
  "scores": [...],          // scores table (BCC tournaments only)
  "playerHandicaps": [...], // players table (BCC tournaments only)
  "coursesMeta": [...],     // courses table
  "tournamentSettings": [...], // tournaments table (BCC only, distinct by year)
  "matchSummaries": [...],  // bcc_match_summaries — AI narratives
  "playerBios": [...],      // bcc_player_bios — AI bios + career stats
  "playerPictures": [...]   // files in assets/Pics/ matching pattern {red|blue}_{first}_{last}.{ext}
}
```

---

## Notification Server (server.py)

- **Runtime:** Python Flask, port 5000, runs as background process
- **Endpoint:** `POST http://glizzyattheturn.app:5000/send-notification`
- **Payload:** `{"title": "Round: 1, Match: 2", "message": "Blue def. Red 3&2."}`
- **Flow:** Reads all tokens from DB → sends individual APNs HTTP/2 requests with JWT auth
- **APNs key:** `./AuthKey_TG772SA5W2.p8` (relative to `/var/www/html/bluffcitycup/`)
- **Check if running:** `ps aux | grep server.py` on server
- **Start:** `nohup python3 server.py > nohup.out 2>&1 &` from web root

---

## Key Business Logic

### Match Completion
When `completed=1` is written to `matches` table, the iOS app calls `sendMatchNotification()` which POSTs to server.py. The notification goes to **all** registered tokens (not per-tournament).

### Score String Format
Stored as text like `"3 UP"`, `"1 DOWN"`, `"AS"` (all square). `winningteam` field stores `"Blue"`, `"Red"`, or `"AS"`.

### Tournament Naming
Must follow pattern `"Bluff City Cup YYYY"`. Year extracted from this string in reporting queries via `substring(BTRIM(tournament) from '([0-9]{4})$')`.

### Handicap Application
Max handicap cap is set per tournament (`maxhandicap` in tournaments table). Handicap strokes allocated by hole handicap order. Applied locally in iOS app, not in backend.

### Match Formats
- `"Match"` = Singles match play (2 players)  
- `"Alternate Shot"` = Doubles alternate shot (4 players)  
- Other doubles formats supported (4 players: player1+player3 vs player2+player4)

### Win Probability
Pre-computed lookup table embedded in `Tournament.swift` (static dictionary). Also stored in `matchprobabilities` DB table per hole, accessed via `match_probabilities.php`.
