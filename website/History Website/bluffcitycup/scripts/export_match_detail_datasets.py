#!/usr/bin/env python3
import csv
import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


ROOT = Path("/Users/rossmon/Developer/bluffcitycup/History Website/bluffcitycup")
API_SNAPSHOT = ROOT / "tmp_api_export_snapshot.json"
PROB_TABLE_JS = ROOT / "assets" / "match_prob_tables.js"
OUT_DIR = ROOT / "data_exports" / "match_detail_datasets"
SSH_CMD = [
    "ssh",
    "-i",
    str(Path.home() / "Downloads" / "LightsailDefaultKey-us-east-2.pem"),
    "bitnami@3.149.108.246",
]


def norm(value: Any) -> str:
    return "" if value is None else str(value).strip()


def int_or_none(value: Any) -> Optional[int]:
    try:
        s = norm(value)
        if s == "":
            return None
        return int(float(s))
    except Exception:
        return None


def float_or_none(value: Any) -> Optional[float]:
    try:
        s = norm(value)
        if s == "":
            return None
        return float(s)
    except Exception:
        return None


def canonical_format_web(format_name: str) -> str:
    f = norm(format_name)
    if f == "Match":
        return "Singles"
    return f


def projection_format(format_name: str) -> str:
    f = canonical_format_web(format_name)
    return {
        "Mod. Alt. Shot": "Alternate Shot",
        "Mod. Alt. Shot.": "Alternate Shot",
        "2-Man Scramble": "Two Man Scramble",
        "4-Man Scramble": "Four Man Scramble",
    }.get(f, f)


def player_key(name: str) -> str:
    return norm(name).lower()


def first_last_key(name: str) -> str:
    parts = [p for p in norm(name).lower().split() if p]
    if len(parts) < 2:
        return ""
    return f"{parts[0]}_{parts[-1]}"


def fetch_api_snapshot() -> Dict[str, Any]:
    API_SNAPSHOT.parent.mkdir(parents=True, exist_ok=True)
    cmd = SSH_CMD + ["curl", "-s", "http://localhost/bluffcitycup/api.php"]
    raw = subprocess.check_output(cmd, text=True)
    API_SNAPSHOT.write_text(raw)
    return json.loads(raw)


def load_prob_tables() -> Dict[str, Any]:
    text = PROB_TABLE_JS.read_text()
    prefix = "window.BCC_MATCH_PROB_TABLES = "
    if not text.startswith(prefix):
        raise RuntimeError("Unexpected probability table asset format.")
    payload = text[len(prefix):].strip()
    if payload.endswith(";"):
        payload = payload[:-1]
    return json.loads(payload)


def round_half_up(value: float) -> int:
    # Swift Darwin.round is half-away-from-zero for .5 cases; Python round is bankers.
    if value >= 0:
        return int(value + 0.5)
    return int(value - 0.5)


def handicap_score(actual_score: Optional[int], player_handicap: Optional[int], hole_handicap: Optional[int]) -> Optional[int]:
    if actual_score is None:
        return None
    if actual_score <= 0:
        return actual_score
    if player_handicap is None or hole_handicap is None:
        return actual_score
    if player_handicap >= 36:
        return actual_score - (3 if (player_handicap - 36) >= hole_handicap else 2)
    if player_handicap >= 18:
        return actual_score - (2 if (player_handicap - 18) >= hole_handicap else 1)
    return actual_score - (1 if player_handicap >= hole_handicap else 0)


def course_handicap_from_index(player_hcp: Optional[float], slope: Optional[int], rating: Optional[float], par: Optional[float], max_hcp: Optional[int]) -> Optional[int]:
    if None in (player_hcp, slope, rating, par, max_hcp):
        return None
    return min(round_half_up(player_hcp * (slope / 113.0) + (rating - par)), max_hcp)


def shamble_course_handicap_from_index(player_hcp: Optional[float], slope: Optional[int], rating: Optional[float], par: Optional[float], max_hcp: Optional[int]) -> Optional[int]:
    if None in (player_hcp, slope, rating, par, max_hcp):
        return None
    return min(round_half_up(0.8 * (player_hcp * (slope / 113.0) + (rating - par))), max_hcp)


def slope_only_course_handicap(player_hcp: Optional[float], slope: Optional[int], max_hcp: Optional[int]) -> Optional[int]:
    if None in (player_hcp, slope, max_hcp):
        return None
    return min(round_half_up(player_hcp * (slope / 113.0)), max_hcp)


def team_hcp_two_player(fmt: str, p1_full: Optional[int], p2_full: Optional[int]) -> Optional[int]:
    if p1_full is None or p2_full is None:
        return None
    if fmt == "Alternate Shot":
        return round_half_up(p1_full * 0.5 + p2_full * 0.5)
    if fmt == "Two Man Scramble":
        return round_half_up(p1_full * 0.35 + p2_full * 0.15)
    return None


def team_hcp_four_man_scramble(slope_only_vals: List[Optional[int]]) -> Optional[int]:
    if len(slope_only_vals) < 4 or any(v is None for v in slope_only_vals[:4]):
        return None
    v = [float(slope_only_vals[i]) for i in range(4)]
    return round_half_up(v[0] * 0.20 + v[1] * 0.15 + v[2] * 0.10 + v[3] * 0.05)


def bool_text(v: bool) -> str:
    return "1" if v else "0"


def winner_from_group(red_row: Optional[dict], blue_row: Optional[dict]) -> str:
    red_wl = norm((red_row or {}).get("win_or_loss")).lower()
    blue_wl = norm((blue_row or {}).get("win_or_loss")).lower()
    if red_wl == "win" or blue_wl == "loss":
        return "Red"
    if blue_wl == "win" or red_wl == "loss":
        return "Blue"
    if red_wl == "tie" or blue_wl == "tie":
        return "Tie"
    return ""


def get_players_from_side_row(row: Optional[dict]) -> List[str]:
    if not row:
        return []
    players = []
    for i in range(1, 5):
        name = norm(row.get(f"player{i}"))
        if name:
            players.append(name)
    return players


def safe_filename(s: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", s).strip("_")


def write_csv(path: Path, rows: List[Dict[str, Any]], fieldnames: List[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        for row in rows:
            writer.writerow({k: row.get(k, "") for k in fieldnames})


def projection_lookup_static(prob_tables: Dict[str, Any], fmt: str, match_length: int, starting_hole: int, hole: int, score_diff: int) -> Optional[Dict[str, float]]:
    fmt_table = prob_tables.get(fmt)
    if not isinstance(fmt_table, dict):
        return None
    length_table = fmt_table.get(str(match_length))
    if not isinstance(length_table, dict):
        return None
    relative_hole = hole - starting_hole + 1
    row = (length_table.get(str(relative_hole)) or {}).get(str(score_diff))
    if not isinstance(row, dict):
        return None
    try:
        return {
            "blue": float(row["blueWin"]) * 100.0,
            "red": float(row["redWin"]) * 100.0,
            "tie": float(row["tie"]) * 100.0,
            "relative_hole": relative_hole,
        }
    except Exception:
        return None


def main() -> int:
    print("Fetching live API snapshot...")
    payload = fetch_api_snapshot()
    prob_tables = load_prob_tables()

    rows = payload.get("rows", [])
    year_outcomes = payload.get("yearOutcomes", [])
    match_courses = payload.get("matchCourses", [])
    holes = payload.get("holes", [])
    scores = payload.get("scores", [])
    player_hcps = payload.get("playerHandicaps", [])
    courses_meta = payload.get("coursesMeta", [])
    tournament_settings = payload.get("tournamentSettings", [])
    player_pictures = payload.get("playerPictures", [])

    # Lookups
    year_location = {norm(r.get("year")): norm(r.get("location")) for r in year_outcomes}

    match_meta_by_key = defaultdict(list)
    for r in match_courses:
        k = (norm(r.get("year")), norm(r.get("round")), norm(r.get("match")))
        match_meta_by_key[k].append(r)

    holes_by_course_tees = defaultdict(dict)
    for h in holes:
        k = (norm(h.get("course")), norm(h.get("tees")))
        hole_no = int_or_none(h.get("holenumber"))
        if hole_no is None:
            continue
        holes_by_course_tees[k][hole_no] = {
            "hole": hole_no,
            "handicap": int_or_none(h.get("handicap")),
            "par": int_or_none(h.get("par")),
            "yards": int_or_none(h.get("length")),
        }

    score_lookup = {}
    for s in scores:
        k = (norm(s.get("year")), norm(s.get("round")), norm(s.get("course")), player_key(s.get("player")), int_or_none(s.get("hole")))
        hole = k[4]
        if hole is None:
            continue
        score_lookup[k] = int_or_none(s.get("actualscore"))

    player_hcp_lookup = defaultdict(list)
    for p in player_hcps:
        k = (norm(p.get("year")), norm(p.get("name")))
        player_hcp_lookup[k].append(p)

    course_meta_lookup = {}
    for c in courses_meta:
        course_meta_lookup[(norm(c.get("course")), norm(c.get("tees")))] = c

    tournament_max_lookup = {}
    for t in tournament_settings:
        year = norm(t.get("year"))
        val = int_or_none(t.get("maxhandicap"))
        if year and val is not None:
            tournament_max_lookup[year] = val

    pic_lookup = {}
    for pic in player_pictures:
        key = (norm(pic.get("team")), norm(pic.get("key")).lower())
        pic_lookup[key] = pic

    # Group bcc_match_results into one row per match
    grouped = defaultdict(list)
    for r in rows:
        k = (norm(r.get("year")), norm(r.get("round")), norm(r.get("match")), canonical_format_web(norm(r.get("format"))))
        grouped[k].append(r)

    matches_rows: List[Dict[str, Any]] = []
    participants_rows: List[Dict[str, Any]] = []
    team_hcp_rows: List[Dict[str, Any]] = []
    hole_rows: List[Dict[str, Any]] = []
    hole_player_rows: List[Dict[str, Any]] = []
    hole_popup_rows: List[Dict[str, Any]] = []
    prob_chart_rows: List[Dict[str, Any]] = []
    prob_summary_rows: List[Dict[str, Any]] = []
    issues_rows: List[Dict[str, Any]] = []

    for (year, round_no, match_no, fmt_display), side_rows in sorted(grouped.items()):
        red_row = next((r for r in side_rows if norm(r.get("team")) == "Red"), None)
        blue_row = next((r for r in side_rows if norm(r.get("team")) == "Blue"), None)
        if red_row is None or blue_row is None:
            issues_rows.append({
                "year": year,
                "round": round_no,
                "match": match_no,
                "format": fmt_display,
                "issue": "missing_red_or_blue_row",
            })
            continue

        meta_candidates = match_meta_by_key.get((year, round_no, match_no), [])
        meta = meta_candidates[0] if meta_candidates else {}
        matchgroup = norm(meta.get("matchgroup"))
        match_uid = f"{year}-R{round_no}-M{match_no}" + (f"-G{matchgroup}" if matchgroup else "")

        red_players = get_players_from_side_row(red_row)
        blue_players = get_players_from_side_row(blue_row)
        winner = winner_from_group(red_row, blue_row)
        score_text = norm(red_row.get("score")) or norm(blue_row.get("score"))
        points_text = norm(red_row.get("points")) or norm(blue_row.get("points"))

        course = norm(meta.get("course"))
        tees = norm(meta.get("tees"))
        match_length = int_or_none(meta.get("matchlength"))
        starting_hole = int_or_none(meta.get("startinghole")) or 1
        if match_length is None:
            match_length = 18 if any(int_or_none(s.get("hole")) and int_or_none(s.get("hole")) > 9 for s in scores if norm(s.get("year")) == year and norm(s.get("round")) == round_no and norm(s.get("course")) == course) else 9

        end_hole = min(18, starting_hole + match_length - 1)
        hole_range = list(range(starting_hole, end_hole + 1))

        course_meta = course_meta_lookup.get((course, tees), {})
        slope = int_or_none(course_meta.get("slope"))
        rating = float_or_none(course_meta.get("rating"))
        par = float_or_none(course_meta.get("par"))
        max_handicap = tournament_max_lookup.get(year, 30)
        location = year_location.get(year, "")
        fmt_app = projection_format(fmt_display)

        # Participant handicap indexes and derived handicaps
        participant_info = []
        for team, team_players in (("Red", red_players), ("Blue", blue_players)):
            for slot, name in enumerate(team_players, start=1):
                candidates = player_hcp_lookup.get((year, name), [])
                chosen = next((c for c in candidates if norm(c.get("team")) == team), None) or (candidates[0] if candidates else None)
                hcp_index = float_or_none((chosen or {}).get("handicap"))
                full_course_hcp = course_handicap_from_index(hcp_index, slope, rating, par, max_handicap)
                shamble_hcp = shamble_course_handicap_from_index(hcp_index, slope, rating, par, max_handicap)
                slope_only_hcp = slope_only_course_handicap(hcp_index, slope, max_handicap)
                pic = pic_lookup.get((team, first_last_key(name)), {})
                participant_info.append({
                    "team": team,
                    "slot": slot,
                    "player_name": name,
                    "handicap_index": hcp_index,
                    "course_handicap_full": full_course_hcp,
                    "course_handicap_shamble": shamble_hcp,
                    "course_handicap_slope_only": slope_only_hcp,
                    "picture_file": norm(pic.get("file")),
                    "picture_url": norm(pic.get("url")),
                })

        pinfo_by_team = {
            "Red": [p for p in participant_info if p["team"] == "Red"],
            "Blue": [p for p in participant_info if p["team"] == "Blue"],
        }
        pinfo_by_name = {player_key(p["player_name"]): p for p in participant_info}

        # Format-specific handicap context
        player_match_strokes: Dict[str, Optional[int]] = {}
        team_raw_hcp: Dict[str, Optional[int]] = {"Red": None, "Blue": None}
        team_match_strokes: Dict[str, Optional[int]] = {"Red": None, "Blue": None}
        team_hcp_method = ""

        if fmt_app == "Singles":
            vals = [p["course_handicap_full"] for p in participant_info if p["course_handicap_full"] is not None]
            low = min(vals) if vals else None
            for p in participant_info:
                player_match_strokes[player_key(p["player_name"])] = (p["course_handicap_full"] - low) if (low is not None and p["course_handicap_full"] is not None) else None
            team_hcp_method = "player_course_handicap_relative_to_low"
        elif fmt_app == "Best Ball":
            vals = [p["course_handicap_full"] for p in participant_info if p["course_handicap_full"] is not None]
            low = min(vals) if vals else None
            for p in participant_info:
                player_match_strokes[player_key(p["player_name"])] = (p["course_handicap_full"] - low) if (low is not None and p["course_handicap_full"] is not None) else None
            team_hcp_method = "best_ball_player_course_handicap_relative_to_match_low"
        elif fmt_app == "Shamble":
            vals = [p["course_handicap_shamble"] for p in participant_info if p["course_handicap_shamble"] is not None]
            low = min(vals) if vals else None
            for p in participant_info:
                player_match_strokes[player_key(p["player_name"])] = (p["course_handicap_shamble"] - low) if (low is not None and p["course_handicap_shamble"] is not None) else None
            team_hcp_method = "shamble_player_course_handicap_relative_to_match_low"
        elif fmt_app in ("Alternate Shot", "Two Man Scramble"):
            team_hcp_method = "weighted_team_course_handicap_relative_to_low"
            for team in ("Red", "Blue"):
                team_players_info = pinfo_by_team[team]
                if len(team_players_info) >= 2:
                    team_raw_hcp[team] = team_hcp_two_player(
                        fmt_app,
                        team_players_info[0]["course_handicap_full"],
                        team_players_info[1]["course_handicap_full"],
                    )
                elif len(team_players_info) == 1:
                    team_raw_hcp[team] = team_players_info[0]["course_handicap_full"]
            if team_raw_hcp["Red"] is not None and team_raw_hcp["Blue"] is not None:
                low = min(team_raw_hcp["Red"], team_raw_hcp["Blue"])
                team_match_strokes["Red"] = team_raw_hcp["Red"] - low
                team_match_strokes["Blue"] = team_raw_hcp["Blue"] - low
        elif fmt_app == "Four Man Scramble":
            team_hcp_method = "4man_scramble_weighted_slope_only_team_handicap_relative_to_low"
            for team in ("Red", "Blue"):
                team_players_info = pinfo_by_team[team]
                vals = [p["course_handicap_slope_only"] for p in team_players_info]
                if len(vals) >= 4:
                    team_raw_hcp[team] = team_hcp_four_man_scramble(vals)
            if team_raw_hcp["Red"] is not None and team_raw_hcp["Blue"] is not None:
                low = min(team_raw_hcp["Red"], team_raw_hcp["Blue"])
                team_match_strokes["Red"] = team_raw_hcp["Red"] - low
                team_match_strokes["Blue"] = team_raw_hcp["Blue"] - low
        else:
            team_hcp_method = "unsupported_format"

        # Build hole meta and actual/net scores
        hole_defs_map = holes_by_course_tees.get((course, tees), {})
        hole_defs = []
        for hole in hole_range:
            h = hole_defs_map.get(hole)
            if h:
                hole_defs.append(h)
            else:
                hole_defs.append({"hole": hole, "handicap": None, "par": None, "yards": None})
                issues_rows.append({
                    "match_uid": match_uid,
                    "year": year,
                    "round": round_no,
                    "match": match_no,
                    "hole": hole,
                    "issue": "missing_hole_definition",
                })

        def actual_score_for_player(player_name: str, hole: int) -> Optional[int]:
            return score_lookup.get((year, round_no, course, player_key(player_name), hole))

        def net_score_for_player(player_name: str, hole: int) -> Optional[int]:
            actual = actual_score_for_player(player_name, hole)
            pinfo = pinfo_by_name.get(player_key(player_name))
            if pinfo is None:
                return actual
            stroke = player_match_strokes.get(player_key(player_name))
            hole_hcp = next((h["handicap"] for h in hole_defs if h["hole"] == hole), None)
            return handicap_score(actual, stroke, hole_hcp)

        def actual_score_for_team(team: str, hole: int) -> Optional[int]:
            team_players = pinfo_by_team[team]
            vals = [actual_score_for_player(p["player_name"], hole) for p in team_players]
            vals = [v for v in vals if v is not None]
            if not vals:
                return None
            if fmt_app in ("Best Ball", "Shamble", "Singles"):
                return min(vals)
            return vals[0]

        def net_score_for_team(team: str, hole: int) -> Optional[int]:
            hole_hcp = next((h["handicap"] for h in hole_defs if h["hole"] == hole), None)
            if fmt_app in ("Best Ball", "Shamble", "Singles"):
                vals = [net_score_for_player(p["player_name"], hole) for p in pinfo_by_team[team]]
                vals = [v for v in vals if v is not None]
                return min(vals) if vals else None
            actual = actual_score_for_team(team, hole)
            return handicap_score(actual, team_match_strokes.get(team), hole_hcp)

        # Popup row definitions
        popup_rows = []
        if fmt_display in ("2-Man Scramble", "Mod. Alt. Shot", "Shamble", "4-Man Scramble"):
            for team in ("Red", "Blue"):
                members = [p["player_name"] for p in pinfo_by_team[team]]
                popup_rows.append({
                    "team": team,
                    "row_kind": "team",
                    "label": " / ".join([n.split()[-1] for n in members if n]) if members else team,
                    "members": members,
                    "row_id": f"{team}:team",
                })
        else:
            for team in ("Red", "Blue"):
                for p in pinfo_by_team[team]:
                    popup_rows.append({
                        "team": team,
                        "row_kind": "player",
                        "label": p["player_name"].split()[-1] if norm(p["player_name"]) else "",
                        "members": [p["player_name"]],
                        "row_id": f"{team}:{p['player_name']}",
                    })

        # Precompute popup row scores and win highlight
        popup_row_score_by_hole: Dict[Tuple[str, int], Tuple[Optional[int], Optional[int]]] = {}
        popup_highlight: Dict[Tuple[str, int], bool] = {}
        for row_def in popup_rows:
            for h in hole_defs:
                hole = h["hole"]
                if row_def["row_kind"] == "team":
                    actual = actual_score_for_team(row_def["team"], hole)
                    net = net_score_for_team(row_def["team"], hole)
                else:
                    player_name = row_def["members"][0]
                    actual = actual_score_for_player(player_name, hole)
                    net = net_score_for_player(player_name, hole)
                popup_row_score_by_hole[(row_def["row_id"], hole)] = (actual, net)
                popup_highlight[(row_def["row_id"], hole)] = False

        # Highlight logic (mirrors popup)
        for h in hole_defs:
            hole = h["hole"]
            red_row_candidates = []
            blue_row_candidates = []
            for idx, row_def in enumerate(popup_rows):
                _, net = popup_row_score_by_hole[(row_def["row_id"], hole)]
                if net is None:
                    continue
                item = (idx, row_def, net)
                if row_def["team"] == "Red":
                    red_row_candidates.append(item)
                else:
                    blue_row_candidates.append(item)
            if not red_row_candidates or not blue_row_candidates:
                continue
            red_best = min(x[2] for x in red_row_candidates)
            blue_best = min(x[2] for x in blue_row_candidates)
            if red_best < blue_best:
                for _, row_def, net in red_row_candidates:
                    if net == red_best:
                        popup_highlight[(row_def["row_id"], hole)] = True
            elif blue_best < red_best:
                for _, row_def, net in blue_row_candidates:
                    if net == blue_best:
                        popup_highlight[(row_def["row_id"], hole)] = True

        # Build hole/team/player datasets
        cumulative_blue = 0
        cumulative_red = 0
        played_holes_for_prob: List[Tuple[int, str]] = []

        for rel_idx, h in enumerate(hole_defs, start=1):
            hole = h["hole"]
            red_team_actual = actual_score_for_team("Red", hole)
            blue_team_actual = actual_score_for_team("Blue", hole)
            red_team_net = net_score_for_team("Red", hole)
            blue_team_net = net_score_for_team("Blue", hole)
            hole_winner_actual = ""
            hole_winner_net = ""
            if red_team_actual is not None and blue_team_actual is not None:
                if red_team_actual < blue_team_actual:
                    hole_winner_actual = "Red"
                elif blue_team_actual < red_team_actual:
                    hole_winner_actual = "Blue"
                else:
                    hole_winner_actual = "AS"
            if red_team_net is not None and blue_team_net is not None:
                if red_team_net < blue_team_net:
                    hole_winner_net = "Red"
                elif blue_team_net < red_team_net:
                    hole_winner_net = "Blue"
                else:
                    hole_winner_net = "AS"
                played_holes_for_prob.append((hole, hole_winner_net))

            score_diff_before = cumulative_blue - cumulative_red
            if hole_winner_net == "Blue":
                cumulative_blue += 1
            elif hole_winner_net == "Red":
                cumulative_red += 1
            score_diff_after = cumulative_blue - cumulative_red

            hole_rows.append({
                "match_uid": match_uid,
                "year": year,
                "round": round_no,
                "match": match_no,
                "matchgroup": matchgroup,
                "format_display": fmt_display,
                "format_app": fmt_app,
                "hole": hole,
                "relative_hole": rel_idx,
                "hole_handicap": h["handicap"],
                "par": h["par"],
                "yards": h["yards"],
                "red_team_actual": red_team_actual,
                "blue_team_actual": blue_team_actual,
                "red_team_net": red_team_net,
                "blue_team_net": blue_team_net,
                "hole_winner_actual": hole_winner_actual,
                "hole_winner_net": hole_winner_net,
                "score_diff_before_hole": score_diff_before,
                "score_diff_after_hole": score_diff_after,
                "hole_played": bool_text(hole_winner_net != ""),
            })

            for p in participant_info:
                pname = p["player_name"]
                actual = actual_score_for_player(pname, hole)
                net = net_score_for_player(pname, hole)
                popup_displayed = any(
                    row_def["row_kind"] == "player" and row_def["team"] == p["team"] and row_def["members"][0] == pname
                    for row_def in popup_rows
                )
                popup_high = False
                if popup_displayed:
                    row_id = f"{p['team']}:{pname}"
                    popup_high = popup_highlight.get((row_id, hole), False)
                hole_player_rows.append({
                    "match_uid": match_uid,
                    "year": year,
                    "round": round_no,
                    "match": match_no,
                    "matchgroup": matchgroup,
                    "hole": hole,
                    "relative_hole": rel_idx,
                    "team": p["team"],
                    "player_name": pname,
                    "actual_score": actual,
                    "net_score": net,
                    "handicap_index": p["handicap_index"],
                    "course_handicap_full": p["course_handicap_full"],
                    "course_handicap_shamble": p["course_handicap_shamble"],
                    "course_handicap_slope_only": p["course_handicap_slope_only"],
                    "match_strokes_used": player_match_strokes.get(player_key(pname)),
                    "popup_row_displayed": bool_text(popup_displayed),
                    "popup_score_highlight": bool_text(popup_high),
                })

            for row_order, row_def in enumerate(popup_rows, start=1):
                actual, net = popup_row_score_by_hole[(row_def["row_id"], hole)]
                hole_popup_rows.append({
                    "match_uid": match_uid,
                    "year": year,
                    "round": round_no,
                    "match": match_no,
                    "matchgroup": matchgroup,
                    "hole": hole,
                    "relative_hole": rel_idx,
                    "row_order": row_order,
                    "row_id": row_def["row_id"],
                    "row_team": row_def["team"],
                    "row_kind": row_def["row_kind"],
                    "row_label": row_def["label"],
                    "row_member_names": "|".join(row_def["members"]),
                    "actual_score": actual,
                    "net_score": net,
                    "popup_highlight": bool_text(popup_highlight.get((row_def["row_id"], hole), False)),
                })

        # Probability chart rows (app-style static table logic)
        points = []
        if played_holes_for_prob:
            first_hole = played_holes_for_prob[0][0]
            initial = projection_lookup_static(prob_tables, fmt_app, match_length, starting_hole, first_hole, 0)
            if initial:
                points.append((1, first_hole, initial["relative_hole"], 0, initial["blue"], initial["tie"], initial["red"]))

            blue_wins = 0
            red_wins = 0
            for idx in range(1, len(played_holes_for_prob)):
                prev_hole, prev_winner = played_holes_for_prob[idx - 1]
                if prev_winner == "Blue":
                    blue_wins += 1
                elif prev_winner == "Red":
                    red_wins += 1
                diff = blue_wins - red_wins
                hole = played_holes_for_prob[idx][0]
                prob = projection_lookup_static(prob_tables, fmt_app, match_length, starting_hole, hole, diff)
                if prob:
                    points.append((idx + 1, hole, prob["relative_hole"], diff, prob["blue"], prob["tie"], prob["red"]))
        else:
            initial = projection_lookup_static(prob_tables, fmt_app, match_length, starting_hole, starting_hole, 0)
            if initial:
                points.append((1, starting_hole, initial["relative_hole"], 0, initial["blue"], initial["tie"], initial["red"]))

        if not points and fmt_app != "Four Man Scramble":
            issues_rows.append({
                "match_uid": match_uid,
                "year": year,
                "round": round_no,
                "match": match_no,
                "format": fmt_display,
                "issue": "no_projection_points_found",
            })

        for point_order, hole, rel_hole, diff, blue_pct, tie_pct, red_pct in points:
            prob_chart_rows.append({
                "match_uid": match_uid,
                "year": year,
                "round": round_no,
                "match": match_no,
                "matchgroup": matchgroup,
                "format_display": fmt_display,
                "format_app": fmt_app,
                "point_order": point_order,
                "hole": hole,
                "relative_hole": rel_hole,
                "score_diff_before_hole": diff,
                "blue_win_prob_pct": round(blue_pct, 3),
                "tie_prob_pct": round(tie_pct, 3),
                "red_win_prob_pct": round(red_pct, 3),
                "source": "app_static_table",
            })

        summary_source = points[-1] if points else None
        if winner == "Blue":
            summary_blue, summary_tie, summary_red = 100.0, 0.0, 0.0
            summary_mode = "deterministic_final_result"
        elif winner == "Red":
            summary_blue, summary_tie, summary_red = 0.0, 0.0, 100.0
            summary_mode = "deterministic_final_result"
        elif winner == "Tie":
            summary_blue, summary_tie, summary_red = 0.0, 100.0, 0.0
            summary_mode = "deterministic_final_result"
        elif summary_source:
            summary_blue, summary_tie, summary_red = float(summary_source[4]), float(summary_source[5]), float(summary_source[6])
            summary_mode = "last_chart_point"
        else:
            summary_blue, summary_tie, summary_red = None, None, None
            summary_mode = "unavailable"

        prob_summary_rows.append({
            "match_uid": match_uid,
            "year": year,
            "round": round_no,
            "match": match_no,
            "matchgroup": matchgroup,
            "format_display": fmt_display,
            "format_app": fmt_app,
            "blue_win_prob_pct": summary_blue,
            "tie_prob_pct": summary_tie,
            "red_win_prob_pct": summary_red,
            "summary_mode": summary_mode,
        })

        # Match / participant / team handicap datasets
        matches_rows.append({
            "match_uid": match_uid,
            "year": year,
            "round": round_no,
            "match": match_no,
            "matchgroup": matchgroup,
            "format_display": fmt_display,
            "format_app": fmt_app,
            "winner": winner,
            "score": score_text,
            "points": points_text,
            "location": location,
            "course": course,
            "tees": tees,
            "matchlength": match_length,
            "startinghole": starting_hole,
            "endinghole": end_hole,
            "course_slope": slope,
            "course_rating": rating,
            "course_par": par,
            "tournament_maxhandicap": max_handicap,
            "red_players": "|".join(red_players),
            "blue_players": "|".join(blue_players),
            "match_meta_candidate_count": len(meta_candidates),
        })

        for p in participant_info:
            name_parts = norm(p["player_name"]).split()
            participants_rows.append({
                "match_uid": match_uid,
                "year": year,
                "round": round_no,
                "match": match_no,
                "matchgroup": matchgroup,
                "format_display": fmt_display,
                "format_app": fmt_app,
                "team": p["team"],
                "slot": p["slot"],
                "player_name": p["player_name"],
                "first_name": name_parts[0] if name_parts else "",
                "last_name": name_parts[-1] if name_parts else "",
                "picture_file": p["picture_file"],
                "picture_url": p["picture_url"],
                "handicap_index": p["handicap_index"],
                "course_handicap_full": p["course_handicap_full"],
                "course_handicap_shamble": p["course_handicap_shamble"],
                "course_handicap_slope_only": p["course_handicap_slope_only"],
                "match_strokes_used": player_match_strokes.get(player_key(p["player_name"])),
                "popup_row_displayed": bool_text(any(r["row_kind"] == "player" and r["members"] == [p["player_name"]] for r in popup_rows)),
            })

        for team in ("Red", "Blue"):
            team_hcp_rows.append({
                "match_uid": match_uid,
                "year": year,
                "round": round_no,
                "match": match_no,
                "matchgroup": matchgroup,
                "format_display": fmt_display,
                "format_app": fmt_app,
                "team": team,
                "team_handicap_method": team_hcp_method,
                "team_course_handicap_raw": team_raw_hcp.get(team),
                "team_match_strokes_relative": team_match_strokes.get(team),
                "players": "|".join([p["player_name"] for p in pinfo_by_team[team]]),
            })

        if not course or not tees:
            issues_rows.append({
                "match_uid": match_uid,
                "year": year,
                "round": round_no,
                "match": match_no,
                "format": fmt_display,
                "issue": "missing_course_or_tees_meta",
            })

    # Output schemas
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    write_csv(OUT_DIR / "matches.csv", matches_rows, [
        "match_uid", "year", "round", "match", "matchgroup",
        "format_display", "format_app", "winner", "score", "points",
        "location", "course", "tees", "matchlength", "startinghole", "endinghole",
        "course_slope", "course_rating", "course_par", "tournament_maxhandicap",
        "red_players", "blue_players", "match_meta_candidate_count",
    ])

    write_csv(OUT_DIR / "match_participants.csv", participants_rows, [
        "match_uid", "year", "round", "match", "matchgroup",
        "format_display", "format_app", "team", "slot",
        "player_name", "first_name", "last_name",
        "picture_file", "picture_url",
        "handicap_index",
        "course_handicap_full", "course_handicap_shamble", "course_handicap_slope_only",
        "match_strokes_used", "popup_row_displayed",
    ])

    write_csv(OUT_DIR / "match_team_handicaps.csv", team_hcp_rows, [
        "match_uid", "year", "round", "match", "matchgroup",
        "format_display", "format_app", "team", "team_handicap_method",
        "team_course_handicap_raw", "team_match_strokes_relative", "players",
    ])

    write_csv(OUT_DIR / "match_holes.csv", hole_rows, [
        "match_uid", "year", "round", "match", "matchgroup",
        "format_display", "format_app",
        "hole", "relative_hole", "hole_handicap", "par", "yards",
        "red_team_actual", "blue_team_actual", "red_team_net", "blue_team_net",
        "hole_winner_actual", "hole_winner_net",
        "score_diff_before_hole", "score_diff_after_hole", "hole_played",
    ])

    write_csv(OUT_DIR / "match_hole_player_scores.csv", hole_player_rows, [
        "match_uid", "year", "round", "match", "matchgroup",
        "hole", "relative_hole", "team", "player_name",
        "actual_score", "net_score",
        "handicap_index", "course_handicap_full", "course_handicap_shamble", "course_handicap_slope_only",
        "match_strokes_used", "popup_row_displayed", "popup_score_highlight",
    ])

    write_csv(OUT_DIR / "match_hole_popup_rows.csv", hole_popup_rows, [
        "match_uid", "year", "round", "match", "matchgroup",
        "hole", "relative_hole", "row_order", "row_id", "row_team", "row_kind",
        "row_label", "row_member_names", "actual_score", "net_score", "popup_highlight",
    ])

    write_csv(OUT_DIR / "match_probabilities_chart.csv", prob_chart_rows, [
        "match_uid", "year", "round", "match", "matchgroup",
        "format_display", "format_app",
        "point_order", "hole", "relative_hole", "score_diff_before_hole",
        "blue_win_prob_pct", "tie_prob_pct", "red_win_prob_pct", "source",
    ])

    write_csv(OUT_DIR / "match_probabilities_summary.csv", prob_summary_rows, [
        "match_uid", "year", "round", "match", "matchgroup",
        "format_display", "format_app",
        "blue_win_prob_pct", "tie_prob_pct", "red_win_prob_pct", "summary_mode",
    ])

    write_csv(OUT_DIR / "data_quality_issues.csv", issues_rows, [
        "match_uid", "year", "round", "match", "hole", "format", "issue"
    ])

    manifest = {
        "source": "live_api_plus_app_static_probability_tables",
        "generated_files": {
            "matches.csv": len(matches_rows),
            "match_participants.csv": len(participants_rows),
            "match_team_handicaps.csv": len(team_hcp_rows),
            "match_holes.csv": len(hole_rows),
            "match_hole_player_scores.csv": len(hole_player_rows),
            "match_hole_popup_rows.csv": len(hole_popup_rows),
            "match_probabilities_chart.csv": len(prob_chart_rows),
            "match_probabilities_summary.csv": len(prob_summary_rows),
            "data_quality_issues.csv": len(issues_rows),
        },
        "keys": {
            "primary_match_key": "match_uid",
            "recommended_join_columns": ["year", "round", "match", "matchgroup", "match_uid"],
        },
        "notes": [
            "matchgroup is included because year+round+match may not be globally unique in all source schemas",
            "popup chart probabilities use app static tables from Tournament.swift (not DB matchprobabilities table)",
            "match_probabilities_summary.csv uses deterministic final 100/0/0 or tie override for completed matches",
            "match_hole_popup_rows.csv contains the rows actually shown in the popup scorecard",
            "match_hole_player_scores.csv always includes player-level actual and net scores, even for team-display formats",
        ],
    }
    (OUT_DIR / "manifest.json").write_text(json.dumps(manifest, indent=2))

    readme = f"""# Match Detail Datasets

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
"""
    (OUT_DIR / "README.md").write_text(readme)

    print(f"Wrote dataset package to: {OUT_DIR}")
    print(json.dumps(manifest["generated_files"], indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())

