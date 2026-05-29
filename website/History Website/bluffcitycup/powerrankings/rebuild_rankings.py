#!/usr/bin/env python3
from __future__ import annotations

import json
import math
import os
import statistics
import subprocess
import urllib.request
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


API_URL = os.environ.get("BCC_API_URL", "http://localhost/bluffcitycup/api.php")
PG_CONN = os.environ.get(
    "BCC_PG_CONN",
    "host=localhost port=5432 dbname=bluffcitycup user=bcc_admin sslmode=disable",
)
PG_PASSWORD = os.environ.get("BCC_PG_PASSWORD", "memphis")
OUTPUT_JSON = Path(__file__).resolve().with_name("power_rankings.snapshot.json")

COHORT_YEAR = 2025
MODEL_START_YEAR = 2017
COHORT_PLAYERS = {
    "Allen Bobango",
    "Brandon Byrd",
    "Buck Towner",
    "Daniel Wynn",
    "Drew Hursey",
    "Hunter Meriwether",
    "Jay Edwards",
    "Jay Snyder",
    "John Irvine",
    "Kevin Rea",
    "Kyle Cummins",
    "Louis Amagliani",
    "Luke Jensen",
    "Mac Plosser",
    "Owen Mercer",
    "Ross Montague",
    "Ryan Quinn",
    "William Harris",
}

FORMAT_MAP = {
    "Match": "Singles",
    "Best Ball": "Best Ball",
    "Shamble": "Shamble",
    "Mod. Alt. Shot": "Alternate Shot",
    "Alternate Shot": "Alternate Shot",
    "2-Man Scramble": "Two Man Scramble",
    "Two Man Scramble": "Two Man Scramble",
    "4-Man Scramble": "Four Man Scramble",
}

FORMAT_SCALE = {
    "Singles": 1.00,
    "Best Ball": 0.72,
    "Shamble": 0.72,
    "Alternate Shot": 0.82,
    "Two Man Scramble": 0.76,
    "Four Man Scramble": 0.58,
}

FORMAT_AGENCY = {
    "Singles": 1.00,
    "Best Ball": 0.92,
    "Shamble": 0.90,
    "Alternate Shot": 0.88,
    "Two Man Scramble": 0.84,
    "Four Man Scramble": 0.62,
}

SCORE_FORMAT_WEIGHT = {
    "Singles": 1.00,
    "Best Ball": 1.00,
    "Shamble": 1.00,
    "Alternate Shot": 0.82,
    "Two Man Scramble": 0.76,
    "Four Man Scramble": 0.58,
}

RECENCY_BASE = 0.84
SEED_SCALE = 18.0
SEASON_REGRESSION = 0.26
ROOKIE_SEED_WEIGHT = 0.45
MATCH_SAMPLE_TARGET = 12.0
RATING_BASE = 1500.0
RATING_DIVISOR = 240.0
HANDICAP_LOGISTIC_K = 0.051
K_BASE = 34.0
SCORE_SHRINK_ROUNDS = 4.0
WIN_SHRINK_WEIGHT = 6.0
SCORE_LOGISTIC_SCALE = 2.5
SINGLES_WIN_WEIGHT = 2.0
CUMULATIVE_WINDOW_YEARS = 5

RED_PALETTE = [
    "#bf0f21",
    "#cf2c2f",
    "#a90d22",
    "#d2473d",
    "#8f0b19",
    "#c85f54",
    "#a64a4b",
    "#e06a54",
    "#7f0916",
]

BLUE_PALETTE = [
    "#0b387e",
    "#2451a2",
    "#062558",
    "#3c6ab8",
    "#17458e",
    "#4b82c6",
    "#1a5bb1",
    "#5a92cf",
    "#15366f",
]


@dataclass
class MatchSide:
    team: str
    players: list[str]
    raw_format: str
    result: str
    points: float
    score: str


@dataclass
class MatchMeta:
    course: str
    tees: str
    raw_format: str
    match_length: int
    starting_hole: int = 1


def normalize(value: object | None) -> str:
    return " ".join(str(value or "").split())


def slugify_player(name: str) -> str:
    return normalize(name).lower().replace(" ", "_")


def normalize_avatar_url(url: str) -> str:
    value = normalize(url)
    if value.startswith("./assets/"):
        return "../assets/" + value[len("./assets/"):]
    return value


def fetch_api_payload() -> dict[str, object]:
    with urllib.request.urlopen(API_URL) as response:
        payload = json.loads(response.read().decode("utf-8"))
    if not payload.get("success"):
        raise RuntimeError(f"Source API failed: {payload.get('error') or 'unknown error'}")
    return payload


def psql(sql: str) -> None:
    command = [
        "psql",
        PG_CONN,
        "-v",
        "ON_ERROR_STOP=1",
        "-c",
        sql,
    ]
    env = dict(os.environ)
    env["PGPASSWORD"] = PG_PASSWORD
    subprocess.run(command, env=env, check=True)


def psql_admin(sql: str) -> None:
    command = [
        "sudo",
        "-u",
        "postgres",
        "psql",
        "-d",
        "bluffcitycup",
        "-v",
        "ON_ERROR_STOP=1",
        "-c",
        sql,
    ]
    subprocess.run(command, check=True)


def psql_literal(value: object | None) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


def course_handicap(index: float, slope: float, rating: float, par: float, max_handicap: int) -> int:
    return min(round((index * (slope / 113.0)) + (rating - par)), max_handicap)


def shamble_handicap(index: float, slope: float, rating: float, par: float, max_handicap: int) -> int:
    return min(round(0.8 * ((index * (slope / 113.0)) + (rating - par))), max_handicap)


def confidence_from_matches(prior_matches: int) -> float:
    if prior_matches <= 0:
        return 0.0
    return min(1.0, math.sqrt(prior_matches / MATCH_SAMPLE_TARGET))


def seed_rating_from_handicap(handicap: float, global_avg: float) -> float:
    return RATING_BASE + (global_avg - handicap) * SEED_SCALE


def weighted_average(entries: list[dict[str, float]], key: str, year: int, default: float) -> float:
    if not entries:
        return default

    total_weight = 0.0
    total_value = 0.0
    for entry in entries:
        weight = RECENCY_BASE ** max(0, year - int(entry["year"]) - 1)
        total_weight += weight
        total_value += float(entry[key]) * weight

    return total_value / total_weight if total_weight else default


def rolling_cumulative_years(all_years: list[int], anchor_year: int) -> list[int]:
    return [year for year in all_years if anchor_year - (CUMULATIVE_WINDOW_YEARS - 1) <= year <= anchor_year]


def recency_window_weight(source_year: int, anchor_year: int) -> float:
    age = anchor_year - source_year
    if age < 0 or age >= CUMULATIVE_WINDOW_YEARS:
        return 0.0
    return float(CUMULATIVE_WINDOW_YEARS - age)


def margin_index(score: str, result: str, match_length: int) -> float:
    token = score.upper().replace(" ", "")
    sign = 1.0 if result == "Win" else -1.0 if result == "Loss" else 0.0

    if result == "Tie" or token in {"AS", "TIE"}:
        return 0.0
    if "UP" in token:
        raw = int(token.replace("UP", ""))
    elif "&" in token:
        raw = int(token.split("&", 1)[0])
    else:
        raw = 0

    return sign * (raw / max(1.0, match_length / 3.0))


def strokes_received(course_handicap_value: int, hole_handicap: int) -> int:
    if course_handicap_value >= 36:
        return 3 if (course_handicap_value - 36) >= hole_handicap else 2
    if course_handicap_value >= 18:
        return 2 if (course_handicap_value - 18) >= hole_handicap else 1
    return 1 if course_handicap_value >= hole_handicap else 0


def played_holes(starting_hole: int, match_length: int) -> list[int]:
    hole = starting_hole
    sequence: list[int] = []
    for _ in range(match_length):
        sequence.append(hole)
        hole += 1
        if hole > 18:
            hole = 1
    return sequence


def build_payload(source: dict[str, object]) -> dict[str, object]:
    rows = source.get("rows", [])
    player_handicaps_rows = source.get("playerHandicaps", [])
    match_courses_rows = source.get("matchCourses", [])
    courses_meta_rows = source.get("coursesMeta", [])
    tournament_rows = source.get("tournamentSettings", [])
    player_pictures_rows = source.get("playerPictures", [])

    player_handicaps: dict[str, dict[int, float]] = defaultdict(dict)
    player_teams: dict[str, dict[int, str]] = defaultdict(dict)
    match_meta_by_key: dict[tuple[int, int, int], MatchMeta] = {}
    match_sides_by_key: dict[tuple[int, int, int], list[MatchSide]] = defaultdict(list)
    course_meta: dict[tuple[str, str], tuple[float, float, float]] = {}
    max_handicap_by_year: dict[int, int] = {}
    active_players_by_year: dict[int, set[str]] = defaultdict(set)
    all_years: set[int] = set()

    for row in player_handicaps_rows:
        year = int(row["year"])
        if year < MODEL_START_YEAR:
            continue
        name = normalize(row["name"])
        if not name:
            continue
        player_handicaps[name][year] = float(row["handicap"])
        player_teams[name][year] = normalize(row["team"])

    for row in match_courses_rows:
        key = (int(row["year"]), int(row["round"]), int(row["match"]))
        if key[0] < MODEL_START_YEAR:
            continue
        all_years.add(key[0])
        match_meta_by_key.setdefault(
            key,
            MatchMeta(
                course=normalize(row["course"]),
                tees=normalize(row["tees"]),
                raw_format="",
                match_length=int(normalize(row["matchlength"]) or "18"),
            ),
        )

    for row in rows:
        year = int(row["year"])
        if year < MODEL_START_YEAR:
            continue
        key = (year, int(row["round"]), int(row["match"]))
        players = [normalize(row[field]) for field in ("player1", "player2", "player3", "player4") if normalize(row[field])]
        for player in players:
            if player in COHORT_PLAYERS:
                active_players_by_year[year].add(player)
        if key in match_meta_by_key and not match_meta_by_key[key].raw_format:
            match_meta_by_key[key].raw_format = normalize(row["format"])
        match_sides_by_key[key].append(
            MatchSide(
                team=normalize(row["team"]),
                players=players,
                raw_format=normalize(row["format"]),
                result=normalize(row["win_or_loss"]),
                points=float(row["points"]),
                score=normalize(row["score"]),
            )
        )

    for row in courses_meta_rows:
        course_meta[(normalize(row["course"]), normalize(row["tees"]))] = (
            float(row["slope"]),
            float(row["rating"]),
            float(row["par"]),
        )

    for row in tournament_rows:
        max_handicap_by_year[int(row["year"])] = int(float(row["maxhandicap"]))

    picture_map = {
        slugify_player(f"{normalize(item['first'])} {normalize(item['last'])}"): normalize_avatar_url(item["url"])
        for item in player_pictures_rows
    }

    all_years |= set(active_players_by_year)
    years = sorted(all_years)
    global_avg_handicap = statistics.mean(
        handicap
        for per_player in player_handicaps.values()
        for handicap in per_player.values()
    )

    def handicap_for_year(player: str, year: int) -> tuple[float | None, bool]:
        data = player_handicaps.get(player, {})
        if year in data:
            return data[year], False
        if not data:
            return None, True

        known_years = sorted(data)
        prev_year = max((item for item in known_years if item < year), default=None)
        next_year = min((item for item in known_years if item > year), default=None)
        if prev_year is not None and next_year is not None:
            share = (year - prev_year) / (next_year - prev_year)
            return data[prev_year] + (data[next_year] - data[prev_year]) * share, True

        nearest = prev_year if prev_year is not None else next_year
        return data[nearest], True

    def normalize_format(raw_format: str, match_key: tuple[int, int, int]) -> str:
        meta = match_meta_by_key.get(match_key)
        if meta and meta.raw_format:
            return FORMAT_MAP.get(meta.raw_format, FORMAT_MAP.get(raw_format, raw_format))
        return FORMAT_MAP.get(raw_format, raw_format)

    def fallback_effective_handicap(format_name: str, players: list[str], year: int) -> float | None:
        indexes = []
        for player in players:
            handicap, _ = handicap_for_year(player, year)
            if handicap is None:
                return None
            indexes.append(handicap)
        indexes.sort()

        if format_name == "Singles":
            return indexes[0]
        if format_name == "Best Ball":
            return statistics.mean(indexes)
        if format_name == "Shamble":
            return statistics.mean(indexes) * 0.8
        if format_name == "Alternate Shot":
            return indexes[0] * 0.5 + indexes[1] * 0.5
        if format_name == "Two Man Scramble":
            return indexes[0] * 0.35 + indexes[1] * 0.15
        if format_name == "Four Man Scramble":
            return sum(value * weight for value, weight in zip(indexes, (0.20, 0.15, 0.10, 0.05)))
        return statistics.mean(indexes)

    def effective_handicap(match_key: tuple[int, int, int], side: MatchSide) -> tuple[float | None, str]:
        year = match_key[0]
        format_name = normalize_format(side.raw_format, match_key)
        meta = match_meta_by_key.get(match_key)

        if meta and (meta.course, meta.tees) in course_meta:
            slope, rating, par = course_meta[(meta.course, meta.tees)]
            max_handicap = max_handicap_by_year.get(year, 30)
            indexes = []
            for player in side.players:
                handicap, _ = handicap_for_year(player, year)
                if handicap is None:
                    indexes = []
                    break
                indexes.append(handicap)

            if indexes:
                if format_name == "Singles":
                    return course_handicap(indexes[0], slope, rating, par, max_handicap), format_name
                if format_name == "Best Ball":
                    values = [course_handicap(value, slope, rating, par, max_handicap) for value in indexes]
                    return statistics.mean(values), format_name
                if format_name == "Shamble":
                    values = [shamble_handicap(value, slope, rating, par, max_handicap) for value in indexes]
                    return statistics.mean(values), format_name
                if format_name in {"Alternate Shot", "Two Man Scramble"} and len(indexes) >= 2:
                    values = sorted(course_handicap(value, slope, rating, par, max_handicap) for value in indexes[:2])
                    if format_name == "Alternate Shot":
                        return round(values[0] * 0.5 + values[1] * 0.5), format_name
                    return round(values[0] * 0.35 + values[1] * 0.15), format_name
                if format_name == "Four Man Scramble" and len(indexes) >= 4:
                    values = [min(round(value * (slope / 113.0)), max_handicap) for value in sorted(indexes[:4])]
                    return round(sum(value * weight for value, weight in zip(values, (0.20, 0.15, 0.10, 0.05)))), format_name

        return fallback_effective_handicap(format_name, side.players, year), format_name

    latest_team_map: dict[str, str] = {}
    for player in COHORT_PLAYERS:
        latest_team_map[player] = player_teams.get(player, {}).get(COHORT_YEAR, "")

    ratings_end_of_year: dict[str, float] = {}
    history_logs: dict[str, list[dict[str, float]]] = {player: [] for player in COHORT_PLAYERS}
    season_rows: list[dict[str, object]] = []

    for year in years:
        active = sorted(active_players_by_year[year] & COHORT_PLAYERS)
        preseason_ratings: dict[str, float] = {}
        seed_ratings: dict[str, float] = {}

        for player in active:
            handicap, _ = handicap_for_year(player, year)
            seed_value = seed_rating_from_handicap(handicap if handicap is not None else global_avg_handicap, global_avg_handicap)
            seed_ratings[player] = seed_value
            if player in ratings_end_of_year:
                preseason_ratings[player] = (ratings_end_of_year[player] * (1.0 - SEASON_REGRESSION)) + (seed_value * SEASON_REGRESSION)
            else:
                preseason_ratings[player] = seed_value

        yearly_rows: list[dict[str, object]] = []
        for player in active:
            prior_logs = [entry for entry in history_logs[player] if int(entry["year"]) < year]
            prior_matches = len(prior_logs)
            confidence = confidence_from_matches(prior_matches)
            handicap, handicap_imputed = handicap_for_year(player, year)
            power_score = (
                RATING_BASE
                + confidence * (preseason_ratings[player] - RATING_BASE)
                + (1.0 - confidence) * ROOKIE_SEED_WEIGHT * (seed_ratings[player] - RATING_BASE)
            )
            yearly_rows.append(
                {
                    "year": year,
                    "player": player,
                    "team_2025": latest_team_map.get(player, ""),
                    "season_team": player_teams.get(player, {}).get(year, latest_team_map.get(player, "")),
                    "avatar_url": picture_map.get(slugify_player(player), ""),
                    "power_score": round(power_score, 4),
                    "preseason_rating": round(preseason_ratings[player], 4),
                    "seed_rating": round(seed_ratings[player], 4),
                    "handicap_index": round(handicap, 2) if handicap is not None else None,
                    "handicap_imputed": bool(handicap_imputed),
                    "prior_matches": prior_matches,
                    "confidence": round(confidence, 4),
                    "points_rate": round(weighted_average(prior_logs, "actual", year, 0.5), 4),
                    "over_expected": round(weighted_average(prior_logs, "over_expected", year, 0.0), 4),
                    "margin_index": round(weighted_average(prior_logs, "margin_index", year, 0.0), 4),
                    "best_prior_rating": round(max((float(entry["post_rating"]) for entry in prior_logs), default=RATING_BASE), 4),
                }
            )

        yearly_rows.sort(
            key=lambda row: (
                -float(row["power_score"]),
                float(row["handicap_index"]) if row["handicap_index"] is not None else 99.0,
                str(row["player"]),
            )
        )
        previous_ranks = {row["player"]: int(row["rank"]) for row in season_rows if int(row["year"]) == year - 1}
        for index, row in enumerate(yearly_rows, start=1):
            row["rank"] = index
            previous_rank = previous_ranks.get(str(row["player"]))
            row["trend"] = None if previous_rank is None else previous_rank - index
        season_rows.extend(yearly_rows)

        current_ratings = dict(preseason_ratings)
        for match_key in sorted(key for key in match_sides_by_key if key[0] == year):
            sides = match_sides_by_key[match_key]
            if len(sides) != 2:
                continue

            side_a, side_b = sides
            team_a = [player for player in side_a.players if player in COHORT_PLAYERS and player in current_ratings]
            team_b = [player for player in side_b.players if player in COHORT_PLAYERS and player in current_ratings]
            if not team_a and not team_b:
                continue

            handicap_a, format_name = effective_handicap(match_key, side_a)
            handicap_b, _ = effective_handicap(match_key, side_b)
            rating_a = statistics.mean(current_ratings[player] for player in team_a) if team_a else RATING_BASE
            rating_b = statistics.mean(current_ratings[player] for player in team_b) if team_b else RATING_BASE

            edge = (rating_a - rating_b) / RATING_DIVISOR
            if handicap_a is not None and handicap_b is not None:
                edge += HANDICAP_LOGISTIC_K * FORMAT_SCALE.get(format_name, 0.75) * (handicap_b - handicap_a)

            expected_a = 1.0 / (1.0 + math.exp(-edge))
            actual_a = side_a.points
            actual_b = side_b.points
            match_length = match_meta_by_key.get(match_key, MatchMeta("", "", side_a.raw_format, 18)).match_length
            side_a_margin = margin_index(side_a.score, side_a.result, match_length)
            multiplier = 1.0 + min(0.45, abs(side_a_margin) * 0.18)
            adjustment = K_BASE * FORMAT_AGENCY.get(format_name, 0.80) * multiplier * (actual_a - expected_a)

            for player in team_a:
                current_ratings[player] += adjustment
                history_logs[player].append(
                    {
                        "year": year,
                        "actual": actual_a,
                        "over_expected": actual_a - expected_a,
                        "margin_index": side_a_margin,
                        "post_rating": current_ratings[player],
                    }
                )
            for player in team_b:
                current_ratings[player] -= adjustment
                history_logs[player].append(
                    {
                        "year": year,
                        "actual": actual_b,
                        "over_expected": actual_b - (1.0 - expected_a),
                        "margin_index": -side_a_margin,
                        "post_rating": current_ratings[player],
                    }
                )

        ratings_end_of_year.update(current_ratings)

    rows_2025 = [row for row in season_rows if int(row["year"]) == COHORT_YEAR]
    team_order = {"Red": [], "Blue": []}
    for row in sorted(rows_2025, key=lambda item: int(item["rank"])):
        team = str(row["team_2025"] or "")
        if team in team_order:
            team_order[team].append(str(row["player"]))

    color_map: dict[str, str] = {}
    for team, palette in (("Red", RED_PALETTE), ("Blue", BLUE_PALETTE)):
        for index, player in enumerate(team_order[team]):
            color_map[player] = palette[index % len(palette)]

    for row in season_rows:
        row["line_color"] = color_map.get(str(row["player"]), "#5f6e8d")

    player_summary = []
    for player in sorted(COHORT_PLAYERS):
        years_active = sorted(int(row["year"]) for row in season_rows if row["player"] == player)
        player_summary.append(
            {
                "player": player,
                "team_2025": latest_team_map.get(player, ""),
                "avatar_url": picture_map.get(slugify_player(player), ""),
                "first_year": years_active[0],
                "latest_year": years_active[-1],
                "years_active": years_active,
            }
        )

    series = []
    for player in [row["player"] for row in sorted(rows_2025, key=lambda item: int(item["rank"]))]:
        summary = next(item for item in player_summary if item["player"] == player)
        points = []
        for year in years:
            match = next((row for row in season_rows if int(row["year"]) == year and row["player"] == player), None)
            if match:
                points.append(
                    {
                        "x": year,
                        "y": int(match["rank"]),
                        "powerScore": float(match["power_score"]),
                        "handicapIndex": match["handicap_index"],
                        "priorMatches": int(match["prior_matches"]),
                        "confidence": float(match["confidence"]),
                    }
                )
            else:
                points.append({"x": year, "y": None})

        current_row = next(row for row in rows_2025 if row["player"] == player)
        series.append(
            {
                "player": player,
                "team": summary["team_2025"],
                "avatarUrl": summary["avatar_url"],
                "firstYear": summary["first_year"],
                "latestYear": summary["latest_year"],
                "lineColor": color_map.get(player, "#5f6e8d"),
                "latestRank": int(current_row["rank"]),
                "latestScore": float(current_row["power_score"]),
                "trend": current_row["trend"],
                "points": points,
            }
        )

    return {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "cohortYear": COHORT_YEAR,
        "cohortSize": len(COHORT_PLAYERS),
        "years": years,
        "players": player_summary,
        "rankings": season_rows,
        "series": series,
        "leaderboard2025": rows_2025,
    }


def build_payload_v2(source: dict[str, object]) -> dict[str, object]:
    rows = source.get("rows", [])
    player_handicaps_rows = source.get("playerHandicaps", [])
    match_courses_rows = source.get("matchCourses", [])
    scores_rows = source.get("scores", [])
    holes_rows = source.get("holes", [])
    courses_meta_rows = source.get("coursesMeta", [])
    tournament_rows = source.get("tournamentSettings", [])
    player_pictures_rows = source.get("playerPictures", [])

    player_handicaps: dict[str, dict[int, float]] = defaultdict(dict)
    player_teams: dict[str, dict[int, str]] = defaultdict(dict)
    match_meta_by_key: dict[tuple[int, int, int], MatchMeta] = {}
    match_sides_by_key: dict[tuple[int, int, int], list[MatchSide]] = defaultdict(list)
    course_meta: dict[tuple[str, str], tuple[float, float, float]] = {}
    holes_meta: dict[tuple[str, str], dict[int, dict[str, int]]] = defaultdict(dict)
    max_handicap_by_year: dict[int, int] = {}
    active_players_by_year: dict[int, set[str]] = defaultdict(set)
    score_map: dict[tuple[int, int, str], dict[int, int]] = defaultdict(dict)
    all_years: set[int] = set()

    for row in player_handicaps_rows:
        year = int(row["year"])
        if year < MODEL_START_YEAR:
            continue
        name = normalize(row["name"])
        if not name:
            continue
        player_handicaps[name][year] = float(row["handicap"])
        player_teams[name][year] = normalize(row["team"])

    for row in match_courses_rows:
        key = (int(row["year"]), int(row["round"]), int(row["match"]))
        if key[0] < MODEL_START_YEAR:
            continue
        all_years.add(key[0])
        match_meta_by_key.setdefault(
            key,
            MatchMeta(
                course=normalize(row["course"]),
                tees=normalize(row["tees"]),
                raw_format="",
                match_length=int(normalize(row["matchlength"]) or "18"),
                starting_hole=int(normalize(row["startinghole"]) or "1"),
            ),
        )

    for row in rows:
        year = int(row["year"])
        if year < MODEL_START_YEAR:
            continue
        key = (year, int(row["round"]), int(row["match"]))
        players = [normalize(row[field]) for field in ("player1", "player2", "player3", "player4") if normalize(row[field])]
        for player in players:
            if player in COHORT_PLAYERS:
                active_players_by_year[year].add(player)
        if key in match_meta_by_key and not match_meta_by_key[key].raw_format:
            match_meta_by_key[key].raw_format = normalize(row["format"])
        match_sides_by_key[key].append(
            MatchSide(
                team=normalize(row["team"]),
                players=players,
                raw_format=normalize(row["format"]),
                result=normalize(row["win_or_loss"]),
                points=float(row["points"]),
                score=normalize(row["score"]),
            )
        )

    for row in courses_meta_rows:
        course_meta[(normalize(row["course"]), normalize(row["tees"]))] = (
            float(row["slope"]),
            float(row["rating"]),
            float(row["par"]),
        )

    for row in holes_rows:
        holes_meta[(normalize(row["course"]), normalize(row["tees"]))][int(row["holenumber"])] = {
            "par": int(row["par"]),
            "handicap": int(row["handicap"]),
        }

    for row in tournament_rows:
        year = int(row["year"])
        if year < MODEL_START_YEAR:
            continue
        max_handicap_by_year[year] = int(float(row["maxhandicap"]))

    for row in scores_rows:
        year = int(row["year"])
        if year < MODEL_START_YEAR:
            continue
        key = (year, int(row["round"]), normalize(row["player"]))
        score_map[key][int(row["hole"])] = int(row["actualscore"])

    picture_map = {
        slugify_player(f"{normalize(item['first'])} {normalize(item['last'])}"): normalize_avatar_url(item["url"])
        for item in player_pictures_rows
    }

    all_years |= set(active_players_by_year)
    years = sorted(year for year in all_years if year >= MODEL_START_YEAR)

    def handicap_for_year(player: str, year: int) -> tuple[float | None, bool]:
        data = player_handicaps.get(player, {})
        if year in data:
            return data[year], False
        if not data:
            return None, True
        known_years = sorted(data)
        prev_year = max((item for item in known_years if item < year), default=None)
        next_year = min((item for item in known_years if item > year), default=None)
        if prev_year is not None and next_year is not None:
            share = (year - prev_year) / (next_year - prev_year)
            return data[prev_year] + (data[next_year] - data[prev_year]) * share, True
        nearest = prev_year if prev_year is not None else next_year
        return data[nearest], True

    def normalize_format(raw_format: str) -> str:
        return FORMAT_MAP.get(raw_format, raw_format)

    def pair_actual_total(year: int, round_number: int, players: list[str], holes_played_list: list[int]) -> tuple[int, int]:
        total = 0
        count = 0
        for hole_number in holes_played_list:
            values = [
                score_map.get((year, round_number, player), {}).get(hole_number)
                for player in players
            ]
            values = [value for value in values if value is not None]
            if not values:
                continue
            total += round(sum(values) / len(values))
            count += 1
        return total, count

    score_entries: dict[str, list[dict[str, float]]] = defaultdict(list)
    win_entries: dict[str, list[dict[str, float]]] = defaultdict(list)

    for match_key, sides in match_sides_by_key.items():
        if len(sides) != 2 or match_key not in match_meta_by_key:
            continue

        year, round_number, _match = match_key
        meta = match_meta_by_key[match_key]
        format_name = normalize_format(meta.raw_format or sides[0].raw_format)
        hole_sequence = played_holes(getattr(meta, "starting_hole", 1), meta.match_length)
        hole_lookup = holes_meta.get((meta.course, meta.tees), {})
        course_lookup = course_meta.get((meta.course, meta.tees))
        if not hole_lookup or not course_lookup:
            continue
        if any(hole_number not in hole_lookup for hole_number in hole_sequence):
            continue

        slope, rating, par = course_lookup
        max_handicap = max_handicap_by_year.get(year, 30)

        for side in sides:
            players = [player for player in side.players if player in COHORT_PLAYERS]
            if not players:
                continue

            win_weight = SINGLES_WIN_WEIGHT if format_name == "Singles" else 1.0
            for player in players:
                win_entries[player].append(
                    {
                        "year": year,
                        "points": side.points,
                        "weight": win_weight,
                        "is_singles": 1.0 if format_name == "Singles" else 0.0,
                    }
                )

            if format_name in {"Singles", "Best Ball", "Shamble"}:
                for player in players:
                    handicap_index, _ = handicap_for_year(player, year)
                    if handicap_index is None:
                        continue
                    course_handicap_value = (
                        shamble_handicap(handicap_index, slope, rating, par, max_handicap)
                        if format_name == "Shamble"
                        else course_handicap(handicap_index, slope, rating, par, max_handicap)
                    )
                    actuals = score_map.get((year, round_number, player), {})
                    if any(hole_number not in actuals for hole_number in hole_sequence):
                        continue
                    actual_total = sum(actuals[hole_number] for hole_number in hole_sequence)
                    expected_total = sum(
                        hole_lookup[hole_number]["par"]
                        + strokes_received(course_handicap_value, hole_lookup[hole_number]["handicap"])
                        for hole_number in hole_sequence
                    )
                    performance = (expected_total - actual_total) * 18.0 / len(hole_sequence)
                    score_entries[player].append(
                        {
                            "year": year,
                            "performance": performance,
                        }
                    )
            elif format_name in {"Alternate Shot", "Two Man Scramble"}:
                pair_players = players[:2]
                if len(pair_players) < 2:
                    continue
                indexes: list[float] = []
                for player in pair_players:
                    handicap_index, _ = handicap_for_year(player, year)
                    if handicap_index is None:
                        indexes = []
                        break
                    indexes.append(handicap_index)
                if len(indexes) < 2:
                    continue

                pair_course_handicaps = sorted(
                    course_handicap(handicap_index, slope, rating, par, max_handicap)
                    for handicap_index in indexes
                )
                if format_name == "Alternate Shot":
                    team_handicap = round(pair_course_handicaps[0] * 0.50 + pair_course_handicaps[1] * 0.50)
                else:
                    team_handicap = round(pair_course_handicaps[0] * 0.35 + pair_course_handicaps[1] * 0.15)

                actual_total, counted_holes = pair_actual_total(year, round_number, pair_players, hole_sequence)
                if counted_holes != len(hole_sequence):
                    continue
                expected_total = sum(
                    hole_lookup[hole_number]["par"]
                    + strokes_received(team_handicap, hole_lookup[hole_number]["handicap"])
                    for hole_number in hole_sequence
                )
                performance = (expected_total - actual_total) * 18.0 / len(hole_sequence)
                for player in pair_players:
                    score_entries[player].append(
                        {
                            "year": year,
                            "performance": performance,
                        }
                    )

    latest_team_map = {player: player_teams.get(player, {}).get(COHORT_YEAR, "") for player in COHORT_PLAYERS}

    season_rows: list[dict[str, object]] = []
    for year in years:
        active = sorted(active_players_by_year[year] & COHORT_PLAYERS)
        yearly_rows: list[dict[str, object]] = []

        for player in active:
            prior_scores = [entry for entry in score_entries[player] if int(entry["year"]) < year]
            prior_wins = [entry for entry in win_entries[player] if int(entry["year"]) < year]

            rounds_played = len(prior_scores)
            matches_played = len(prior_wins)
            weighted_match_units = sum(float(entry["weight"]) for entry in prior_wins)
            singles_rows = [entry for entry in prior_wins if float(entry["is_singles"]) > 0]

            raw_score_performance = (
                sum(float(entry["performance"]) for entry in prior_scores) / rounds_played
                if rounds_played
                else 0.0
            )
            adjusted_score_performance = raw_score_performance * (
                rounds_played / (rounds_played + SCORE_SHRINK_ROUNDS)
            ) if rounds_played else 0.0

            raw_weighted_win_pct = (
                sum(float(entry["points"]) * float(entry["weight"]) for entry in prior_wins) / weighted_match_units
                if weighted_match_units
                else 0.5
            )
            adjusted_weighted_win_pct = (
                0.5 + (raw_weighted_win_pct - 0.5) * (weighted_match_units / (weighted_match_units + WIN_SHRINK_WEIGHT))
                if weighted_match_units
                else 0.5
            )

            overall_win_pct = (
                sum(float(entry["points"]) for entry in prior_wins) / matches_played
                if matches_played
                else 0.5
            )
            singles_win_pct = (
                sum(float(entry["points"]) for entry in singles_rows) / len(singles_rows)
                if singles_rows
                else 0.5
            )

            score_index = 1.0 / (1.0 + math.exp(-(adjusted_score_performance / SCORE_LOGISTIC_SCALE)))
            power_score = 100.0 * ((0.75 * score_index) + (0.25 * adjusted_weighted_win_pct))

            current_handicap, handicap_imputed = handicap_for_year(player, year)
            yearly_rows.append(
                {
                    "year": year,
                    "player": player,
                    "team_2025": latest_team_map.get(player, ""),
                    "season_team": player_teams.get(player, {}).get(year, latest_team_map.get(player, "")),
                    "avatar_url": picture_map.get(slugify_player(player), ""),
                    "power_score": round(power_score, 4),
                    "score_performance_raw": round(raw_score_performance, 4),
                    "score_performance_adj": round(adjusted_score_performance, 4),
                    "score_index": round(score_index, 4),
                    "win_pct_weighted": round(adjusted_weighted_win_pct, 4),
                    "win_pct_overall": round(overall_win_pct, 4),
                    "win_pct_singles": round(singles_win_pct, 4),
                    "rounds_played": rounds_played,
                    "matches_played": matches_played,
                    "singles_matches": len(singles_rows),
                    "weighted_match_units": round(weighted_match_units, 2),
                    "handicap_index": round(current_handicap, 2) if current_handicap is not None else None,
                    "handicap_imputed": bool(handicap_imputed),
                }
            )

        yearly_rows.sort(
            key=lambda row: (
                -float(row["power_score"]),
                -float(row["score_performance_adj"]),
                -float(row["win_pct_singles"]),
                str(row["player"]),
            )
        )
        previous_ranks = {row["player"]: int(row["rank"]) for row in season_rows if int(row["year"]) == year - 1}
        for index, row in enumerate(yearly_rows, start=1):
            row["rank"] = index
            previous_rank = previous_ranks.get(str(row["player"]))
            row["trend"] = None if previous_rank is None else previous_rank - index
        season_rows.extend(yearly_rows)

    rows_2025 = [row for row in season_rows if int(row["year"]) == COHORT_YEAR]
    team_order = {"Red": [], "Blue": []}
    for row in sorted(rows_2025, key=lambda item: int(item["rank"])):
        team = str(row["team_2025"] or "")
        if team in team_order:
            team_order[team].append(str(row["player"]))

    color_map: dict[str, str] = {}
    for team, palette in (("Red", RED_PALETTE), ("Blue", BLUE_PALETTE)):
        for index, player in enumerate(team_order[team]):
            color_map[player] = palette[index % len(palette)]

    for row in season_rows:
        row["line_color"] = color_map.get(str(row["player"]), "#5f6e8d")

    player_summary = []
    for player in sorted(COHORT_PLAYERS):
        active_years = sorted(int(row["year"]) for row in season_rows if row["player"] == player)
        player_summary.append(
            {
                "player": player,
                "team_2025": latest_team_map.get(player, ""),
                "avatar_url": picture_map.get(slugify_player(player), ""),
                "first_year": active_years[0],
                "latest_year": active_years[-1],
                "years_active": active_years,
            }
        )

    series = []
    for player in [row["player"] for row in sorted(rows_2025, key=lambda item: int(item["rank"]))]:
        summary = next(item for item in player_summary if item["player"] == player)
        points = []
        for year in years:
            match = next((row for row in season_rows if int(row["year"]) == year and row["player"] == player), None)
            if match:
                points.append(
                    {
                        "x": year,
                        "y": int(match["rank"]),
                        "powerScore": float(match["power_score"]),
                        "scorePerformance": float(match["score_performance_adj"]),
                        "winPctWeighted": float(match["win_pct_weighted"]),
                        "winPctSingles": float(match["win_pct_singles"]),
                    }
                )
            else:
                points.append({"x": year, "y": None})

        current_row = next(row for row in rows_2025 if row["player"] == player)
        series.append(
            {
                "player": player,
                "team": summary["team_2025"],
                "avatarUrl": summary["avatar_url"],
                "firstYear": summary["first_year"],
                "latestYear": summary["latest_year"],
                "lineColor": color_map.get(player, "#5f6e8d"),
                "latestRank": int(current_row["rank"]),
                "latestScore": float(current_row["power_score"]),
                "trend": current_row["trend"],
                "points": points,
            }
        )

    return {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "cohortYear": COHORT_YEAR,
        "cohortSize": len(COHORT_PLAYERS),
        "years": years,
        "players": player_summary,
        "rankings": season_rows,
        "series": series,
        "leaderboard2025": rows_2025,
        "model": {
            "name": "BCC Score-First Model",
            "summary": "Power score is 75% handicap-adjusted score performance and 25% win rate, with singles matches counted extra inside the win bucket.",
            "components": [
                "75% score performance versus handicap expectation",
                "25% weighted win percentage",
                "Singles matches count double inside win percentage",
                "Best Ball and Shamble use individual score performance",
                "Alternate Shot and Scramble use pairing score performance",
                "Small samples shrink toward neutral",
            ],
        },
    }


def build_payload_v3(source: dict[str, object]) -> dict[str, object]:
    rows = source.get("rows", [])
    player_handicaps_rows = source.get("playerHandicaps", [])
    match_courses_rows = source.get("matchCourses", [])
    scores_rows = source.get("scores", [])
    holes_rows = source.get("holes", [])
    courses_meta_rows = source.get("coursesMeta", [])
    tournament_rows = source.get("tournamentSettings", [])
    player_pictures_rows = source.get("playerPictures", [])

    player_handicaps: dict[str, dict[int, float]] = defaultdict(dict)
    player_teams: dict[str, dict[int, str]] = defaultdict(dict)
    match_meta_by_key: dict[tuple[int, int, int], MatchMeta] = {}
    match_sides_by_key: dict[tuple[int, int, int], list[MatchSide]] = defaultdict(list)
    course_meta: dict[tuple[str, str], tuple[float, float, float]] = {}
    holes_meta: dict[tuple[str, str], dict[int, dict[str, int]]] = defaultdict(dict)
    max_handicap_by_year: dict[int, int] = {}
    active_players_by_year: dict[int, set[str]] = defaultdict(set)
    score_map: dict[tuple[int, int, str], dict[int, int]] = defaultdict(dict)
    all_years: set[int] = set()

    for row in player_handicaps_rows:
        year = int(row["year"])
        name = normalize(row["name"])
        if not name:
            continue
        player_handicaps[name][year] = float(row["handicap"])
        player_teams[name][year] = normalize(row["team"])

    for row in match_courses_rows:
        key = (int(row["year"]), int(row["round"]), int(row["match"]))
        all_years.add(key[0])
        match_meta_by_key.setdefault(
            key,
            MatchMeta(
                course=normalize(row["course"]),
                tees=normalize(row["tees"]),
                raw_format="",
                match_length=int(normalize(row["matchlength"]) or "18"),
                starting_hole=int(normalize(row["startinghole"]) or "1"),
            ),
        )

    for row in rows:
        year = int(row["year"])
        key = (year, int(row["round"]), int(row["match"]))
        players = [normalize(row[field]) for field in ("player1", "player2", "player3", "player4") if normalize(row[field])]
        for player in players:
            if player in COHORT_PLAYERS:
                active_players_by_year[year].add(player)
        if key in match_meta_by_key and not match_meta_by_key[key].raw_format:
            match_meta_by_key[key].raw_format = normalize(row["format"])
        match_sides_by_key[key].append(
            MatchSide(
                team=normalize(row["team"]),
                players=players,
                raw_format=normalize(row["format"]),
                result=normalize(row["win_or_loss"]),
                points=float(row["points"]),
                score=normalize(row["score"]),
            )
        )

    for row in courses_meta_rows:
        course_meta[(normalize(row["course"]), normalize(row["tees"]))] = (
            float(row["slope"]),
            float(row["rating"]),
            float(row["par"]),
        )

    for row in holes_rows:
        holes_meta[(normalize(row["course"]), normalize(row["tees"]))][int(row["holenumber"])] = {
            "par": int(row["par"]),
            "handicap": int(row["handicap"]),
        }

    for row in tournament_rows:
        year = int(row["year"])
        if year < MODEL_START_YEAR:
            continue
        max_handicap_by_year[year] = int(float(row["maxhandicap"]))

    for row in scores_rows:
        year = int(row["year"])
        if year < MODEL_START_YEAR:
            continue
        key = (year, int(row["round"]), normalize(row["player"]))
        score_map[key][int(row["hole"])] = int(row["actualscore"])

    picture_map = {
        slugify_player(f"{normalize(item['first'])} {normalize(item['last'])}"): normalize_avatar_url(item["url"])
        for item in player_pictures_rows
    }

    all_years |= set(active_players_by_year)
    years = sorted(year for year in all_years if year >= MODEL_START_YEAR)

    def handicap_for_year(player: str, year: int) -> tuple[float | None, bool]:
        data = player_handicaps.get(player, {})
        if year in data:
            return data[year], False
        if not data:
            return None, True
        known_years = sorted(data)
        prev_year = max((item for item in known_years if item < year), default=None)
        next_year = min((item for item in known_years if item > year), default=None)
        if prev_year is not None and next_year is not None:
            share = (year - prev_year) / (next_year - prev_year)
            return data[prev_year] + (data[next_year] - data[prev_year]) * share, True
        nearest = prev_year if prev_year is not None else next_year
        return data[nearest], True

    def normalize_format(raw_format: str) -> str:
        return FORMAT_MAP.get(raw_format, raw_format)

    def pair_actual_total(year: int, round_number: int, players: list[str], holes_played_list: list[int]) -> tuple[int, int]:
        total = 0
        count = 0
        for hole_number in holes_played_list:
            values = [
                score_map.get((year, round_number, player), {}).get(hole_number)
                for player in players
            ]
            values = [value for value in values if value is not None]
            if not values:
                continue
            total += round(sum(values) / len(values))
            count += 1
        return total, count

    score_entries_by_player_year: dict[str, dict[int, list[dict[str, float]]]] = defaultdict(lambda: defaultdict(list))
    win_entries_by_player_year: dict[str, dict[int, list[dict[str, float]]]] = defaultdict(lambda: defaultdict(list))

    for match_key, sides in match_sides_by_key.items():
        if len(sides) != 2 or match_key not in match_meta_by_key:
            continue

        year, round_number, _match = match_key
        meta = match_meta_by_key[match_key]
        format_name = normalize_format(meta.raw_format or sides[0].raw_format)
        hole_sequence = played_holes(getattr(meta, "starting_hole", 1), meta.match_length)
        hole_lookup = holes_meta.get((meta.course, meta.tees), {})
        course_lookup = course_meta.get((meta.course, meta.tees))
        if not hole_lookup or not course_lookup:
            continue
        if any(hole_number not in hole_lookup for hole_number in hole_sequence):
            continue

        slope, rating, par = course_lookup
        max_handicap = max_handicap_by_year.get(year, 30)

        for side in sides:
            players = [player for player in side.players if player in COHORT_PLAYERS]
            if not players:
                continue

            win_weight = SINGLES_WIN_WEIGHT if format_name == "Singles" else 1.0
            for player in players:
                win_entries_by_player_year[player][year].append(
                    {
                        "year": year,
                        "points": side.points,
                        "weight": win_weight,
                        "is_singles": 1.0 if format_name == "Singles" else 0.0,
                    }
                )

            if format_name in {"Singles", "Best Ball", "Shamble"}:
                for player in players:
                    handicap_index, _ = handicap_for_year(player, year)
                    if handicap_index is None:
                        continue
                    course_handicap_value = (
                        shamble_handicap(handicap_index, slope, rating, par, max_handicap)
                        if format_name == "Shamble"
                        else course_handicap(handicap_index, slope, rating, par, max_handicap)
                    )
                    actuals = score_map.get((year, round_number, player), {})
                    if any(hole_number not in actuals for hole_number in hole_sequence):
                        continue
                    actual_total = sum(actuals[hole_number] for hole_number in hole_sequence)
                    expected_total = sum(
                        hole_lookup[hole_number]["par"]
                        + strokes_received(course_handicap_value, hole_lookup[hole_number]["handicap"])
                        for hole_number in hole_sequence
                    )
                    performance = (expected_total - actual_total) * 18.0 / len(hole_sequence)
                    score_entries_by_player_year[player][year].append(
                        {
                            "performance": performance,
                            "weight": SCORE_FORMAT_WEIGHT.get(format_name, 1.0),
                        }
                    )
            elif format_name in {"Alternate Shot", "Two Man Scramble"}:
                pair_players = players[:2]
                if len(pair_players) < 2:
                    continue
                indexes: list[float] = []
                for player in pair_players:
                    handicap_index, _ = handicap_for_year(player, year)
                    if handicap_index is None:
                        indexes = []
                        break
                    indexes.append(handicap_index)
                if len(indexes) < 2:
                    continue

                pair_course_handicaps = sorted(
                    course_handicap(handicap_index, slope, rating, par, max_handicap)
                    for handicap_index in indexes
                )
                if format_name == "Alternate Shot":
                    team_handicap = round(pair_course_handicaps[0] * 0.50 + pair_course_handicaps[1] * 0.50)
                else:
                    team_handicap = round(pair_course_handicaps[0] * 0.35 + pair_course_handicaps[1] * 0.15)

                actual_total, counted_holes = pair_actual_total(year, round_number, pair_players, hole_sequence)
                if counted_holes != len(hole_sequence):
                    continue
                expected_total = sum(
                    hole_lookup[hole_number]["par"]
                    + strokes_received(team_handicap, hole_lookup[hole_number]["handicap"])
                    for hole_number in hole_sequence
                )
                performance = (expected_total - actual_total) * 18.0 / len(hole_sequence)
                for player in pair_players:
                    score_entries_by_player_year[player][year].append(
                        {
                            "performance": performance,
                            "weight": SCORE_FORMAT_WEIGHT.get(format_name, 1.0),
                        }
                    )

    def summarize_scores(player: str, included_years: list[int], anchor_year: int | None = None) -> dict[str, float | int]:
        yearly_averages: list[tuple[float, float]] = []
        rounds = 0
        for included_year in included_years:
            values = score_entries_by_player_year[player].get(included_year, [])
            if not values:
                continue
            weight = recency_window_weight(included_year, anchor_year) if anchor_year is not None else 1.0
            if weight <= 0:
                continue
            yearly_weight_total = sum(float(item["weight"]) for item in values)
            yearly_average = (
                sum(float(item["performance"]) * float(item["weight"]) for item in values) / yearly_weight_total
                if yearly_weight_total
                else 0.0
            )
            yearly_averages.append((yearly_average, weight))
            rounds += len(values)

        weighted_total = sum(value * weight for value, weight in yearly_averages)
        total_weight = sum(weight for _value, weight in yearly_averages)
        raw_score = (weighted_total / total_weight) if total_weight else 0.0
        adjusted_score = raw_score * (rounds / (rounds + SCORE_SHRINK_ROUNDS)) if rounds else 0.0
        score_index = 1.0 / (1.0 + math.exp(-(adjusted_score / SCORE_LOGISTIC_SCALE)))

        return {
            "raw": raw_score,
            "adjusted": adjusted_score,
            "index": score_index,
            "rounds": rounds,
            "years_scored": len(yearly_averages),
        }

    def summarize_wins(entries: list[dict[str, float]], anchor_year: int | None = None) -> dict[str, float | int]:
        eligible_entries = [
            {
                **entry,
                "season_weight": recency_window_weight(int(entry["year"]), anchor_year) if anchor_year is not None else 1.0,
            }
            for entry in entries
        ]
        eligible_entries = [entry for entry in eligible_entries if float(entry["season_weight"]) > 0]
        matches_played = len(eligible_entries)
        weighted_match_units = sum(
            float(entry["weight"]) * float(entry["season_weight"])
            for entry in eligible_entries
        )
        singles_rows = [entry for entry in eligible_entries if float(entry["is_singles"]) > 0]
        singles_weight_units = sum(float(entry["season_weight"]) for entry in singles_rows)

        raw_weighted_win_pct = (
            sum(
                float(entry["points"]) * float(entry["weight"]) * float(entry["season_weight"])
                for entry in eligible_entries
            ) / weighted_match_units
            if weighted_match_units
            else 0.5
        )
        adjusted_weighted_win_pct = (
            0.5 + (raw_weighted_win_pct - 0.5) * (weighted_match_units / (weighted_match_units + WIN_SHRINK_WEIGHT))
            if weighted_match_units
            else 0.5
        )
        overall_win_pct = (
            sum(float(entry["points"]) for entry in eligible_entries) / matches_played
            if matches_played
            else 0.5
        )
        singles_win_pct = (
            sum(float(entry["points"]) * float(entry["season_weight"]) for entry in singles_rows) / singles_weight_units
            if singles_weight_units
            else 0.5
        )

        return {
            "weighted": adjusted_weighted_win_pct,
            "overall": overall_win_pct,
            "singles": singles_win_pct,
            "matches": matches_played,
            "singles_matches": len(singles_rows),
            "weighted_units": weighted_match_units,
        }

    latest_team_map = {player: player_teams.get(player, {}).get(COHORT_YEAR, "") for player in COHORT_PLAYERS}
    raw_rows_by_year: dict[int, list[dict[str, object]]] = defaultdict(list)

    for year in years:
        active = sorted(active_players_by_year[year] & COHORT_PLAYERS)
        cumulative_years = rolling_cumulative_years(years, year)
        for player in active:
            yearly_score_summary = summarize_scores(player, [year])
            cumulative_score_summary = summarize_scores(player, cumulative_years, year)

            yearly_win_entries = list(win_entries_by_player_year[player].get(year, []))
            cumulative_win_entries = [
                entry
                for included_year in cumulative_years
                for entry in win_entries_by_player_year[player].get(included_year, [])
            ]
            yearly_win_summary = summarize_wins(yearly_win_entries)
            cumulative_win_summary = summarize_wins(cumulative_win_entries, year)

            yearly_power_score = 100.0 * (
                (0.75 * float(yearly_score_summary["index"]))
                + (0.25 * float(yearly_win_summary["weighted"]))
            )
            cumulative_power_score = 100.0 * (
                (0.75 * float(cumulative_score_summary["index"]))
                + (0.25 * float(cumulative_win_summary["weighted"]))
            )
            yearly_net_handicap_score = 100.0 * float(yearly_score_summary["index"])
            cumulative_net_handicap_score = 100.0 * float(cumulative_score_summary["index"])

            current_handicap, handicap_imputed = handicap_for_year(player, year)
            raw_rows_by_year[year].append(
                {
                    "year": year,
                    "player": player,
                    "team_2025": latest_team_map.get(player, ""),
                    "season_team": player_teams.get(player, {}).get(year, latest_team_map.get(player, "")),
                    "avatar_url": picture_map.get(slugify_player(player), ""),
                    "yearly_power_score": round(yearly_power_score, 4),
                    "yearly_score_performance_raw": round(float(yearly_score_summary["raw"]), 4),
                    "yearly_score_performance_adj": round(float(yearly_score_summary["adjusted"]), 4),
                    "yearly_score_index": round(float(yearly_score_summary["index"]), 4),
                    "yearly_win_pct_weighted": round(float(yearly_win_summary["weighted"]), 4),
                    "yearly_win_pct_overall": round(float(yearly_win_summary["overall"]), 4),
                    "yearly_win_pct_singles": round(float(yearly_win_summary["singles"]), 4),
                    "yearly_rounds_played": int(yearly_score_summary["rounds"]),
                    "yearly_matches_played": int(yearly_win_summary["matches"]),
                    "yearly_singles_matches": int(yearly_win_summary["singles_matches"]),
                    "yearly_weighted_match_units": round(float(yearly_win_summary["weighted_units"]), 2),
                    "yearly_net_handicap_score": round(yearly_net_handicap_score, 4),
                    "cumulative_power_score": round(cumulative_power_score, 4),
                    "cumulative_score_performance_raw": round(float(cumulative_score_summary["raw"]), 4),
                    "cumulative_score_performance_adj": round(float(cumulative_score_summary["adjusted"]), 4),
                    "cumulative_score_index": round(float(cumulative_score_summary["index"]), 4),
                    "cumulative_win_pct_weighted": round(float(cumulative_win_summary["weighted"]), 4),
                    "cumulative_win_pct_overall": round(float(cumulative_win_summary["overall"]), 4),
                    "cumulative_win_pct_singles": round(float(cumulative_win_summary["singles"]), 4),
                    "cumulative_rounds_played": int(cumulative_score_summary["rounds"]),
                    "cumulative_matches_played": int(cumulative_win_summary["matches"]),
                    "cumulative_singles_matches": int(cumulative_win_summary["singles_matches"]),
                    "cumulative_weighted_match_units": round(float(cumulative_win_summary["weighted_units"]), 2),
                    "cumulative_years_scored": int(cumulative_score_summary["years_scored"]),
                    "cumulative_net_handicap_score": round(cumulative_net_handicap_score, 4),
                    "handicap_index": round(current_handicap, 2) if current_handicap is not None else None,
                    "handicap_imputed": bool(handicap_imputed),
                }
            )

    season_rows: list[dict[str, object]] = []
    previous_yearly_ranks: dict[str, int] = {}
    previous_cumulative_ranks: dict[str, int] = {}
    previous_yearly_net_ranks: dict[str, int] = {}
    previous_cumulative_net_ranks: dict[str, int] = {}
    for year in years:
        year_rows = raw_rows_by_year[year]

        yearly_order = sorted(
            year_rows,
            key=lambda row: (
                -float(row["yearly_power_score"]),
                -float(row["yearly_score_performance_adj"]),
                -float(row["yearly_win_pct_singles"]),
                str(row["player"]),
            ),
        )
        for index, row in enumerate(yearly_order, start=1):
            row["yearly_rank"] = index
            previous_rank = previous_yearly_ranks.get(str(row["player"]))
            row["yearly_trend"] = None if previous_rank is None else previous_rank - index
        previous_yearly_ranks = {str(row["player"]): int(row["yearly_rank"]) for row in year_rows}

        cumulative_order = sorted(
            year_rows,
            key=lambda row: (
                -float(row["cumulative_power_score"]),
                -float(row["cumulative_score_performance_adj"]),
                -float(row["cumulative_win_pct_singles"]),
                str(row["player"]),
            ),
        )
        for index, row in enumerate(cumulative_order, start=1):
            row["cumulative_rank"] = index
            previous_rank = previous_cumulative_ranks.get(str(row["player"]))
            row["cumulative_trend"] = None if previous_rank is None else previous_rank - index
        previous_cumulative_ranks = {str(row["player"]): int(row["cumulative_rank"]) for row in year_rows}

        yearly_net_order = sorted(
            year_rows,
            key=lambda row: (
                -float(row["yearly_net_handicap_score"]),
                -float(row["yearly_score_performance_adj"]),
                str(row["player"]),
            ),
        )
        for index, row in enumerate(yearly_net_order, start=1):
            row["yearly_net_handicap_rank"] = index
            previous_rank = previous_yearly_net_ranks.get(str(row["player"]))
            row["yearly_net_handicap_trend"] = None if previous_rank is None else previous_rank - index
        previous_yearly_net_ranks = {str(row["player"]): int(row["yearly_net_handicap_rank"]) for row in year_rows}

        cumulative_net_order = sorted(
            year_rows,
            key=lambda row: (
                -float(row["cumulative_net_handicap_score"]),
                -float(row["cumulative_score_performance_adj"]),
                str(row["player"]),
            ),
        )
        for index, row in enumerate(cumulative_net_order, start=1):
            row["cumulative_net_handicap_rank"] = index
            previous_rank = previous_cumulative_net_ranks.get(str(row["player"]))
            row["cumulative_net_handicap_trend"] = None if previous_rank is None else previous_rank - index
        previous_cumulative_net_ranks = {str(row["player"]): int(row["cumulative_net_handicap_rank"]) for row in year_rows}

        season_rows.extend(sorted(year_rows, key=lambda row: int(row["yearly_rank"])))

    rows_2025 = [row for row in season_rows if int(row["year"]) == COHORT_YEAR]
    team_order = {"Red": [], "Blue": []}
    for row in sorted(rows_2025, key=lambda item: int(item["yearly_rank"])):
        team = str(row["team_2025"] or "")
        if team in team_order:
            team_order[team].append(str(row["player"]))

    color_map: dict[str, str] = {}
    for team, palette in (("Red", RED_PALETTE), ("Blue", BLUE_PALETTE)):
        for index, player in enumerate(team_order[team]):
            color_map[player] = palette[index % len(palette)]

    for row in season_rows:
        row["line_color"] = color_map.get(str(row["player"]), "#5f6e8d")

    player_summary = []
    for player in sorted(COHORT_PLAYERS):
        active_years = sorted(int(row["year"]) for row in season_rows if row["player"] == player)
        if not active_years:
            continue
        player_summary.append(
            {
                "player": player,
                "team_2025": latest_team_map.get(player, ""),
                "avatar_url": picture_map.get(slugify_player(player), ""),
                "first_year": active_years[0],
                "latest_year": active_years[-1],
                "years_active": active_years,
            }
        )

    series = []
    player_rows_by_year = {
        (int(row["year"]), str(row["player"])): row
        for row in season_rows
    }
    players_2025_order = [row["player"] for row in sorted(rows_2025, key=lambda item: int(item["yearly_rank"]))]
    for player in players_2025_order:
        summary = next(item for item in player_summary if item["player"] == player)
        points = []
        for year in years:
            match = player_rows_by_year.get((year, player))
            if match:
                points.append(
                    {
                        "x": year,
                        "yearlyRank": int(match["yearly_rank"]),
                        "cumulativeRank": int(match["cumulative_rank"]),
                        "yearlyScore": float(match["yearly_power_score"]),
                        "cumulativeScore": float(match["cumulative_power_score"]),
                        "yearlyNetHandicapScore": float(match["yearly_net_handicap_score"]),
                        "cumulativeNetHandicapScore": float(match["cumulative_net_handicap_score"]),
                        "yearlyScorePerformance": float(match["yearly_score_performance_adj"]),
                        "cumulativeScorePerformance": float(match["cumulative_score_performance_adj"]),
                        "yearlyNetHandicapRank": int(match["yearly_net_handicap_rank"]),
                        "cumulativeNetHandicapRank": int(match["cumulative_net_handicap_rank"]),
                        "yearlyWeightedWinPct": float(match["yearly_win_pct_weighted"]),
                        "cumulativeWeightedWinPct": float(match["cumulative_win_pct_weighted"]),
                        "yearlyOverallWinPct": float(match["yearly_win_pct_overall"]),
                        "cumulativeOverallWinPct": float(match["cumulative_win_pct_overall"]),
                        "yearlySinglesWinPct": float(match["yearly_win_pct_singles"]),
                        "cumulativeSinglesWinPct": float(match["cumulative_win_pct_singles"]),
                    }
                )
            else:
                points.append({"x": year, "yearlyScore": None, "cumulativeScore": None})

        current_row = next(row for row in rows_2025 if row["player"] == player)
        series.append(
            {
                "player": player,
                "team": summary["team_2025"],
                "avatarUrl": summary["avatar_url"],
                "firstYear": summary["first_year"],
                "latestYear": summary["latest_year"],
                "lineColor": color_map.get(player, "#5f6e8d"),
                "latestYearlyRank": int(current_row["yearly_rank"]),
                "latestYearlyScore": float(current_row["yearly_power_score"]),
                "latestCumulativeRank": int(current_row["cumulative_rank"]),
                "latestCumulativeScore": float(current_row["cumulative_power_score"]),
                "latestYearlyNetHandicapRank": int(current_row["yearly_net_handicap_rank"]),
                "latestYearlyNetHandicapScore": float(current_row["yearly_net_handicap_score"]),
                "latestCumulativeNetHandicapRank": int(current_row["cumulative_net_handicap_rank"]),
                "latestCumulativeNetHandicapScore": float(current_row["cumulative_net_handicap_score"]),
                "yearlyTrend": current_row["yearly_trend"],
                "cumulativeTrend": current_row["cumulative_trend"],
                "yearlyNetHandicapTrend": current_row["yearly_net_handicap_trend"],
                "cumulativeNetHandicapTrend": current_row["cumulative_net_handicap_trend"],
                "points": points,
            }
        )

    return {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "cohortYear": COHORT_YEAR,
        "cohortSize": len(COHORT_PLAYERS),
        "years": years,
        "players": player_summary,
        "rankings": season_rows,
        "series": series,
        "leaderboard2025": rows_2025,
        "model": {
            "name": "BCC Score-First Model",
            "summary": "Year-by-Year view uses only that season. Cumulative view uses a rolling five-season window through that season and progressively weights the newest seasons most heavily. Power Ratings are 75% score-vs-handicap and 25% win rate. Net of Handicap uses only the score-vs-handicap side.",
            "components": [
                "75% score performance versus handicap expectation",
                "25% weighted win percentage",
                "Net of Handicap is the score-versus-expectation side on its own",
                "Cumulative score performance averages yearly score-over-expected marks instead of pooling every round together",
                "Cumulative mode only considers the last five seasons and weights the newest seasons most heavily",
                "Main-site win percentage is also stored separately through cumulative_win_pct_overall",
                "Singles matches count double inside the weighted win bucket",
                "Singles, Best Ball, and Shamble count more in score performance because they use individual scores",
                "Alternate Shot and Two Man Scramble count less in score performance because they use shared team scores",
                "Small samples shrink toward neutral",
            ],
        },
    }


def write_rankings_to_postgres(payload: dict[str, object]) -> None:
    psql_admin(
        """
        CREATE TABLE IF NOT EXISTS bcc_power_rankings (
            ranking_year INTEGER NOT NULL,
            player_name TEXT NOT NULL,
            team_2025 TEXT NOT NULL,
            season_team TEXT NOT NULL,
            rank INTEGER NOT NULL,
            power_score NUMERIC(10,4) NOT NULL,
            preseason_rating NUMERIC(10,4) NOT NULL,
            seed_rating NUMERIC(10,4) NOT NULL,
            handicap_index NUMERIC(6,2),
            handicap_imputed BOOLEAN NOT NULL DEFAULT FALSE,
            prior_matches INTEGER NOT NULL,
            confidence NUMERIC(6,4) NOT NULL,
            points_rate NUMERIC(6,4) NOT NULL,
            over_expected NUMERIC(7,4) NOT NULL,
            margin_index NUMERIC(7,4) NOT NULL,
            best_prior_rating NUMERIC(10,4) NOT NULL,
            trend INTEGER,
            line_color TEXT NOT NULL,
            avatar_url TEXT NOT NULL,
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            PRIMARY KEY (ranking_year, player_name)
        );

        ALTER TABLE bcc_power_rankings OWNER TO bcc_admin;
        GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON bcc_power_rankings TO bcc_admin;
        """
    )
    psql("TRUNCATE TABLE bcc_power_rankings;")

    values_sql = ",\n".join(
        "("
        + ", ".join(
            [
                psql_literal(row["year"]),
                psql_literal(row["player"]),
                psql_literal(row["team_2025"]),
                psql_literal(row["season_team"]),
                psql_literal(row["rank"]),
                psql_literal(row["power_score"]),
                psql_literal(row["preseason_rating"]),
                psql_literal(row["seed_rating"]),
                psql_literal(row["handicap_index"]),
                psql_literal(row["handicap_imputed"]),
                psql_literal(row["prior_matches"]),
                psql_literal(row["confidence"]),
                psql_literal(row["points_rate"]),
                psql_literal(row["over_expected"]),
                psql_literal(row["margin_index"]),
                psql_literal(row["best_prior_rating"]),
                psql_literal(row["trend"]),
                psql_literal(row["line_color"]),
                psql_literal(row["avatar_url"]),
            ]
        )
        + ")"
        for row in payload["rankings"]
    )

    insert_sql = f"""
        INSERT INTO bcc_power_rankings (
            ranking_year, player_name, team_2025, season_team, rank, power_score, preseason_rating,
            seed_rating, handicap_index, handicap_imputed, prior_matches, confidence, points_rate,
            over_expected, margin_index, best_prior_rating, trend, line_color, avatar_url
        )
        VALUES
        {values_sql};
    """
    psql(insert_sql)


def write_rankings_to_postgres_v2(payload: dict[str, object]) -> None:
    psql_admin(
        """
        DROP TABLE IF EXISTS bcc_power_rankings;

        CREATE TABLE bcc_power_rankings (
            ranking_year INTEGER NOT NULL,
            player_name TEXT NOT NULL,
            team_2025 TEXT NOT NULL,
            season_team TEXT NOT NULL,
            rank INTEGER NOT NULL,
            power_score NUMERIC(8,4) NOT NULL,
            score_performance_raw NUMERIC(8,4) NOT NULL,
            score_performance_adj NUMERIC(8,4) NOT NULL,
            score_index NUMERIC(8,4) NOT NULL,
            win_pct_weighted NUMERIC(8,4) NOT NULL,
            win_pct_overall NUMERIC(8,4) NOT NULL,
            win_pct_singles NUMERIC(8,4) NOT NULL,
            rounds_played INTEGER NOT NULL,
            matches_played INTEGER NOT NULL,
            singles_matches INTEGER NOT NULL,
            weighted_match_units NUMERIC(8,2) NOT NULL,
            handicap_index NUMERIC(6,2),
            handicap_imputed BOOLEAN NOT NULL DEFAULT FALSE,
            trend INTEGER,
            line_color TEXT NOT NULL,
            avatar_url TEXT NOT NULL,
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            PRIMARY KEY (ranking_year, player_name)
        );

        ALTER TABLE bcc_power_rankings OWNER TO bcc_admin;
        GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON bcc_power_rankings TO bcc_admin;
        """
    )

    values_sql = ",\n".join(
        "("
        + ", ".join(
            [
                psql_literal(row["year"]),
                psql_literal(row["player"]),
                psql_literal(row["team_2025"]),
                psql_literal(row["season_team"]),
                psql_literal(row["rank"]),
                psql_literal(row["power_score"]),
                psql_literal(row["score_performance_raw"]),
                psql_literal(row["score_performance_adj"]),
                psql_literal(row["score_index"]),
                psql_literal(row["win_pct_weighted"]),
                psql_literal(row["win_pct_overall"]),
                psql_literal(row["win_pct_singles"]),
                psql_literal(row["rounds_played"]),
                psql_literal(row["matches_played"]),
                psql_literal(row["singles_matches"]),
                psql_literal(row["weighted_match_units"]),
                psql_literal(row["handicap_index"]),
                psql_literal(row["handicap_imputed"]),
                psql_literal(row["trend"]),
                psql_literal(row["line_color"]),
                psql_literal(row["avatar_url"]),
            ]
        )
        + ")"
        for row in payload["rankings"]
    )

    insert_sql = f"""
        INSERT INTO bcc_power_rankings (
            ranking_year, player_name, team_2025, season_team, rank, power_score,
            score_performance_raw, score_performance_adj, score_index,
            win_pct_weighted, win_pct_overall, win_pct_singles,
            rounds_played, matches_played, singles_matches, weighted_match_units,
            handicap_index, handicap_imputed, trend, line_color, avatar_url
        )
        VALUES
        {values_sql};
    """
    psql(insert_sql)


def write_rankings_to_postgres_v3(payload: dict[str, object]) -> None:
    psql_admin(
        """
        DROP TABLE IF EXISTS bcc_power_rankings;

        CREATE TABLE bcc_power_rankings (
            ranking_year INTEGER NOT NULL,
            player_name TEXT NOT NULL,
            team_2025 TEXT NOT NULL,
            season_team TEXT NOT NULL,
            yearly_rank INTEGER NOT NULL,
            yearly_power_score NUMERIC(8,4) NOT NULL,
            yearly_net_handicap_rank INTEGER NOT NULL,
            yearly_net_handicap_score NUMERIC(8,4) NOT NULL,
            yearly_score_performance_raw NUMERIC(8,4) NOT NULL,
            yearly_score_performance_adj NUMERIC(8,4) NOT NULL,
            yearly_score_index NUMERIC(8,4) NOT NULL,
            yearly_win_pct_weighted NUMERIC(8,4) NOT NULL,
            yearly_win_pct_overall NUMERIC(8,4) NOT NULL,
            yearly_win_pct_singles NUMERIC(8,4) NOT NULL,
            yearly_rounds_played INTEGER NOT NULL,
            yearly_matches_played INTEGER NOT NULL,
            yearly_singles_matches INTEGER NOT NULL,
            yearly_weighted_match_units NUMERIC(8,2) NOT NULL,
            cumulative_rank INTEGER NOT NULL,
            cumulative_power_score NUMERIC(8,4) NOT NULL,
            cumulative_net_handicap_rank INTEGER NOT NULL,
            cumulative_net_handicap_score NUMERIC(8,4) NOT NULL,
            cumulative_score_performance_raw NUMERIC(8,4) NOT NULL,
            cumulative_score_performance_adj NUMERIC(8,4) NOT NULL,
            cumulative_score_index NUMERIC(8,4) NOT NULL,
            cumulative_win_pct_weighted NUMERIC(8,4) NOT NULL,
            cumulative_win_pct_overall NUMERIC(8,4) NOT NULL,
            cumulative_win_pct_singles NUMERIC(8,4) NOT NULL,
            cumulative_rounds_played INTEGER NOT NULL,
            cumulative_matches_played INTEGER NOT NULL,
            cumulative_singles_matches INTEGER NOT NULL,
            cumulative_weighted_match_units NUMERIC(8,2) NOT NULL,
            cumulative_years_scored INTEGER NOT NULL,
            handicap_index NUMERIC(6,2),
            handicap_imputed BOOLEAN NOT NULL DEFAULT FALSE,
            yearly_trend INTEGER,
            yearly_net_handicap_trend INTEGER,
            cumulative_trend INTEGER,
            cumulative_net_handicap_trend INTEGER,
            line_color TEXT NOT NULL,
            avatar_url TEXT NOT NULL,
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            PRIMARY KEY (ranking_year, player_name)
        );

        ALTER TABLE bcc_power_rankings OWNER TO bcc_admin;
        GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON bcc_power_rankings TO bcc_admin;
        """
    )

    values_sql = ",\n".join(
        "("
        + ", ".join(
            [
                psql_literal(row["year"]),
                psql_literal(row["player"]),
                psql_literal(row["team_2025"]),
                psql_literal(row["season_team"]),
                psql_literal(row["yearly_rank"]),
                psql_literal(row["yearly_power_score"]),
                psql_literal(row["yearly_net_handicap_rank"]),
                psql_literal(row["yearly_net_handicap_score"]),
                psql_literal(row["yearly_score_performance_raw"]),
                psql_literal(row["yearly_score_performance_adj"]),
                psql_literal(row["yearly_score_index"]),
                psql_literal(row["yearly_win_pct_weighted"]),
                psql_literal(row["yearly_win_pct_overall"]),
                psql_literal(row["yearly_win_pct_singles"]),
                psql_literal(row["yearly_rounds_played"]),
                psql_literal(row["yearly_matches_played"]),
                psql_literal(row["yearly_singles_matches"]),
                psql_literal(row["yearly_weighted_match_units"]),
                psql_literal(row["cumulative_rank"]),
                psql_literal(row["cumulative_power_score"]),
                psql_literal(row["cumulative_net_handicap_rank"]),
                psql_literal(row["cumulative_net_handicap_score"]),
                psql_literal(row["cumulative_score_performance_raw"]),
                psql_literal(row["cumulative_score_performance_adj"]),
                psql_literal(row["cumulative_score_index"]),
                psql_literal(row["cumulative_win_pct_weighted"]),
                psql_literal(row["cumulative_win_pct_overall"]),
                psql_literal(row["cumulative_win_pct_singles"]),
                psql_literal(row["cumulative_rounds_played"]),
                psql_literal(row["cumulative_matches_played"]),
                psql_literal(row["cumulative_singles_matches"]),
                psql_literal(row["cumulative_weighted_match_units"]),
                psql_literal(row["cumulative_years_scored"]),
                psql_literal(row["handicap_index"]),
                psql_literal(row["handicap_imputed"]),
                psql_literal(row["yearly_trend"]),
                psql_literal(row["yearly_net_handicap_trend"]),
                psql_literal(row["cumulative_trend"]),
                psql_literal(row["cumulative_net_handicap_trend"]),
                psql_literal(row["line_color"]),
                psql_literal(row["avatar_url"]),
            ]
        )
        + ")"
        for row in payload["rankings"]
    )

    insert_sql = f"""
        INSERT INTO bcc_power_rankings (
            ranking_year, player_name, team_2025, season_team,
            yearly_rank, yearly_power_score, yearly_net_handicap_rank, yearly_net_handicap_score,
            yearly_score_performance_raw, yearly_score_performance_adj,
            yearly_score_index, yearly_win_pct_weighted, yearly_win_pct_overall, yearly_win_pct_singles,
            yearly_rounds_played, yearly_matches_played, yearly_singles_matches, yearly_weighted_match_units,
            cumulative_rank, cumulative_power_score, cumulative_net_handicap_rank, cumulative_net_handicap_score,
            cumulative_score_performance_raw, cumulative_score_performance_adj,
            cumulative_score_index, cumulative_win_pct_weighted, cumulative_win_pct_overall, cumulative_win_pct_singles,
            cumulative_rounds_played, cumulative_matches_played, cumulative_singles_matches, cumulative_weighted_match_units,
            cumulative_years_scored, handicap_index, handicap_imputed, yearly_trend, yearly_net_handicap_trend,
            cumulative_trend, cumulative_net_handicap_trend,
            line_color, avatar_url
        )
        VALUES
        {values_sql};
    """
    psql(insert_sql)


def main() -> None:
    print(f"Fetching source data from {API_URL}")
    payload = build_payload_v3(fetch_api_payload())
    OUTPUT_JSON.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    write_rankings_to_postgres_v3(payload)
    print(f"Wrote snapshot to {OUTPUT_JSON}")
    print(f"Stored {len(payload['rankings'])} ranking rows in PostgreSQL.")


if __name__ == "__main__":
    main()
