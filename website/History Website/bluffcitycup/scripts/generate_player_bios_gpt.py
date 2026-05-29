 #!/usr/bin/env python3
import argparse
import csv
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any, Dict, List, Tuple

BASE = Path("/Users/rossmon/Developer/bluffcitycup/History Website/bluffcitycup/data_exports/match_detail_datasets")
DEFAULT_OUT = BASE / "player_bios_gpt52.csv"
DEFAULT_CACHE = BASE / "player_bios_gpt52_cache.jsonl"

BIO_PROMPT = """You are writing a player bio for a long-running team golf competition using structured historical match data.

You will receive a structured dataset for one player that may include:
- Team and career span
- Overall record and points
- Format-by-format performance
- Tournament/year-by-year performance
- Common partners (same team)
- Most frequent opponents and head-to-head record vs those opponents
- Notable wins/losses and short match summaries

Write a 200-300 word bio that is analytical, specific, and readable.

Requirements:
1. Write in one clean paragraph (no bullets, no headings).
2. Ground the bio in the provided data only; do not invent facts.
3. Highlight some combination of: common partners, rivalries on the opposing team, strongest formats, best tournaments, and best matches.
4. Use match-play-aware language and show you understand context (formats, records, momentum, points).
5. Include some wit/humor, but keep it restrained and supported by the data.
6. Avoid generic praise or filler.
7. If the player has a small sample, acknowledge that briefly and focus on what is actually present.

Return only the bio paragraph."""


def norm(v: Any) -> str:
    return "" if v is None else str(v).strip()


def read_csv(path: Path) -> List[Dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def to_int(v: Any, default: int = 0) -> int:
    try:
        return int(float(norm(v)))
    except Exception:
        return default


def to_float(v: Any, default: float = 0.0) -> float:
    try:
        return float(norm(v))
    except Exception:
        return default


def pct(w: int, t: int, m: int) -> float:
    return round(((w + 0.5 * t) / m) * 100, 1) if m else 0.0


def points_pct(w: int, t: int, m: int) -> float:
    return round(((w + t) / m) * 100, 1) if m else 0.0


def score_margin(score: str) -> int:
    s = norm(score).upper()
    if s in {"AS", "A/S", "ALL SQUARE", "HALVED"}:
        return 0
    m = re.search(r"(\d+)\s*&\s*(\d+)", s)
    if m:
        return int(m.group(1))
    m = re.search(r"(\d+)\s*UP", s)
    if m:
        return int(m.group(1))
    return 0


def sanitize_summary(text: str) -> str:
    return " ".join(norm(text).split())


def extract_response_text(payload: Dict[str, Any]) -> str:
    if isinstance(payload.get("output_text"), str) and payload["output_text"].strip():
        return payload["output_text"].strip()
    texts: List[str] = []
    for item in payload.get("output", []) or []:
        for content in item.get("content", []) or []:
            t = content.get("text")
            if isinstance(t, str):
                texts.append(t)
    joined = "\n".join(t for t in texts if t.strip()).strip()
    if joined:
        return joined
    raise RuntimeError(f"Unable to extract text from API response: keys={list(payload.keys())}")


def call_openai(model: str, api_key: str, prompt: str, payload_obj: Dict[str, Any], timeout: int = 120) -> str:
    body = {
        "model": model,
        "input": [
            {
                "role": "system",
                "content": [{"type": "input_text", "text": prompt}],
            },
            {
                "role": "user",
                "content": [{"type": "input_text", "text": json.dumps(payload_obj, separators=(",", ":"), ensure_ascii=True)}],
            },
        ],
    }
    req = urllib.request.Request(
        "https://api.openai.com/v1/responses",
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    return extract_response_text(data)


def load_cache(path: Path) -> Dict[str, Dict[str, str]]:
    if not path.exists():
        return {}
    out: Dict[str, Dict[str, str]] = {}
    with path.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
            except Exception:
                continue
            key = norm(row.get("player_name"))
            if key:
                out[key] = row
    return out


def append_cache(path: Path, row: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(row, ensure_ascii=False) + "\n")


def write_csv(path: Path, rows: List[Dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "player_name", "team", "first_name", "last_name", "career_matches", "wins", "losses", "ties", "points",
        "bio", "word_count", "model"
    ]
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)


def build_history(base: Path) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
    matches_rows = read_csv(base / "matches.csv")
    parts_rows = read_csv(base / "match_participants.csv")
    summaries_rows = read_csv(base / "match_summaries_gpt52_150_200.csv") if (base / "match_summaries_gpt52_150_200.csv").exists() else read_csv(base / "match_summaries_gpt52.csv")

    matches = {r["match_uid"]: r for r in matches_rows}
    summaries = {r["match_uid"]: r for r in summaries_rows}
    participants_by_match: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    for r in parts_rows:
        participants_by_match[r["match_uid"]].append(r)

    player_rows: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    for r in parts_rows:
        player_rows[r["player_name"]].append(r)

    profiles: List[Dict[str, Any]] = []

    for player_name in sorted(player_rows.keys()):
        participations = player_rows[player_name]
        team_counts = Counter(norm(r["team"]) for r in participations)
        team = team_counts.most_common(1)[0][0] if team_counts else ""
        first_name = norm(participations[0].get("first_name")) if participations else ""
        last_name = norm(participations[0].get("last_name")) if participations else ""

        match_ids = sorted(
            {r["match_uid"] for r in participations},
            key=lambda mid: (
                to_int(matches[mid].get("year")),
                to_int(matches[mid].get("round")),
                to_int(matches[mid].get("match")),
                to_int(matches[mid].get("matchgroup")),
            ),
        )

        overall = {"matches": 0, "wins": 0, "losses": 0, "ties": 0, "points": 0.0}
        years = set()
        format_stats: Dict[str, Dict[str, Any]] = defaultdict(lambda: {"matches":0,"wins":0,"losses":0,"ties":0,"points":0.0})
        year_stats: Dict[str, Dict[str, Any]] = defaultdict(lambda: {"matches":0,"wins":0,"losses":0,"ties":0,"points":0.0})
        partners: Dict[str, Dict[str, Any]] = defaultdict(lambda: {"matches":0,"wins":0,"losses":0,"ties":0,"points":0.0, "formats": Counter()})
        opponents: Dict[str, Dict[str, Any]] = defaultdict(lambda: {"matches":0,"wins":0,"losses":0,"ties":0,"points":0.0, "formats": Counter()})
        all_matches_detail: List[Dict[str, Any]] = []
        hcap_samples: List[Dict[str, Any]] = []

        for mid in match_ids:
            m = matches[mid]
            match_parts = participants_by_match[mid]
            my_rows = [r for r in match_parts if norm(r["player_name"]) == player_name]
            if not my_rows:
                continue
            my_row = my_rows[0]
            my_team = norm(my_row["team"])
            winner = norm(m.get("winner"))
            pts_val = to_float(m.get("points"))
            if winner == my_team:
                result = "Win"
                pts_earned = pts_val
            elif winner == "Tie":
                result = "Tie"
                pts_earned = pts_val
            else:
                result = "Loss"
                pts_earned = 0.0

            overall["matches"] += 1
            overall["points"] += pts_earned
            years.add(norm(m.get("year")))
            if result == "Win": overall["wins"] += 1
            elif result == "Loss": overall["losses"] += 1
            else: overall["ties"] += 1

            fmt = norm(m.get("format_display"))
            fs = format_stats[fmt]
            ys = year_stats[norm(m.get("year"))]
            for s in (fs, ys):
                s["matches"] += 1
                s["points"] += pts_earned
                if result == "Win": s["wins"] += 1
                elif result == "Loss": s["losses"] += 1
                else: s["ties"] += 1

            my_side = [r for r in match_parts if norm(r["team"]) == my_team]
            opp_side = [r for r in match_parts if norm(r["team"]) != my_team]
            teammate_names = [norm(r["player_name"]) for r in my_side if norm(r["player_name"]) != player_name]
            opponent_names = [norm(r["player_name"]) for r in opp_side]

            for p in teammate_names:
                ps = partners[p]
                ps["matches"] += 1
                ps["points"] += pts_earned
                ps["formats"][fmt] += 1
                if result == "Win": ps["wins"] += 1
                elif result == "Loss": ps["losses"] += 1
                else: ps["ties"] += 1

            for opp in opponent_names:
                os_ = opponents[opp]
                os_["matches"] += 1
                os_["points"] += pts_earned
                os_["formats"][fmt] += 1
                if result == "Win": os_["wins"] += 1
                elif result == "Loss": os_["losses"] += 1
                else: os_["ties"] += 1

            hcap_samples.append({
                "year": norm(my_row.get("year")),
                "format": fmt,
                "handicap_index": norm(my_row.get("handicap_index")),
                "course_handicap_full": norm(my_row.get("course_handicap_full")),
                "match_strokes_used": norm(my_row.get("match_strokes_used")),
            })

            all_matches_detail.append({
                "match_uid": mid,
                "year": norm(m.get("year")),
                "round": norm(m.get("round")),
                "match": norm(m.get("match")),
                "matchgroup": norm(m.get("matchgroup")),
                "format": fmt,
                "result": result,
                "score": norm(m.get("score")),
                "points_earned": round(pts_earned, 2),
                "winner": winner,
                "location": norm(m.get("location")),
                "course": norm(m.get("course")),
                "teammates": teammate_names,
                "opponents": opponent_names,
                "summary": norm((summaries.get(mid) or {}).get("summary")),
                "margin": score_margin(norm(m.get("score"))),
            })

        # aggregate lists for GPT input
        format_rows = []
        for fmt, s in format_stats.items():
            format_rows.append({
                "format": fmt,
                "matches": s["matches"],
                "record": f"{s['wins']}-{s['losses']}-{s['ties']}",
                "points": round(s["points"], 2),
                "win_pct": pct(s["wins"], s["ties"], s["matches"]),
                "win_tie_pct": points_pct(s["wins"], s["ties"], s["matches"]),
            })
        format_rows.sort(key=lambda r: (-r["points"], -r["win_pct"], -r["matches"], r["format"]))

        year_rows = []
        for yr, s in year_stats.items():
            year_rows.append({
                "year": yr,
                "matches": s["matches"],
                "record": f"{s['wins']}-{s['losses']}-{s['ties']}",
                "points": round(s["points"], 2),
                "win_pct": pct(s["wins"], s["ties"], s["matches"]),
            })
        year_rows.sort(key=lambda r: (-r["points"], -r["win_pct"], -r["matches"], r["year"]))

        partner_rows = []
        for partner, s in partners.items():
            if not norm(partner):
                continue
            top_formats = [f for f, _ in s["formats"].most_common(3)]
            partner_rows.append({
                "partner": partner,
                "matches": s["matches"],
                "record": f"{s['wins']}-{s['losses']}-{s['ties']}",
                "points": round(s["points"], 2),
                "win_pct": pct(s["wins"], s["ties"], s["matches"]),
                "common_formats": top_formats,
            })
        partner_rows.sort(key=lambda r: (-r["matches"], -r["points"], -r["win_pct"], r["partner"]))

        opponent_rows = []
        for opp, s in opponents.items():
            top_formats = [f for f, _ in s["formats"].most_common(3)]
            opponent_rows.append({
                "opponent": opp,
                "matches": s["matches"],
                "record": f"{s['wins']}-{s['losses']}-{s['ties']}",
                "points": round(s["points"], 2),
                "win_pct": pct(s["wins"], s["ties"], s["matches"]),
                "common_formats": top_formats,
            })
        opponent_rows.sort(key=lambda r: (-r["matches"], r["win_pct"], -r["points"], r["opponent"]))

        wins = [m for m in all_matches_detail if m["result"] == "Win"]
        losses = [m for m in all_matches_detail if m["result"] == "Loss"]
        ties = [m for m in all_matches_detail if m["result"] == "Tie"]
        wins.sort(key=lambda m: (-m["points_earned"], -m["margin"], -to_int(m["year"]), -to_int(m["round"]), -to_int(m["match"])))
        losses.sort(key=lambda m: (-m["margin"], -to_int(m["year"]), -to_int(m["round"]), -to_int(m["match"])))

        # Most dramatic swings / best matches via summary presence and closeness/margin
        notable_wins = [
            {
                "match_uid": m["match_uid"],
                "year": m["year"],
                "round": m["round"],
                "match": m["match"],
                "format": m["format"],
                "score": m["score"],
                "opponents": m["opponents"],
                "teammates": m["teammates"],
                "summary_excerpt": (m["summary"][:260] + "...") if len(m["summary"]) > 260 else m["summary"],
            }
            for m in wins[:5]
        ]
        tough_losses = [
            {
                "match_uid": m["match_uid"],
                "year": m["year"],
                "round": m["round"],
                "match": m["match"],
                "format": m["format"],
                "score": m["score"],
                "opponents": m["opponents"],
                "teammates": m["teammates"],
                "summary_excerpt": (m["summary"][:220] + "...") if len(m["summary"]) > 220 else m["summary"],
            }
            for m in losses[:3]
        ]

        # best tournament(s) by points then win pct
        best_years = year_rows[:5]
        strongest_formats = [r for r in format_rows if r["matches"] >= 2][:5] or format_rows[:5]

        # handicap trend snapshot
        hcap_numeric = [to_float(x["handicap_index"], None) for x in hcap_samples if norm(x.get("handicap_index")) != ""]
        hcap_numeric = [x for x in hcap_numeric if isinstance(x, (int, float))]
        handicap_snapshot = {}
        if hcap_numeric:
            handicap_snapshot = {
                "avg_handicap_index": round(sum(hcap_numeric) / len(hcap_numeric), 1),
                "min_handicap_index": round(min(hcap_numeric), 1),
                "max_handicap_index": round(max(hcap_numeric), 1),
            }

        profiles.append({
            "player_name": player_name,
            "team": team,
            "first_name": first_name,
            "last_name": last_name,
            "career": {
                "matches": overall["matches"],
                "record": f"{overall['wins']}-{overall['losses']}-{overall['ties']}",
                "wins": overall["wins"],
                "losses": overall["losses"],
                "ties": overall["ties"],
                "points": round(overall["points"], 2),
                "win_pct": pct(overall["wins"], overall["ties"], overall["matches"]),
                "win_tie_pct": points_pct(overall["wins"], overall["ties"], overall["matches"]),
                "years_played": sorted([y for y in years if y]),
                "tournaments_played": len(years),
            },
            "handicap_snapshot": handicap_snapshot,
            "strongest_formats": strongest_formats,
            "format_stats_all": format_rows,
            "best_tournaments": best_years,
            "year_stats_all": year_rows,
            "common_partners": partner_rows[:8],
            "rivalries": opponent_rows[:10],
            "best_matches": notable_wins,
            "toughest_losses": tough_losses,
            "career_match_count": overall["matches"],
            "career_points": round(overall["points"], 2),
            "career_wins": overall["wins"],
            "career_losses": overall["losses"],
            "career_ties": overall["ties"],
        })

    profiles.sort(key=lambda p: (-p["career_match_count"], p["team"], p["player_name"]))
    return profiles, {"matches": matches, "participants_by_match": participants_by_match}


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate player bios with OpenAI from Bluff City Cup history exports.")
    parser.add_argument("--base", type=Path, default=BASE)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--cache", type=Path, default=DEFAULT_CACHE)
    parser.add_argument("--model", default="gpt-5.2")
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--sleep", type=float, default=0.2)
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    profiles, _ctx = build_history(args.base)
    if args.limit and args.limit > 0:
        profiles = profiles[:args.limit]

    cache = load_cache(args.cache) if args.resume else {}
    api_key = os.environ.get("OPENAI_API_KEY", "").strip()
    if not args.dry_run and not api_key:
        print("OPENAI_API_KEY is not set. Set it and rerun, or use --dry-run.", file=sys.stderr)
        return 2

    output_rows: List[Dict[str, str]] = []
    failures: List[str] = []

    for idx, profile in enumerate(profiles, start=1):
        player_name = profile["player_name"]
        if args.resume and player_name in cache and norm(cache[player_name].get("bio")):
            cached = cache[player_name]
            output_rows.append({
                "player_name": player_name,
                "team": profile["team"],
                "first_name": profile["first_name"],
                "last_name": profile["last_name"],
                "career_matches": str(profile["career_match_count"]),
                "wins": str(profile["career_wins"]),
                "losses": str(profile["career_losses"]),
                "ties": str(profile["career_ties"]),
                "points": str(profile["career_points"]),
                "bio": norm(cached.get("bio")),
                "word_count": str(len(norm(cached.get("bio")).split())),
                "model": norm(cached.get("model")) or args.model,
            })
            print(f"[{idx}/{len(profiles)}] resume {player_name}")
            continue

        # Keep input compact but rich
        prompt_input = {
            "player": {
                "name": profile["player_name"],
                "team": profile["team"],
                "first_name": profile["first_name"],
                "last_name": profile["last_name"],
            },
            "career": profile["career"],
            "handicap_snapshot": profile["handicap_snapshot"],
            "strongest_formats": profile["strongest_formats"],
            "best_tournaments": profile["best_tournaments"],
            "common_partners": profile["common_partners"],
            "rivalries": profile["rivalries"],
            "best_matches": profile["best_matches"],
            "toughest_losses": profile["toughest_losses"],
        }

        if args.dry_run:
            bio = f"DRY RUN for {player_name}"
        else:
            try:
                bio = call_openai(args.model, api_key, BIO_PROMPT, prompt_input)
                bio = sanitize_summary(bio)
            except urllib.error.HTTPError as e:
                err = e.read().decode("utf-8", errors="replace")
                failures.append(player_name)
                print(f"[{idx}/{len(profiles)}] ERROR {player_name} HTTP {e.code}: {err[:500]}", file=sys.stderr)
                continue
            except Exception as e:
                failures.append(player_name)
                print(f"[{idx}/{len(profiles)}] ERROR {player_name}: {e}", file=sys.stderr)
                continue

        row = {
            "player_name": player_name,
            "team": profile["team"],
            "first_name": profile["first_name"],
            "last_name": profile["last_name"],
            "career_matches": str(profile["career_match_count"]),
            "wins": str(profile["career_wins"]),
            "losses": str(profile["career_losses"]),
            "ties": str(profile["career_ties"]),
            "points": str(profile["career_points"]),
            "bio": bio,
            "word_count": str(len(bio.split())),
            "model": args.model,
        }
        output_rows.append(row)
        append_cache(args.cache, row)
        print(f"[{idx}/{len(profiles)}] ok {player_name} ({row['word_count']} words)")
        if not args.dry_run and args.sleep > 0:
            time.sleep(args.sleep)

    out_by_name = {r["player_name"]: r for r in output_rows}
    ordered = [out_by_name[p["player_name"]] for p in profiles if p["player_name"] in out_by_name]
    write_csv(args.out, ordered)
    print(f"Wrote {len(ordered)} bios to {args.out}")
    if failures:
        print(f"Failures: {len(failures)}", file=sys.stderr)
        for name in failures:
            print(f" - {name}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
