#!/usr/bin/env python3
import csv
import math
from collections import Counter, defaultdict
from pathlib import Path
from statistics import mean


BASE = Path("/Users/rossmon/Developer/bluffcitycup/History Website/bluffcitycup/data_exports/match_detail_datasets")
OUT = BASE / "match_summaries.csv"


def norm(v):
    return "" if v is None else str(v).strip()


def i(v):
    s = norm(v)
    if s == "":
        return None
    try:
        return int(float(s))
    except Exception:
        return None


def f(v):
    s = norm(v)
    if s == "":
        return None
    try:
        return float(s)
    except Exception:
        return None


def words(text):
    return len([w for w in text.replace("\n", " ").split(" ") if w])


def stroke_count(match_strokes, hole_hcp):
    if match_strokes is None or hole_hcp is None:
        return 0
    if match_strokes >= 36:
        return 3 if (match_strokes - 36) >= hole_hcp else 2
    if match_strokes >= 18:
        return 2 if (match_strokes - 18) >= hole_hcp else 1
    return 1 if match_strokes >= hole_hcp else 0


def team_side_text(players):
    names = [p["player_name"] for p in sorted(players, key=lambda r: int(r["slot"]))]
    if not names:
        return "that side"
    if len(names) == 1:
        return names[0]
    if len(names) == 2:
        return f"{names[0]} and {names[1]}"
    return ", ".join(names[:-1]) + f", and {names[-1]}"


def format_label(fmt):
    return fmt or "Match"


def winner_label(w):
    if w == "Red":
        return "Red"
    if w == "Blue":
        return "Blue"
    if w == "Tie":
        return "Tie"
    return "Unknown"


def parse_score_text(score_text):
    s = norm(score_text)
    if not s:
        return {"type": "unknown", "raw": ""}
    if "UP" in s.upper():
        return {"type": "up", "margin": s, "raw": s}
    if "&" in s:
        return {"type": "and", "margin": s, "raw": s}
    if s.lower() == "tie":
        return {"type": "tie", "margin": "Tie", "raw": s}
    return {"type": "raw", "margin": s, "raw": s}


def read_csv(path):
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def load_data():
    return {
        "matches": read_csv(BASE / "matches.csv"),
        "participants": read_csv(BASE / "match_participants.csv"),
        "team_hcps": read_csv(BASE / "match_team_handicaps.csv"),
        "holes": read_csv(BASE / "match_holes.csv"),
        "popup_rows": read_csv(BASE / "match_hole_popup_rows.csv"),
        "prob_chart": read_csv(BASE / "match_probabilities_chart.csv"),
        "prob_summary": read_csv(BASE / "match_probabilities_summary.csv"),
        "issues": read_csv(BASE / "data_quality_issues.csv"),
    }


def group_by(rows, key):
    d = defaultdict(list)
    for r in rows:
        d[r[key]].append(r)
    return d


def sign(x):
    if x is None:
        return 0
    if x > 0:
        return 1
    if x < 0:
        return -1
    return 0


def summarize_match(match, participants, team_hcps, holes, popup_rows, prob_chart, prob_summary, issues):
    year = norm(match["year"])
    round_no = norm(match["round"])
    match_no = norm(match["match"])
    match_uid = norm(match["match_uid"])
    fmt = norm(match["format_display"])
    winner = norm(match["winner"])
    score_text = norm(match["score"])
    score_parsed = parse_score_text(score_text)

    red_players = [p for p in participants if norm(p["team"]) == "Red"]
    blue_players = [p for p in participants if norm(p["team"]) == "Blue"]
    red_names = team_side_text(red_players)
    blue_names = team_side_text(blue_players)

    holes_sorted = sorted(
        [h for h in holes if norm(h.get("hole_played")) == "1"],
        key=lambda r: (i(r.get("relative_hole")) or 999, i(r.get("hole")) or 999),
    )
    probs_sorted = sorted(prob_chart, key=lambda r: i(r.get("point_order")) or 999)
    prob_sum = prob_summary[0] if prob_summary else None
    issue_counts = Counter([norm(r["issue"]) for r in issues])

    # Handicap setup text
    red_team_hcp = next((r for r in team_hcps if norm(r["team"]) == "Red"), None)
    blue_team_hcp = next((r for r in team_hcps if norm(r["team"]) == "Blue"), None)
    handicap_mode = norm((red_team_hcp or {}).get("team_handicap_method"))

    red_participant_bits = []
    for p in sorted(red_players, key=lambda r: int(r["slot"])):
        ch = norm(p.get("course_handicap_full"))
        ms = norm(p.get("match_strokes_used"))
        if ms != "":
            red_participant_bits.append(f"{norm(p['last_name'])} ({ch} ch, {ms} strokes)")
        elif ch != "":
            red_participant_bits.append(f"{norm(p['last_name'])} ({ch} ch)")
        else:
            red_participant_bits.append(norm(p["last_name"]))

    blue_participant_bits = []
    for p in sorted(blue_players, key=lambda r: int(r["slot"])):
        ch = norm(p.get("course_handicap_full"))
        ms = norm(p.get("match_strokes_used"))
        if ms != "":
            blue_participant_bits.append(f"{norm(p['last_name'])} ({ch} ch, {ms} strokes)")
        elif ch != "":
            blue_participant_bits.append(f"{norm(p['last_name'])} ({ch} ch)")
        else:
            blue_participant_bits.append(norm(p["last_name"]))

    # Hole-level match shape
    hole_winners_net = [norm(h.get("hole_winner_net")) for h in holes_sorted]
    hole_nums = [i(h.get("hole")) for h in holes_sorted]
    red_net_wins = sum(1 for w in hole_winners_net if w == "Red")
    blue_net_wins = sum(1 for w in hole_winners_net if w == "Blue")
    halved = sum(1 for w in hole_winners_net if w == "AS")

    net_flip_holes = []
    for h in holes_sorted:
        actual_w = norm(h.get("hole_winner_actual"))
        net_w = norm(h.get("hole_winner_net"))
        hole = i(h.get("hole"))
        if actual_w and net_w and actual_w != net_w:
            net_flip_holes.append(hole)

    # Lead changes and pivotal stretches using score diff after hole (Blue-Red)
    diffs_after = [i(h.get("score_diff_after_hole")) for h in holes_sorted]
    diffs_before = [i(h.get("score_diff_before_hole")) for h in holes_sorted]
    leader_after = [sign(d) for d in diffs_after]
    lead_changes = 0
    prev_non_zero = None
    for sgn in leader_after:
        if sgn == 0:
            continue
        if prev_non_zero is None:
            prev_non_zero = sgn
            continue
        if sgn != prev_non_zero:
            lead_changes += 1
            prev_non_zero = sgn

    # Streaks
    longest_streak = {"team": "AS", "length": 0, "start": None, "end": None}
    cur_team = None
    cur_len = 0
    cur_start = None
    for hnum, w in zip(hole_nums, hole_winners_net):
        if w not in ("Red", "Blue"):
            cur_team, cur_len, cur_start = None, 0, None
            continue
        if w == cur_team:
            cur_len += 1
        else:
            cur_team, cur_len, cur_start = w, 1, hnum
        if cur_len > longest_streak["length"]:
            longest_streak = {"team": w, "length": cur_len, "start": cur_start, "end": hnum}

    # Probability trend analysis
    winner_prob_key = "red_win_prob_pct" if winner == "Red" else "blue_win_prob_pct" if winner == "Blue" else "tie_prob_pct"
    prob_points = []
    for p in probs_sorted:
        hole = i(p.get("hole"))
        wp = f(p.get(winner_prob_key)) if winner_prob_key else None
        bluep = f(p.get("blue_win_prob_pct"))
        redp = f(p.get("red_win_prob_pct"))
        tiev = f(p.get("tie_prob_pct"))
        if hole is None:
            continue
        prob_points.append({
            "hole": hole,
            "winner_prob": wp,
            "blue": bluep,
            "red": redp,
            "tie": tiev,
        })

    major_swing = None
    if len(prob_points) >= 2 and winner_prob_key:
        swings = []
        for prev, curr in zip(prob_points, prob_points[1:]):
            if prev["winner_prob"] is None or curr["winner_prob"] is None:
                continue
            swings.append({
                "from_hole": prev["hole"],
                "to_hole": curr["hole"],
                "delta": curr["winner_prob"] - prev["winner_prob"],
                "from": prev["winner_prob"],
                "to": curr["winner_prob"],
            })
        if swings:
            major_swing = max(swings, key=lambda s: abs(s["delta"]))

    max_winner_prob = None
    min_winner_prob = None
    if prob_points and winner_prob_key:
        vals = [p["winner_prob"] for p in prob_points if p["winner_prob"] is not None]
        if vals:
            max_winner_prob = max(vals)
            min_winner_prob = min(vals)

    # Handicap leverage detail
    stroke_hole_counts = {"Red": 0, "Blue": 0}
    stroke_hole_net_wins = {"Red": 0, "Blue": 0}
    for h in holes_sorted:
        hh = i(h.get("hole_handicap"))
        hole = i(h.get("hole"))
        net_w = norm(h.get("hole_winner_net"))
        if hh is None or hole is None:
            continue
        for team, plist in (("Red", red_players), ("Blue", blue_players)):
            received = False
            if fmt in ("Singles", "Best Ball", "Shamble"):
                for p in plist:
                    ms = i(p.get("match_strokes_used"))
                    if stroke_count(ms, hh) > 0:
                        received = True
                        break
            else:
                team_row = next((r for r in team_hcps if norm(r["team"]) == team), None)
                ms = i((team_row or {}).get("team_match_strokes_relative"))
                if stroke_count(ms, hh) > 0:
                    received = True
            if received:
                stroke_hole_counts[team] += 1
                if net_w == team:
                    stroke_hole_net_wins[team] += 1

    # Popup row contributors (best ball/shamble/singles mostly)
    popup_rows_sorted = sorted(
        popup_rows,
        key=lambda r: (i(r.get("hole")) or 999, i(r.get("row_order")) or 999)
    )
    highlight_counts = Counter()
    for r in popup_rows_sorted:
        if norm(r.get("popup_highlight")) == "1":
            highlight_counts[norm(r.get("row_label"))] += 1
    top_highlights = highlight_counts.most_common(2)

    # Build narrative sentences
    opening = []
    if winner == "Tie":
        opening.append(
            f"This {format_label(fmt)} match between Red ({red_names}) and Blue ({blue_names}) finished all square ({score_text or 'Tie'}), and the net scoring data shows why neither side could create a clean separation."
        )
    else:
        opening.append(
            f"Red ({red_names}) and Blue ({blue_names}) played a {format_label(fmt)} match that ended {score_text}, with {winner} getting the point after a net-scoring battle that was decided by a few high-leverage holes rather than a clean sweep."
        )

    if red_participant_bits or blue_participant_bits:
        handicap_sentence = (
            f"The handicap setup mattered immediately: Red came in as {', '.join(red_participant_bits)} while Blue countered with {', '.join(blue_participant_bits)}."
        )
    else:
        handicap_sentence = "The available data supports a net-score read of the match, but some participant handicap details are incomplete."

    if handicap_mode and handicap_mode != "unsupported_format":
        handicap_sentence += (
            f" In this format, the popup logic applies {handicap_mode.replace('_', ' ')} before comparing hole-by-hole net scores against the stroke index."
        )

    if holes_sorted:
        early = holes_sorted[: min(3, len(holes_sorted))]
        early_desc = []
        for h in early:
            hn = norm(h["hole"])
            w = norm(h["hole_winner_net"])
            if w == "AS":
                early_desc.append(f"hole {hn} was halved")
            else:
                early_desc.append(f"{w} took hole {hn}")
        flow_early = f"Early shape: {', '.join(early_desc)}."
    else:
        flow_early = "Hole-by-hole scoring is incomplete for this match, so the sequence-level analysis is limited."

    mid_sentence_parts = []
    if longest_streak["length"] >= 2:
        mid_sentence_parts.append(
            f"The biggest uninterrupted run was a {longest_streak['length']}-hole stretch for {longest_streak['team']} from hole {longest_streak['start']} through {longest_streak['end']}."
        )
    if lead_changes:
        mid_sentence_parts.append(f"The lead changed hands {lead_changes} time{'s' if lead_changes != 1 else ''}, which kept the net match state live deeper into the round than the final score alone suggests.")
    elif holes_sorted:
        mid_sentence_parts.append("There were no true lead changes once the match tilted, which points to sustained control rather than a late scramble.")
    if not mid_sentence_parts:
        mid_sentence_parts.append("The available sequence data is too thin to isolate a full momentum map, but the net hole winners still align with the posted result.")
    mid_sentence = " ".join(mid_sentence_parts)

    leverage_parts = []
    if net_flip_holes:
        flip_list = ", ".join(str(h) for h in net_flip_holes[:6])
        if len(net_flip_holes) > 6:
            flip_list += ", ..."
        leverage_parts.append(
            f"Handicap leverage changed the hole outcome on {len(net_flip_holes)} hole{'s' if len(net_flip_holes) != 1 else ''} when comparing actual to net scoring (notably {flip_list})."
        )
    else:
        leverage_parts.append("There was little daylight between actual and net hole winners, so the result came more from raw scoring than handicap reversal.")

    if stroke_hole_counts["Red"] or stroke_hole_counts["Blue"]:
        leverage_parts.append(
            f"Stroke allocation showed up in the conversion rates: Red won {stroke_hole_net_wins['Red']} of {stroke_hole_counts['Red']} net stroke holes, while Blue converted {stroke_hole_net_wins['Blue']} of {stroke_hole_counts['Blue']}."
        )

    if top_highlights:
        bits = []
        for label, c in top_highlights:
            bits.append(f"{label} was credited with {c} highlighted net hole{'s' if c != 1 else ''}")
        leverage_parts.append("On the popup scorecard view, " + " and ".join(bits) + ".")
    leverage_sentence = " ".join(leverage_parts)

    prob_parts = []
    if probs_sorted and winner_prob_key and max_winner_prob is not None and min_winner_prob is not None:
        prob_parts.append(
            f"The projection track for the eventual winner ranged from {min_winner_prob:.1f}% to {max_winner_prob:.1f}% during the plotted holes, which captures how much uncertainty remained before the match finally closed."
        )
        if major_swing and abs(major_swing["delta"]) >= 8:
            direction = "jumped" if major_swing["delta"] > 0 else "dropped"
            prob_parts.append(
                f"The sharpest swing came between holes {major_swing['from_hole']} and {major_swing['to_hole']}, when {winner_label(winner)}'s win probability {direction} from {major_swing['from']:.1f}% to {major_swing['to']:.1f}%."
            )
        if prob_sum:
            prob_parts.append(
                f"The summary line correctly resolves to the final state ({f(prob_sum.get('red_win_prob_pct')) or 0:.1f}% Red / {f(prob_sum.get('tie_prob_pct')) or 0:.1f}% Tie / {f(prob_sum.get('blue_win_prob_pct')) or 0:.1f}% Blue) once the result is posted."
            )
    else:
        prob_parts.append("Probability trend data is unavailable or not modeled for this format, so the recap leans on the net hole sequence rather than win-projection swings.")
    prob_sentence = " ".join(prob_parts)

    decision_reason_parts = []
    if holes_sorted:
        decision_reason_parts.append(
            f"Net hole totals finished {red_net_wins}-{blue_net_wins} with {halved} halved hole{'s' if halved != 1 else ''}, which is the cleanest explanation of the margin."
        )
        if winner == "Red":
            if red_net_wins > blue_net_wins:
                decision_reason_parts.append("Red's edge came from stacking enough net wins in clusters and avoiding a long back-half giveback.")
            else:
                decision_reason_parts.append("Red still cashed the match despite not dominating hole count, which points to timing and pressure holes more than volume.")
        elif winner == "Blue":
            if blue_net_wins > red_net_wins:
                decision_reason_parts.append("Blue won it by converting more net holes, not by waiting for Red mistakes to accumulate.")
            else:
                decision_reason_parts.append("Blue's point came from timing the wins, not from owning the card hole after hole.")
        else:
            decision_reason_parts.append("Neither side separated because every short burst was answered, and the halved-hole volume kept the match from breaking open.")
    else:
        decision_reason_parts.append("The result is clear, but missing hole-level metadata prevents a sharper diagnostic on where the match actually swung.")

    if issue_counts:
        missing_meta_count = issue_counts.get("missing_course_or_tees_meta", 0) + issue_counts.get("missing_hole_definition", 0)
        if missing_meta_count:
            decision_reason_parts.append("This summary is constrained by historical data gaps in the exported hole/course metadata for this specific match.")
    decision_reason = " ".join(decision_reason_parts)

    sentences = [opening[0], handicap_sentence, flow_early, mid_sentence, leverage_sentence, prob_sentence, decision_reason]
    text = " ".join(s.strip() for s in sentences if s.strip())

    # Keep 200-300 words with controlled padding/trimming.
    if words(text) < 200:
        extra = []
        if holes_sorted:
            pars = [i(h.get("par")) for h in holes_sorted if i(h.get("par")) is not None]
            hdcps = [i(h.get("hole_handicap")) for h in holes_sorted if i(h.get("hole_handicap")) is not None]
            if pars:
                extra.append(f"The scoring run also played out across a mix of par values, so the net comparisons mattered on both scoring holes and survival holes rather than in one narrow scoring profile.")
            if hdcps:
                low_si = min(hdcps)
                high_si = max(hdcps)
                extra.append(f"From a match-play strategy angle, the stroke-index spread ({low_si} through {high_si}) created enough handicap leverage opportunities that execution on the right holes mattered more than a simple average-score comparison.")
        if not extra:
            extra.append("Even without every supporting datapoint, the exported net score sequence and result line are enough to identify the basic rhythm of the match and why the point landed where it did.")
        text = text + " " + " ".join(extra)

    # Trim if too long by dropping lower-priority trailing sentences.
    if words(text) > 300:
        parts = sentences.copy()
        # remove probability detail first, then leverage detail if needed
        for idx in [5, 4]:
            if idx < len(parts) and parts[idx]:
                parts[idx] = ""
                candidate = " ".join(s.strip() for s in parts if s.strip())
                if words(candidate) <= 300:
                    text = candidate
                    break
        if words(text) > 300:
            # hard trim to ~295 words
            toks = text.split()
            text = " ".join(toks[:295]).rstrip(",;.") + "."

    return {
        "match_uid": match_uid,
        "year": year,
        "round": round_no,
        "match": match_no,
        "matchgroup": norm(match.get("matchgroup")),
        "format": fmt,
        "summary": text,
        "word_count": str(words(text)),
    }


def main():
    data = load_data()
    by_match = {m["match_uid"]: m for m in data["matches"]}
    grouped = {
        "participants": group_by(data["participants"], "match_uid"),
        "team_hcps": group_by(data["team_hcps"], "match_uid"),
        "holes": group_by(data["holes"], "match_uid"),
        "popup_rows": group_by(data["popup_rows"], "match_uid"),
        "prob_chart": group_by(data["prob_chart"], "match_uid"),
        "prob_summary": group_by(data["prob_summary"], "match_uid"),
        "issues": group_by(data["issues"], "match_uid"),
    }

    summaries = []
    for match_uid, match in sorted(by_match.items(), key=lambda kv: (int(kv[1]["year"]), int(kv[1]["round"]), int(kv[1]["match"]), int(kv[1].get("matchgroup") or 0))):
        summaries.append(
            summarize_match(
                match,
                grouped["participants"].get(match_uid, []),
                grouped["team_hcps"].get(match_uid, []),
                grouped["holes"].get(match_uid, []),
                grouped["popup_rows"].get(match_uid, []),
                grouped["prob_chart"].get(match_uid, []),
                grouped["prob_summary"].get(match_uid, []),
                grouped["issues"].get(match_uid, []),
            )
        )

    with OUT.open("w", newline="", encoding="utf-8") as f:
        fieldnames = ["match_uid", "year", "round", "match", "matchgroup", "format", "summary", "word_count"]
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        w.writerows(summaries)

    counts = [int(r["word_count"]) for r in summaries]
    print(f"Wrote {len(summaries)} summaries to {OUT}")
    print(f"Word count min/avg/max: {min(counts)}/{mean(counts):.1f}/{max(counts)}")
    low = [r for r in summaries if int(r["word_count"]) < 200]
    high = [r for r in summaries if int(r["word_count"]) > 300]
    print(f"Below 200: {len(low)} | Above 300: {len(high)}")
    if low[:3]:
        print("Sample low:", [(r["match_uid"], r["word_count"]) for r in low[:3]])
    if high[:3]:
        print("Sample high:", [(r["match_uid"], r["word_count"]) for r in high[:3]])


if __name__ == "__main__":
    main()

