#!/usr/bin/env python3
import argparse
import csv
import json
import os
import sys
import time
import urllib.error
import urllib.request
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Any


BASE = Path("/Users/rossmon/Developer/bluffcitycup/History Website/bluffcitycup/data_exports/match_detail_datasets")
DEFAULT_OUT = BASE / "match_summaries_gpt52.csv"
DEFAULT_CACHE = BASE / "match_summaries_gpt52_cache.jsonl"


SUMMARY_PROMPT = """You are a golf match analyst writing a compelling narrative summary of a match using structured dataset inputs.

You will be provided the below and more:
• Match format (Singles, Best Ball, etc.)
• Player names and teams and course handicaps
• Course information
• Hole-by-hole net (handicap-adjusted) scores
• Hole details, including handicaps (stroke index) yardage
• Final result
• Win probability by hole

Your task is to write a 150–200 word narrative match summary.

Guidelines:
1. Write in clean paragraph form (no bullet points, no headings).
2. Do not restate metadata like year, tees, yardage, or location unless it adds insight.
3. Analyze the match using net performance relative to course handicaps.
4. Identify pivotal holes or stretches where momentum shifted.
5. Incorporate win probability trends only if they add insight (e.g., major swings, lock territory, late collapse, comeback attempt).
6. Highlight why the match was decided (e.g., one player maximizing strokes, a front-nine collapse, mid-round surge, inability to convert strokes).
7. Keep the tone sharp and confident, like a post-match recap.
8. Light competitive digs are allowed if they are supported by the data, but avoid exaggeration.
9. Avoid generic commentary — ground all insights in the provided scoring data.

The summary should feel analytical but natural, as if written by someone who understands match play strategy, handicap leverage, and momentum dynamics.

Only use information contained in the dataset. Do not invent details.

Return only the summary paragraph."""


def norm(v: Any) -> str:
    return "" if v is None else str(v).strip()


def read_csv(path: Path) -> List[Dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def group_by(rows: List[Dict[str, str]], key: str) -> Dict[str, List[Dict[str, str]]]:
    out: Dict[str, List[Dict[str, str]]] = defaultdict(list)
    for r in rows:
        out[r[key]].append(r)
    return out


def load_dataset_package(base: Path) -> Dict[str, Any]:
    data = {
        "matches": read_csv(base / "matches.csv"),
        "participants": read_csv(base / "match_participants.csv"),
        "team_hcps": read_csv(base / "match_team_handicaps.csv"),
        "holes": read_csv(base / "match_holes.csv"),
        "popup_rows": read_csv(base / "match_hole_popup_rows.csv"),
        "prob_chart": read_csv(base / "match_probabilities_chart.csv"),
        "prob_summary": read_csv(base / "match_probabilities_summary.csv"),
        "issues": read_csv(base / "data_quality_issues.csv"),
    }
    data["by"] = {
        "participants": group_by(data["participants"], "match_uid"),
        "team_hcps": group_by(data["team_hcps"], "match_uid"),
        "holes": group_by(data["holes"], "match_uid"),
        "popup_rows": group_by(data["popup_rows"], "match_uid"),
        "prob_chart": group_by(data["prob_chart"], "match_uid"),
        "prob_summary": group_by(data["prob_summary"], "match_uid"),
        "issues": group_by(data["issues"], "match_uid"),
    }
    return data


def sort_int(rows: List[Dict[str, str]], key: str) -> List[Dict[str, str]]:
    def k(r):
        try:
            return int(float(norm(r.get(key))))
        except Exception:
            return 10**9
    return sorted(rows, key=k)


def compact_record(r: Dict[str, str], keys: List[str]) -> Dict[str, str]:
    return {k: norm(r.get(k)) for k in keys if norm(r.get(k)) != ""}


def build_match_input(match: Dict[str, str], data: Dict[str, Any]) -> Dict[str, Any]:
    mid = match["match_uid"]
    by = data["by"]

    participants = sort_int(by["participants"].get(mid, []), "slot")
    team_hcps = sorted(by["team_hcps"].get(mid, []), key=lambda r: (norm(r.get("team")), norm(r.get("players"))))
    holes = sort_int(by["holes"].get(mid, []), "relative_hole")
    popup_rows = by["popup_rows"].get(mid, [])
    popup_rows = sorted(
        popup_rows,
        key=lambda r: (
            int(float(norm(r.get("relative_hole") or "999"))),
            int(float(norm(r.get("row_order") or "999"))),
        ),
    )
    prob_chart = sort_int(by["prob_chart"].get(mid, []), "point_order")
    prob_summary_rows = by["prob_summary"].get(mid, [])
    issues = by["issues"].get(mid, [])

    # Build compact nested structure
    out = {
        "match": compact_record(match, [
            "match_uid", "year", "round", "match", "matchgroup",
            "format_display", "format_app", "winner", "score", "points",
            "location", "course", "tees", "matchlength", "startinghole", "endinghole",
            "course_slope", "course_rating", "course_par", "tournament_maxhandicap",
            "red_players", "blue_players"
        ]),
        "participants": [
            compact_record(r, [
                "team", "slot", "player_name", "handicap_index",
                "course_handicap_full", "course_handicap_shamble", "course_handicap_slope_only",
                "match_strokes_used"
            ])
            for r in participants
        ],
        "team_handicaps": [
            compact_record(r, [
                "team", "team_handicap_method", "team_course_handicap_raw",
                "team_match_strokes_relative", "players"
            ])
            for r in team_hcps
        ],
        "holes": [
            compact_record(r, [
                "hole", "relative_hole", "hole_handicap", "par", "yards",
                "red_team_actual", "blue_team_actual", "red_team_net", "blue_team_net",
                "hole_winner_actual", "hole_winner_net",
                "score_diff_before_hole", "score_diff_after_hole", "hole_played"
            ])
            for r in holes
        ],
        "popup_scorecard_rows": [
            compact_record(r, [
                "hole", "relative_hole", "row_order", "row_team", "row_kind",
                "row_label", "row_member_names", "actual_score", "net_score", "popup_highlight"
            ])
            for r in popup_rows
        ],
        "win_probability_by_hole": [
            compact_record(r, [
                "point_order", "hole", "relative_hole", "score_diff_before_hole",
                "blue_win_prob_pct", "tie_prob_pct", "red_win_prob_pct"
            ])
            for r in prob_chart
        ],
        "win_probability_summary": compact_record(prob_summary_rows[0], [
            "blue_win_prob_pct", "tie_prob_pct", "red_win_prob_pct", "summary_mode"
        ]) if prob_summary_rows else {},
        "data_quality_issues": [
            compact_record(r, ["hole", "format", "issue"]) for r in issues
        ],
    }
    return out


def extract_response_text(payload: Dict[str, Any]) -> str:
    # Responses API often returns output_text via SDK; raw HTTP may require traversing output.
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


def call_openai(model: str, api_key: str, prompt: str, match_input: Dict[str, Any], timeout: int = 120) -> str:
    body = {
        "model": model,
        "input": [
            {
                "role": "system",
                "content": [{"type": "input_text", "text": prompt}],
            },
            {
                "role": "user",
                "content": [{"type": "input_text", "text": json.dumps(match_input, separators=(",", ":"), ensure_ascii=True)}],
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


def sanitize_summary(text: str) -> str:
    return " ".join(norm(text).split())


def load_cache(cache_path: Path) -> Dict[str, Dict[str, str]]:
    cache: Dict[str, Dict[str, str]] = {}
    if not cache_path.exists():
        return cache
    with cache_path.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                row = json.loads(line)
                mid = row.get("match_uid")
                if mid:
                    cache[mid] = row
            except Exception:
                continue
    return cache


def append_cache(cache_path: Path, row: Dict[str, Any]) -> None:
    cache_path.parent.mkdir(parents=True, exist_ok=True)
    with cache_path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(row, ensure_ascii=False) + "\n")


def write_output_csv(out_path: Path, rows: List[Dict[str, str]]) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = ["match_uid", "year", "round", "match", "matchgroup", "format", "summary", "word_count", "model"]
    with out_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(rows)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate match summaries with OpenAI from exported match detail datasets.")
    parser.add_argument("--base", type=Path, default=BASE)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    parser.add_argument("--cache", type=Path, default=DEFAULT_CACHE)
    parser.add_argument("--model", default="gpt-5.2")
    parser.add_argument("--limit", type=int, default=0, help="Process only the first N matches (0 = all)")
    parser.add_argument("--sleep", type=float, default=0.2, help="Seconds between requests")
    parser.add_argument("--resume", action="store_true", help="Skip matches already in cache")
    parser.add_argument("--dry-run", action="store_true", help="Write prompt input previews only (no API calls)")
    args = parser.parse_args()

    data = load_dataset_package(args.base)
    matches = sorted(
        data["matches"],
        key=lambda r: (
            int(float(norm(r["year"]) or 0)),
            int(float(norm(r["round"]) or 0)),
            int(float(norm(r["match"]) or 0)),
            int(float(norm(r.get("matchgroup") or 0) or 0)),
        ),
    )
    if args.limit and args.limit > 0:
        matches = matches[: args.limit]

    cache = load_cache(args.cache) if args.resume else {}
    api_key = os.environ.get("OPENAI_API_KEY", "").strip()
    if not args.dry_run and not api_key:
        print("OPENAI_API_KEY is not set. Set it and rerun, or use --dry-run.", file=sys.stderr)
        return 2

    output_rows: List[Dict[str, str]] = []
    failures: List[str] = []

    for idx, match in enumerate(matches, start=1):
        match_uid = match["match_uid"]
        if args.resume and match_uid in cache and norm(cache[match_uid].get("summary")):
            cached = cache[match_uid]
            output_rows.append({
                "match_uid": match_uid,
                "year": norm(match["year"]),
                "round": norm(match["round"]),
                "match": norm(match["match"]),
                "matchgroup": norm(match.get("matchgroup")),
                "format": norm(match.get("format_display")),
                "summary": norm(cached.get("summary")),
                "word_count": str(len(norm(cached.get("summary")).split())),
                "model": norm(cached.get("model")) or args.model,
            })
            print(f"[{idx}/{len(matches)}] resume {match_uid}")
            continue

        match_input = build_match_input(match, data)
        if args.dry_run:
            summary = f"DRY RUN for {match_uid}"
        else:
            try:
                summary = call_openai(args.model, api_key, SUMMARY_PROMPT, match_input)
                summary = sanitize_summary(summary)
            except urllib.error.HTTPError as e:
                err = e.read().decode("utf-8", errors="replace")
                failures.append(match_uid)
                print(f"[{idx}/{len(matches)}] ERROR {match_uid} HTTP {e.code}: {err[:500]}", file=sys.stderr)
                continue
            except Exception as e:
                failures.append(match_uid)
                print(f"[{idx}/{len(matches)}] ERROR {match_uid}: {e}", file=sys.stderr)
                continue

        row = {
            "match_uid": match_uid,
            "year": norm(match["year"]),
            "round": norm(match["round"]),
            "match": norm(match["match"]),
            "matchgroup": norm(match.get("matchgroup")),
            "format": norm(match.get("format_display")),
            "summary": summary,
            "word_count": str(len(summary.split())),
            "model": args.model,
        }
        output_rows.append(row)
        append_cache(args.cache, row)
        print(f"[{idx}/{len(matches)}] ok {match_uid} ({row['word_count']} words)")
        if not args.dry_run and args.sleep > 0:
            time.sleep(args.sleep)

    # Preserve sorted order of requested matches
    out_by_id = {r["match_uid"]: r for r in output_rows}
    ordered = [out_by_id[m["match_uid"]] for m in matches if m["match_uid"] in out_by_id]
    write_output_csv(args.out, ordered)

    print(f"Wrote {len(ordered)} summaries to {args.out}")
    if failures:
        print(f"Failures: {len(failures)}", file=sys.stderr)
        for mid in failures[:20]:
            print(f" - {mid}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
