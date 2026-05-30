# Records Validation Notes

Compare the native Records screen against:

https://glizzyattheturn.app/bluffcitycup/index.php

The iOS app uses the same dynamic JSON source as the website:

https://glizzyattheturn.app/bluffcitycup/api.php

## Checklist

- Confirm the Records menu item appears only after logging into a tournament whose name starts with `Bluff City Cup`.
- Confirm the Records menu item is absent for a non-Bluff City Cup tournament after login, tournament change, and app relaunch/session restore.
- Compare API counts in the app overview against the website payload: match-side rows, player bios, and player photos.
- Compare Points by Team by Year with the website chart/year outcome data.
- Compare Player Profiles: same Red/Blue players with uploaded photos, same bios, same career W-L-T and points.
- Compare Overall Records by Team and Format for All years and individual/multiple selected years.
- Compare Course Records using the course metadata attached to each match in the shared API payload.
- Compare Head-to-Head by selecting the same Red player and Blue player on the website and app; verify match count, format breakout, W-L-T, percentages, score, and rows.
- Compare Overall Player Records with the same team/year/format/player/min-match filters.
- Compare 2-Man Pairings with the same team/year/format/player/min-match filters and with format breakdown on/off.
- Compare Singles Records against the website Singles-format record logic.
- Compare All Match Outcomes with the same team/year/format/player filters; verify Red side, Blue side, winner, score, course, and match summary.

## Backend Assumptions

- `api.php` remains the canonical source for Records data.
- Player photos are resolved from `playerPictures.url` relative to `/bluffcitycup/`.
- No record result values are hardcoded in the iOS app.
