# Quickstart

## Read in This Order (2-minute onboarding)

1. **`metadata.yaml`** — What is this project, what's the stack, where is everything
2. **`architecture.md`** — How the pieces connect and data flow
3. **`playbooks.md`** — Find your task type and go directly to relevant files

Then open only the files that match your task (see `file_index.json`).

---

## Essential Facts

| Fact | Value |
|------|-------|
| App type | iOS golf tournament scoring app (Ryder Cup format) |
| Teams | Red vs Blue |
| Backend URL | `https://glizzyattheturn.app/bluffcitycup` |
| Server SSH | `ssh -i ~/Downloads/LightsailDefaultKey-us-east-2.pem bitnami@3.149.108.246` |
| Web root | `/var/www/html/bluffcitycup/` |
| Database | PostgreSQL `bluffcitycup` (connect: `sudo -u postgres psql bluffcitycup`) |
| iOS entry | `AppDelegate.swift` → `ContainerViewController` |
| Active iOS project | `iOS/Bluff City Cup.xcodeproj` |
| Data layer | `Model.sharedInstance` (all API calls live here) |
| Tournament key | `"Bluff City Cup YYYY"` exact string |
| URL encoding | spaces=`!spa`, `&`=`!amp`, `.`=`!dot` |

---

## Task Routing

| I need to... | Start here |
|-------------|-----------|
| Add/change a network call | `Model.swift` |
| Change what data the history website shows | `api.php` on server |
| Change iOS UI | find the `*ViewController.swift` in `file_index.json` |
| Add a DB column | `database_schema.md` → then update the PHP endpoint + Model.swift |
| Debug a score not saving | `Model.updateHoleScoreRecord()` → `update_scores.php` |
| Debug push notifications | `server.py` on server + `AppDelegate.swift` |
| Add a tournament setting | `update_tournament.php` + `tournament.php` + `Tournament.swift` + `Model.parseJSONtournament()` |
| Understand the power rankings | `bcc_power_rankings` table + `powerrankings/api.php` |
| Change match scoring logic | `Match.swift` (local calculation) |
| Understand win probabilities | `Tournament.swift` (static table) + `matchprobabilities` DB table |

---

## What NOT to Load

Unless your task specifically requires it, skip:

- `tvOS/` — separate scoreboard-only app, rarely modified
- `website/History Website/` — static HTML/CSS/JS files, rarely modified  
- `archive/iOS Redesign/` — archived SwiftUI/redesign experiment, preserved for reference only and **not active**
- `iOS/Bluff City Cup/Bluff City Cup/` (nested directories) — these are **duplicates from old git state**, not active code
- `*.psd` files — Photoshop design assets
- `BCC icons/` — app icon assets
- `Bluff City Cup.xcodeproj/xcuserdata/` — local Xcode user state
- `phpinfo.php` — debug only, not used in production

---

## Common Gotchas

1. **Padded strings:** DB `character(50)` columns pad with spaces. Always `TRIM()` in SQL.
2. **Nested callbacks in Model.getURLData():** loading order is sequential and intentional — don't parallelize.
3. **Slope stored as `lat`:** in `update_courses.php`, the slope rating is passed as the `lat` parameter (historical naming quirk).
4. **Match format naming:** DB stores `"Match"` for singles, but `api.php` renames it to `"Singles"` in output.
5. **No auth on write endpoints:** anyone knowing the URL can modify data — this is by design for the current user base.
6. **Player pic naming:** `{red|blue}_{firstname}_{lastname}.{ext}` — all lowercase, no spaces.
7. **Notification server may be down:** check with `ps aux | grep server.py` before debugging push issues.
