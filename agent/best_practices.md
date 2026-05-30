# Best Practices

## Naming Conventions

### iOS
- Classes: PascalCase (`ScoreEntryViewController`, `MatchTableViewCell`)
- Files: match class name exactly
- Cell variants named with hole count suffix: `MatchTableViewCell9.swift`, `MatchTableViewCell18.swift`
- "New" suffix on refactored VCs kept for historical reasons (`MatchScorecardViewControllerNew`)
- Active iOS work belongs in `iOS/Bluff City Cup/`; `archive/iOS Redesign/` is inactive reference material only

### Backend
- PHP files: `{verb}_{noun}.php` for writes (`update_scores.php`, `delete_player.php`)
- PHP files: `{noun}.php` for reads (`matches.php`, `players.php`)
- DB column names: lowercase, no underscores except `green_cen_lat/long`, `win_or_loss`

### Database
- Tournament identifier: always `"Bluff City Cup YYYY"` (exact string)
- Team values: `"Red"` or `"Blue"` (capitalized, enforced by CHECK in bcc_match_results)
- Win/loss: `"Win"`, `"Loss"`, `"Tie"` (enforced by CHECK)

---

## URL Encoding (Critical)

All iOS → backend calls use GET requests. Before inserting any string into a URL:

```swift
let safe = value
    .replacingOccurrences(of: " ", with: "!spa")
    .replacingOccurrences(of: "&", with: "!amp")
// For handicap values only:
    .replacingOccurrences(of: ".", with: "!dot")
```

PHP decodes with:
```php
$value = str_replace("!spa", " ", $_GET['param']);
$value = str_replace("!amp", "&", $value);
```

Never use Swift's `addingPercentEncoding` for tournament/player names — the backend expects `!spa` encoding specifically.

---

## API Patterns

### iOS Network Call Template
```swift
func fetchXxxJSON(tournamentName: String, _ completion: @escaping (_ result: [Type]?, _ error: Error?) -> ()) {
    let tournamentNameURL = tournamentName
        .replacingOccurrences(of: " ", with: "!spa")
        .replacingOccurrences(of: "&", with: "!amp")
    
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let urlPath = Model.bluffCityCupBaseURL + "/endpoint.php?tournament=" + tournamentNameURL
    let task = session.dataTask(with: URL(string: urlPath)!) { data, response, error in
        guard error == nil, let data = data else { completion(nil, error); return }
        // parse with JSONSerialization → NSArray → NSDictionary
        completion(result, nil)
    }
    task.resume()
}
```

### PHP Legacy Write Template
```php
$result = pg_query($dbconn,
    "INSERT INTO table (col1, col2) VALUES ('$val1', $val2)
     ON CONFLICT (pk1, pk2) DO UPDATE SET col1 = '$val1', col2 = $val2"
);
```

### PHP Modern Read Template (api.php style)
```php
$sql = "SELECT COALESCE(json_agg(row_data), '[]'::json)::text FROM (...) AS row_data;";
$rows = runPsqlJson($sql);  // returns decoded array
echo json_encode(['success' => true, 'rows' => $rows]);
```

---

## Data Handling Rules

### Tournament Name as Key
The tournament name string is the join key across all operational tables. It must be exactly consistent. Any mismatch (including trailing spaces from char(50) columns) will cause missing data. The iOS app always reads back the trimmed name from the DB.

### Match Identity
A match is uniquely identified by `(tournament, round, matchgroup, match)`. These four values must be consistent across all writes.

### Player Identity
A player is identified by `(name, tournament, team)`. The name must match exactly across the players, scores, and matches tables.

### Score Entry vs Match State
Hole scores in the `scores` table are raw data. Match state (`currentscore`, `scorestring`, `winningteam`, `completed`) in the `matches` table is computed by the iOS app and written separately. The iOS app is the source of truth for match state — the DB stores what iOS computed.

### Handicap Application
- Handicap strokes are applied locally in iOS, never stored as net scores
- Stroke allocation: sort holes by `hole.handicap` (stroke index), allocate from 1 to player's max strokes
- Maximum handicap: capped by `tournament.maxhandicap`
- The `!dot` encoding is only needed for handicap decimal values in URLs

---

## Performance Considerations

### Load Sequence Matters
In `Model.getURLData()`, data is loaded in strict dependency order:
`players → courses → rounds → scores → matches → holes → tournament`
These are nested callbacks (not concurrent). Do not reorder.

### No Caching
The iOS app does not cache data locally. Every app launch or refresh triggers a full reload from the server. The `Model.refresh()` method re-runs the full load sequence.

### History Website
`api.php` returns all data in a single HTTP request. This is intentional — the website loads once and handles everything client-side. Don't split this into multiple calls.

---

## Security Notes (Known Issues — Do Not Silently Fix)

The following are known technical debt items. Before changing them, confirm with the project owner:

1. **No SQL injection protection** in legacy PHP files — string concatenation in queries
2. **DB credentials in plaintext** in all PHP files (`password=memphis`)
3. **APNs private key on disk** (`AuthKey_TG772SA5W2.p8`) in web root
4. **No authentication** on write endpoints — anyone with the URL can write data
5. **Commish password stored in plaintext** in the `tournaments` table
6. **Tournament creation password stored in plaintext** in `passwords` table
