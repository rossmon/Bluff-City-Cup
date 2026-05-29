# Bluff City Cup Handicap Formulas

This document explains how match handicaps are calculated for each format in Bluff City Cup, based on the logic in:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Player.swift`
- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift`
- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Match.swift`

The important distinction is:

1. Convert a player's handicap index into a course handicap.
2. If the format uses a team handicap, combine player course handicaps into a team handicap.
3. Reduce the side or player to a match handicap when the format requires a low-player or low-team baseline.
4. Apply that match handicap hole by hole against the hole handicap to get the net score.

## Core Inputs

The formulas use these course and tournament inputs:

- `courseSlope`
- `courseRating`
- `coursePar`
- `maxHandicap`
- hole handicap / stroke index for each hole

## 1. Player Course Handicap

### Standard course handicap

Used for:

- Singles
- Best Ball
- Alternate Shot
- Two Man Scramble

Formula:

```text
course_handicap = round((player_handicap * courseSlope / 113) + (courseRating - coursePar))
course_handicap = min(course_handicap, maxHandicap)
```

Source:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Player.swift:129`

### Shamble course handicap

Used only for Shamble.

Formula:

```text
shamble_handicap = round(0.8 * ((player_handicap * courseSlope / 113) + (courseRating - coursePar)))
shamble_handicap = min(shamble_handicap, maxHandicap)
```

Source:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Player.swift:136`

## 2. Hole-Level Net Score Conversion

Once a player or team has a match handicap, that handicap is converted into strokes on individual holes by comparing it to the hole handicap.

Formula rules:

- If handicap is less than 18:
  - subtract 1 stroke on holes where `playerHandicap >= holeHandicap`
  - otherwise subtract 0
- If handicap is 18 to 35:
  - every hole gets at least 1 stroke
  - holes where `(playerHandicap - 18) >= holeHandicap` get a second stroke
- If handicap is 36 or more:
  - every hole gets at least 2 strokes
  - holes where `(playerHandicap - 36) >= holeHandicap` get a third stroke

Equivalent pseudocode:

```text
if handicap >= 36:
    if (handicap - 36) >= holeHandicap:
        net = actual - 3
    else:
        net = actual - 2
else if handicap >= 18:
    if (handicap - 18) >= holeHandicap:
        net = actual - 2
    else:
        net = actual - 1
else:
    if handicap >= holeHandicap:
        net = actual - 1
    else:
        net = actual
```

Sources:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2328`
- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Match.swift:501`

## 3. Format-Specific Handicap Logic

## Singles

Each player gets a full standard course handicap.

Then the lower-handicap player becomes the baseline:

```text
blue_match_handicap = blue_course_handicap - min(blue_course_handicap, red_course_handicap)
red_match_handicap  = red_course_handicap  - min(blue_course_handicap, red_course_handicap)
```

That means the lower player plays off 0, and the higher player gets only the difference.

Net scoring is then applied hole by hole using those differential handicaps.

Source path:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2238`

## Best Ball

Each player gets a full standard course handicap.

Then find the lowest handicap among all players in the match:

```text
lowest = min(all four player course handicaps)
```

Each player's match handicap is:

```text
player_match_handicap = player_course_handicap - lowest
```

So the lowest player in the match plays at 0 and everyone else plays off the difference.

Then:

- convert each player's actual score to a net score hole by hole
- the team score for the hole is the lower of the two player net scores

Source paths:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2095`
- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Match.swift:390`

## Shamble

Shamble works like Best Ball structurally, but it uses the Shamble handicap formula instead of the standard course handicap formula.

Steps:

1. Compute each player's shamble course handicap.
2. Find the lowest shamble handicap in the match.
3. Subtract that lowest value from every player's handicap.
4. Convert actual score to net score hole by hole.
5. Take the better net ball on each side as the team score for the hole.

Source paths:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2158`
- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Match.swift:393`

## Alternate Shot

Each side gets a team handicap built from the two players' standard course handicaps.

Active formula:

```text
team_handicap = round(0.50 * player1_course_handicap + 0.50 * player2_course_handicap)
```

Then use the lower team as the baseline:

```text
blue_match_handicap = blue_team_handicap - min(blue_team_handicap, red_team_handicap)
red_match_handicap  = red_team_handicap  - min(blue_team_handicap, red_team_handicap)
```

So the lower team plays at 0 and the higher team gets only the difference.

That match handicap is then applied to the team score hole by hole.

Source paths:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2065`
- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2387`

Note:

- There are old commented-out formulas using `60/40`.
- The active code uses `50/50`.

## Two Man Scramble

Each side gets a team handicap built from the two players' standard course handicaps.

Active formula:

```text
team_handicap = round(0.35 * player1_course_handicap + 0.15 * player2_course_handicap)
```

Then use the lower team as the baseline:

```text
blue_match_handicap = blue_team_handicap - min(blue_team_handicap, red_team_handicap)
red_match_handicap  = red_team_handicap  - min(blue_team_handicap, red_team_handicap)
```

That adjusted team handicap is then applied to the team score hole by hole.

Source paths:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2221`
- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2387`

## Four Man Scramble

Each side gets a team handicap using four weighted players, but this one is handled differently from the two-player formats.

Formula:

```text
p1 = min(round(player1_handicap * courseSlope / 113), maxHandicap)
p2 = min(round(player2_handicap * courseSlope / 113), maxHandicap)
p3 = min(round(player3_handicap * courseSlope / 113), maxHandicap)
p4 = min(round(player4_handicap * courseSlope / 113), maxHandicap)

team_handicap = round(0.20 * p1 + 0.15 * p2 + 0.10 * p3 + 0.05 * p4)
```

Then the lower team becomes the baseline the same way:

```text
blue_match_handicap = blue_team_handicap - min(blue_team_handicap, red_team_handicap)
red_match_handicap  = red_team_handicap  - min(blue_team_handicap, red_team_handicap)
```

That adjusted team handicap is then applied to the team score hole by hole.

Source paths:

- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2253`
- `/Users/rossmon/Developer/Bluff City Cup/Bluff City Cup/Tournament.swift:2375`

Important nuance:

- Four Man Scramble uses slope adjustment only.
- It does not add the `(courseRating - coursePar)` term before weighting.
- That makes it different from Singles, Best Ball, Shamble, Alternate Shot, and Two Man Scramble.

## 4. Practical Summary By Format

| Format | Starting handicap type | Team formula | Baseline adjustment | Hole scoring |
|---|---|---|---|---|
| Singles | Standard course handicap | None | Low player to 0 | Individual net score |
| Best Ball | Standard course handicap | None | Lowest player in match to 0 | Each player nets out, best net ball counts |
| Shamble | Shamble course handicap | None | Lowest shamble handicap in match to 0 | Each player nets out, best net ball counts |
| Alternate Shot | Standard course handicap | 50% + 50% | Low team to 0 | Team net score |
| Two Man Scramble | Standard course handicap | 35% + 15% | Low team to 0 | Team net score |
| Four Man Scramble | Slope-only adjusted handicaps | 20% + 15% + 10% + 5% | Low team to 0 | Team net score |

## 5. Website Format Name Mapping

The website uses slightly different labels from the iPhone app in some places:

- Website `Mod. Alt. Shot` = App `Alternate Shot`
- Website `2-Man Scramble` = App `Two Man Scramble`
- Website `4-Man Scramble` = App `Four Man Scramble`
- Website `Singles` corresponds to the match-play singles logic

## 6. One Concrete Example

If a Singles match has:

- Blue course handicap = 11
- Red course handicap = 7

Then the match handicaps are:

```text
Blue = 11 - 7 = 4
Red  = 7 - 7 = 0
```

Blue gets strokes only on holes with handicap 1 through 4.

If Blue makes `5` on a hole with handicap `3`, Blue's net score is:

```text
5 - 1 = 4
```

If Red makes `4` with a match handicap of `0`, Red stays at `4`.

The hole is tied.

## 7. Key Takeaways

- Handicap is not applied as a flat match-wide adjustment.
- It is converted into strokes on specific holes using hole handicap.
- Most formats first reduce everyone to a relative handicap by using the lowest player or lowest team as the baseline.
- Best Ball and Shamble are player-based net calculations where the side uses the best net ball.
- Alternate Shot and Scramble formats are team-based net calculations.
- Four Man Scramble is the outlier because its team handicap uses slope-only adjustment before the weighted blend.
