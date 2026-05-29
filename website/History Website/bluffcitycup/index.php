<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Bluff City Cup Records</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;700;800&family=Outfit:wght@500;700;900&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
  <style>
    :root {
      --blue: #0b387e;
      --blue-deep: #062558;
      --red: #bf0f21;
      --red-deep: #8f0b19;
      --ink: #10203a;
      --paper: #f4f7fc;
      --card: #ffffff;
      --line: #d7dfef;
      --text: #15223b;
      --muted: #5f6e8d;
      --shadow: 0 16px 42px rgba(8, 29, 66, 0.12);
      --radius: 18px;
    }

    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      font-family: 'Manrope', sans-serif;
      color: var(--text);
      background:
        radial-gradient(1200px 640px at -12% -8%, rgba(11, 56, 126, 0.2), transparent 70%),
        radial-gradient(900px 540px at 108% -20%, rgba(191, 15, 33, 0.16), transparent 72%),
        linear-gradient(180deg, #f9fbff 0%, #eef3fb 100%);
      min-height: 100vh;
    }

    .wrap {
      width: min(1240px, 94vw);
      margin: 0 auto;
      padding: 28px 0 42px;
    }

    .hero {
      background: linear-gradient(128deg, rgba(6, 37, 88, 0.97), rgba(11, 56, 126, 0.95));
      border-radius: 26px;
      color: #fff;
      padding: 20px 24px;
      display: grid;
      grid-template-columns: auto 1fr;
      gap: 18px;
      align-items: center;
      box-shadow: var(--shadow);
      border: 1px solid rgba(255, 255, 255, 0.2);
      position: relative;
      overflow: hidden;
    }

    .hero::after {
      content: '';
      position: absolute;
      inset: auto -120px -170px auto;
      width: 390px;
      height: 390px;
      border-radius: 50%;
      background: radial-gradient(circle, rgba(191, 15, 33, 0.32), rgba(191, 15, 33, 0));
      pointer-events: none;
    }

    .logo {
      width: 124px;
      height: 124px;
      object-fit: contain;
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.08);
      border: 2px solid rgba(255, 255, 255, 0.24);
      padding: 6px;
      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.24);
      position: relative;
      z-index: 1;
    }

    .hero h1 {
      margin: 0;
      font-family: 'Outfit', sans-serif;
      font-size: clamp(1.5rem, 2.4vw, 2.25rem);
      line-height: 1.1;
      letter-spacing: 0.02em;
      font-weight: 900;
      position: relative;
      z-index: 1;
    }

    .hero p {
      margin: 10px 0 0;
      color: rgba(255, 255, 255, 0.88);
      max-width: 62ch;
      position: relative;
      z-index: 1;
    }

    .content {
      margin-top: 18px;
      display: grid;
      gap: 16px;
    }

    .card {
      background: var(--card);
      border-radius: var(--radius);
      border: 1px solid #e2e9f5;
      box-shadow: var(--shadow);
      padding: 16px;
    }

    .collapsible-card {
      position: relative;
    }

    .collapsible-card h2,
    .collapsible-card .sub {
      padding-right: 34px;
    }

    .collapse-toggle {
      position: absolute;
      top: 12px;
      right: 12px;
      width: 28px;
      height: 28px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border: 1px solid #d5e0f2;
      background: #fff;
      color: #1c3565;
      border-radius: 8px;
      padding: 0;
      font-size: 1rem;
      line-height: 1;
      font-weight: 800;
      cursor: pointer;
      z-index: 3;
    }

    .collapse-toggle:hover {
      background: #eef3ff;
      border-color: #bfd0ef;
    }

    .collapse-toggle:focus {
      outline: none;
      box-shadow: 0 0 0 3px rgba(67, 129, 224, 0.2);
      border-color: #6a91dd;
    }

    .collapsible-body[hidden] {
      display: none !important;
    }

    .chart-wrap {
      height: 320px;
      margin-top: 10px;
    }

    h2 {
      margin: 0;
      font-family: 'Outfit', sans-serif;
      font-size: 1.2rem;
      letter-spacing: 0.02em;
      color: var(--ink);
    }

    .sub {
      margin: 6px 0 0;
      color: var(--muted);
      font-size: 0.93rem;
    }

    .filters {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-top: 12px;
    }

    .filters label {
      font-size: 0.78rem;
      color: #415377;
      font-weight: 700;
      display: flex;
      flex-direction: column;
      gap: 4px;
      min-width: 140px;
    }

    select,
    .filters input[type='number'] {
      appearance: none;
      border: 1px solid #c8d4ea;
      background: linear-gradient(180deg, #ffffff, #f5f8ff);
      border-radius: 10px;
      color: #13244a;
      font-size: 0.9rem;
      padding: 8px 9px;
      font-family: inherit;
      font-weight: 600;
      outline: none;
    }

    select:focus,
    .filters input[type='number']:focus {
      border-color: #6a91dd;
      box-shadow: 0 0 0 3px rgba(67, 129, 224, 0.2);
    }

    .multi-native {
      display: none;
    }

    .multi-dropdown {
      position: relative;
      width: 100%;
      min-width: 180px;
    }

    .multi-trigger {
      width: 100%;
      border: 1px solid #c8d4ea;
      background: linear-gradient(180deg, #ffffff, #f5f8ff);
      border-radius: 10px;
      color: #13244a;
      font-size: 0.9rem;
      padding: 8px 34px 8px 9px;
      font-family: inherit;
      font-weight: 600;
      text-align: left;
      cursor: pointer;
      position: relative;
      min-height: 38px;
    }

    .multi-trigger::after {
      content: '▾';
      position: absolute;
      right: 10px;
      top: 50%;
      transform: translateY(-50%);
      color: #5f6e8d;
      font-size: 0.8rem;
    }

    .multi-dropdown.open .multi-trigger {
      border-color: #6a91dd;
      box-shadow: 0 0 0 3px rgba(67, 129, 224, 0.2);
    }

    .multi-dropdown.open .multi-trigger::after {
      content: '▴';
    }

    .multi-menu {
      display: none;
      position: absolute;
      top: calc(100% + 4px);
      left: 0;
      right: 0;
      z-index: 20;
      max-height: 230px;
      overflow: auto;
      background: #fff;
      border: 1px solid #c8d4ea;
      border-radius: 10px;
      box-shadow: 0 12px 24px rgba(8, 29, 66, 0.16);
      padding: 4px;
    }

    .multi-dropdown.open .multi-menu {
      display: block;
    }

    .multi-option {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 7px 8px;
      border-radius: 8px;
      cursor: pointer;
      color: #1f3157;
      font-size: 0.87rem;
      font-weight: 600;
    }

    .multi-option:hover {
      background: #eef3ff;
    }

    .multi-option input {
      margin: 0;
      cursor: pointer;
    }

    .check-filter {
      justify-content: flex-end;
    }

    .check-filter span {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      min-height: 38px;
      padding: 0 2px;
      font-size: 0.84rem;
      font-weight: 600;
      color: #1f3157;
    }

    .check-filter input[type='checkbox'] {
      margin: 0;
      width: 15px;
      height: 15px;
      accent-color: #274b8e;
      cursor: pointer;
    }

    .hide-pair-format .pair-format-col {
      display: none;
    }

    .table-wrap {
      margin-top: 12px;
      overflow: auto;
      border: 1px solid #d8e2f4;
      border-radius: 12px;
      background: #fff;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      min-width: 860px;
    }

    th,
    td {
      padding: 10px 10px;
      text-align: left;
      border-bottom: 1px solid #ecf1fb;
      font-size: 0.9rem;
      white-space: nowrap;
    }

    th {
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.07em;
      color: #486188;
      background: #f4f7fe;
      position: sticky;
      top: 0;
      z-index: 2;
    }

    th.sortable {
      cursor: pointer;
      user-select: none;
    }

    th.sortable::after {
      content: ' ↕';
      color: #7f8db0;
      font-size: 0.72rem;
      letter-spacing: 0;
    }

    th.sortable[data-sort='asc']::after {
      content: ' ↑';
      color: #234784;
    }

    th.sortable[data-sort='desc']::after {
      content: ' ↓';
      color: #234784;
    }

    tbody tr:hover {
      background: #f9fbff;
    }

    .team-pill {
      padding: 4px 8px;
      border-radius: 999px;
      font-size: 0.74rem;
      font-weight: 800;
      display: inline-block;
      letter-spacing: 0.03em;
    }

    .team-red {
      color: #fff;
      background: linear-gradient(120deg, var(--red), var(--red-deep));
    }

    .team-blue {
      color: #fff;
      background: linear-gradient(120deg, var(--blue), var(--blue-deep));
    }

    .h2h-picker-shell {
      margin-top: 12px;
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }

    .h2h-team-panel {
      border: 1px solid #dbe4f3;
      border-radius: 14px;
      padding: 12px;
      background: #fbfdff;
    }

    .h2h-team-panel h3 {
      margin: 0 0 10px;
      font-family: 'Outfit', sans-serif;
      font-size: 1rem;
      letter-spacing: 0.02em;
    }

    .h2h-team-panel.red h3 { color: var(--red-deep); }
    .h2h-team-panel.blue h3 { color: var(--blue-deep); }

    .h2h-player-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(88px, 1fr));
      grid-auto-rows: minmax(112px, auto);
      gap: 10px;
    }

    .h2h-avatar-btn {
      border: 0;
      background: transparent;
      padding: 0;
      cursor: pointer;
      color: inherit;
      font: inherit;
      width: 100%;
      height: 100%;
      min-height: 112px;
      display: grid;
      justify-items: center;
      gap: 6px;
      align-content: start;
    }

    .h2h-avatar-btn .avatar-wrap {
      width: 74px;
      height: 74px;
      border-radius: 50%;
      padding: 3px;
      background: linear-gradient(180deg, #ffffff, #e8eefb);
      border: 1px solid #d6e0f4;
      box-shadow: 0 5px 14px rgba(13, 43, 94, 0.08);
      display: grid;
      place-items: center;
      transition: transform 120ms ease, box-shadow 120ms ease, border-color 120ms ease;
    }

    .h2h-avatar-btn.red .avatar-wrap { border-color: rgba(188, 28, 47, 0.22); }
    .h2h-avatar-btn.blue .avatar-wrap { border-color: rgba(13, 52, 120, 0.22); }

    .h2h-avatar-btn:hover .avatar-wrap {
      transform: translateY(-2px);
      box-shadow: 0 8px 18px rgba(13, 43, 94, 0.12);
    }

    .h2h-avatar-btn.is-selected .avatar-wrap {
      border-color: #6a91dd;
      box-shadow: 0 0 0 3px rgba(67, 129, 224, 0.18), 0 8px 18px rgba(13, 43, 94, 0.12);
      background: linear-gradient(180deg, #ffffff, #e6efff);
      transform: translateY(-1px);
    }

    .h2h-avatar-btn img {
      width: 66px;
      height: 66px;
      border-radius: 50%;
      object-fit: cover;
      border: 2px solid #e1e9f8;
      background: #f3f6fc;
      display: block;
    }

    .h2h-avatar-btn .name {
      font-size: 0.74rem;
      line-height: 1.15;
      text-align: center;
      color: #2b406d;
      font-weight: 700;
      min-height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0 2px;
    }

    .h2h-empty-picker {
      color: #6a7490;
      font-size: 0.85rem;
      padding: 4px 0;
    }

    .player-profiles-shell {
      margin-top: 12px;
      border: 1px solid #dbe4f3;
      border-radius: 14px;
      background: linear-gradient(180deg, #fbfdff 0%, #f6f9ff 100%);
      padding: 14px;
      display: grid;
      grid-template-columns: 1fr auto 1fr;
      gap: 16px;
      align-items: stretch;
    }

    .player-profiles-divider {
      width: 1px;
      background: linear-gradient(180deg, rgba(52, 108, 208, 0.12), rgba(52, 108, 208, 0.7), rgba(52, 108, 208, 0.12));
      border-radius: 999px;
    }

    .player-profiles-team {
      display: grid;
      gap: 10px;
      align-content: start;
      min-width: 0;
    }

    .player-profiles-team h3 {
      margin: 0;
      font-family: 'Outfit', sans-serif;
      font-size: 1rem;
      font-weight: 800;
      letter-spacing: 0.02em;
    }

    .player-profiles-team.red h3 { color: var(--red-deep); }
    .player-profiles-team.blue h3 { color: var(--blue-deep); }

    .player-profiles-grid {
      display: grid;
      grid-template-columns: repeat(5, minmax(0, 1fr));
      gap: 14px 12px;
    }

    .player-profile-tile {
      border: 0;
      background: transparent;
      padding: 0;
      cursor: pointer;
      color: inherit;
      font: inherit;
      display: grid;
      justify-items: center;
      gap: 6px;
      align-content: start;
    }

    .player-profile-tile .avatar-wrap {
      width: 74px;
      height: 74px;
      border-radius: 50%;
      padding: 3px;
      background: linear-gradient(180deg, #ffffff, #e8eefb);
      border: 1px solid #d6e0f4;
      box-shadow: 0 5px 14px rgba(13, 43, 94, 0.08);
      display: grid;
      place-items: center;
      transition: transform 120ms ease, box-shadow 120ms ease, border-color 120ms ease;
    }

    .player-profile-tile.red .avatar-wrap { border-color: rgba(188, 28, 47, 0.22); }
    .player-profile-tile.blue .avatar-wrap { border-color: rgba(13, 52, 120, 0.22); }

    .player-profile-tile:hover .avatar-wrap {
      transform: translateY(-2px);
      box-shadow: 0 8px 18px rgba(13, 43, 94, 0.12);
    }

    .player-profile-tile img {
      width: 66px;
      height: 66px;
      border-radius: 50%;
      object-fit: cover;
      border: 2px solid #e1e9f8;
      background: #f3f6fc;
      display: block;
    }

    .player-profile-tile .name {
      font-size: 0.74rem;
      line-height: 1.15;
      text-align: center;
      color: #2b406d;
      font-weight: 700;
      min-height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0 2px;
    }

    .player-profile-empty {
      color: #6a7490;
      font-size: 0.85rem;
      padding: 2px 0;
    }

    .h2h-summary {
      margin-top: 12px;
      display: grid;
      gap: 10px;
    }

    .h2h-summary-row {
      display: grid;
      grid-template-columns: 1fr auto 1fr;
      gap: 10px;
      align-items: stretch;
    }

    .h2h-stat-card {
      border: 1px solid #dbe4f3;
      border-radius: 14px;
      padding: 10px;
      background: #fff;
      display: grid;
      grid-template-columns: auto 1fr auto;
      gap: 10px;
      align-items: center;
    }

    .h2h-stat-card img {
      width: 52px;
      height: 52px;
      border-radius: 50%;
      object-fit: cover;
      border: 2px solid #d7e2f6;
      background: #f2f5fb;
    }

    .h2h-stat-card.red { border-left: 4px solid var(--red); }
    .h2h-stat-card.blue { border-left: 4px solid var(--blue); }

    .h2h-stat-card .player {
      font-weight: 800;
      color: #15223b;
      font-size: 0.92rem;
    }

    .h2h-stat-card .meta {
      color: #5e6d8d;
      font-size: 0.8rem;
      margin-top: 2px;
    }

    .h2h-stat-main {
      min-width: 0;
    }

    .h2h-winpct {
      text-align: right;
      min-width: 94px;
      display: grid;
      align-content: center;
      justify-items: end;
      gap: 2px;
    }

    .h2h-winpct .label {
      font-size: 0.68rem;
      font-weight: 800;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      color: #6a7a9a;
      line-height: 1;
    }

    .h2h-winpct .value {
      font-family: 'Outfit', sans-serif;
      font-size: 1.55rem;
      font-weight: 900;
      line-height: 0.95;
      color: #15223b;
      letter-spacing: 0.01em;
    }

    .h2h-vs {
      align-self: center;
      font-family: 'Outfit', sans-serif;
      font-weight: 800;
      color: #44597f;
      letter-spacing: 0.08em;
      padding: 0 2px;
    }

    .h2h-empty-state {
      border: 1px dashed #cfd9ea;
      border-radius: 12px;
      padding: 10px 12px;
      color: #596a8c;
      font-size: 0.88rem;
      background: #f7faff;
    }

    .h2h-compare-board {
      border: 1px solid #dbe4f3;
      border-radius: 14px;
      background: #fff;
      padding: 14px;
      display: grid;
      gap: 12px;
    }

    .h2h-compare-head {
      display: grid;
      grid-template-columns: 1fr auto 1fr;
      gap: 10px;
      align-items: center;
    }

    .h2h-compare-player {
      display: grid;
      justify-items: center;
      gap: 6px;
      text-align: center;
    }

    .h2h-compare-player img {
      width: 93px;
      height: 93px;
      border-radius: 50%;
      object-fit: cover;
      border: 2px solid #d7e2f6;
      background: #f2f5fb;
    }

    .h2h-compare-player .name {
      font-weight: 800;
      color: #15223b;
      font-size: 0.9rem;
      line-height: 1.15;
    }

    .h2h-compare-player.red .name { color: var(--red-deep); }
    .h2h-compare-player.blue .name { color: var(--blue-deep); }

    .h2h-compare-vs {
      font-family: 'Outfit', sans-serif;
      font-weight: 900;
      color: #253f73;
      font-size: 1.2rem;
      letter-spacing: 0.05em;
      align-self: center;
    }

    .h2h-compare-rows {
      display: grid;
      gap: 8px;
    }

    .h2h-compare-row {
      display: grid;
      grid-template-columns: 1fr auto 1fr;
      gap: 10px;
      align-items: center;
      border: 1px solid #e3eaf6;
      border-radius: 12px;
      background: #fbfdff;
      padding: 8px 10px;
    }

    .h2h-compare-row.overall {
      background: #f5f9ff;
      border-color: #d5e1f5;
    }

    .h2h-compare-label {
      font-family: 'Outfit', sans-serif;
      font-weight: 800;
      color: #1d2f56;
      font-size: 0.92rem;
      text-align: center;
      min-width: 110px;
      padding: 0 4px;
    }

    .h2h-compare-row.overall .h2h-compare-label {
      font-size: 1.1rem;
    }

    .h2h-compare-metric {
      display: grid;
      justify-items: center;
      gap: 2px;
      text-align: center;
      min-width: 0;
    }

    .h2h-compare-metric .pct {
      font-family: 'Outfit', sans-serif;
      font-size: 1.35rem;
      font-weight: 900;
      line-height: 0.95;
      color: #15223b;
    }

    .h2h-compare-row.overall .h2h-compare-metric .pct {
      font-size: 1.75rem;
    }

    .h2h-compare-metric .record {
      font-size: 0.84rem;
      color: #5f6f90;
      font-weight: 700;
      line-height: 1.1;
    }

    .h2h-compare-metric.red .pct { color: var(--red-deep); }
    .h2h-compare-metric.blue .pct { color: var(--blue-deep); }

    #teamFormatSummary .h2h-compare-player .name {
      font-size: 1.8rem;
      line-height: 1.05;
    }

    #teamFormatSummary .h2h-compare-head {
      padding: 0 10px;
    }

    #teamFormatSummary .h2h-compare-metric .pct {
      font-weight: 400;
    }

    #teamFormatSummary .h2h-compare-row.overall .h2h-compare-metric .pct {
      font-weight: 900;
    }

    #teamFormatSummary .h2h-compare-metric {
      justify-self: stretch;
      align-self: stretch;
      border-radius: 10px;
      padding: 6px 8px;
    }

    #teamFormatSummary .h2h-compare-row {
      background: linear-gradient(
        to right,
        rgba(188, 28, 47, 0.10) 0%,
        rgba(188, 28, 47, 0.10) var(--row-red-fill, 50%),
        rgba(13, 52, 120, 0.10) var(--row-red-fill, 50%),
        rgba(13, 52, 120, 0.10) 100%
      );
    }

    #teamFormatSummary .h2h-compare-row.overall {
      background: linear-gradient(
        to right,
        rgba(188, 28, 47, 0.12) 0%,
        rgba(188, 28, 47, 0.12) var(--row-red-fill, 50%),
        rgba(13, 52, 120, 0.12) var(--row-red-fill, 50%),
        rgba(13, 52, 120, 0.12) 100%
      );
    }

    #teamFormatSummary .h2h-compare-metric.red,
    #teamFormatSummary .h2h-compare-metric.blue {
      background: transparent;
    }

    #h2hSummary .h2h-compare-metric {
      justify-self: stretch;
      align-self: stretch;
      border-radius: 10px;
      padding: 6px 8px;
    }

    #h2hSummary .h2h-compare-metric .pct {
      font-weight: 400;
    }

    #h2hSummary .h2h-compare-row.overall .h2h-compare-metric .pct {
      font-weight: 900;
    }

    #h2hSummary .h2h-compare-row {
      background: linear-gradient(
        to right,
        rgba(188, 28, 47, 0.10) 0%,
        rgba(188, 28, 47, 0.10) var(--row-red-fill, 50%),
        rgba(13, 52, 120, 0.10) var(--row-red-fill, 50%),
        rgba(13, 52, 120, 0.10) 100%
      );
    }

    #h2hSummary .h2h-compare-row.overall {
      background: linear-gradient(
        to right,
        rgba(188, 28, 47, 0.12) 0%,
        rgba(188, 28, 47, 0.12) var(--row-red-fill, 50%),
        rgba(13, 52, 120, 0.12) var(--row-red-fill, 50%),
        rgba(13, 52, 120, 0.12) 100%
      );
    }

    #h2hSummary .h2h-compare-metric.red,
    #h2hSummary .h2h-compare-metric.blue {
      background: transparent;
    }

    .h2h-breakout.table-wrap {
      margin-top: 0;
    }

    .h2h-breakout table {
      min-width: 0;
      width: 100%;
    }

    .h2h-breakout th,
    .h2h-breakout td {
      font-size: 0.82rem;
      padding: 8px 8px;
    }

    .result-win { color: #137a35; font-weight: 700; }
    .result-loss { color: #bc1c2f; font-weight: 700; }
    .result-tie { color: #5e6684; font-weight: 700; }

    .match-row-trigger {
      cursor: pointer;
    }

    .match-row-trigger:hover {
      background: #f3f7ff;
    }

    .match-modal {
      position: fixed;
      inset: 0;
      z-index: 1000;
      display: grid;
      place-items: center;
      padding: 16px;
    }

    .match-modal[hidden] {
      display: none;
    }

    .match-modal-backdrop {
      position: absolute;
      inset: 0;
      background: rgba(10, 20, 41, 0.55);
      backdrop-filter: blur(2px);
    }

    .match-modal-panel {
      position: relative;
      width: min(980px, 92vw);
      max-height: min(88vh, 860px);
      overflow: auto;
      background: #fff;
      border: 1px solid rgba(0, 0, 0, 0.06);
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.18);
      z-index: 1;
      animation: matchModalPanelIn 180ms ease-out;
    }

    .match-modal-header {
      position: sticky;
      top: 0;
      z-index: 50;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      padding: 18px 22px 12px;
      border-bottom: 1px solid rgba(0, 0, 0, 0.06);
      background: rgba(255, 255, 255, 0.85);
      backdrop-filter: blur(8px);
    }

    .match-modal-close {
      position: static;
      width: 40px;
      height: 40px;
      min-width: 40px;
      border-radius: 999px;
      border: 1px solid rgba(0, 0, 0, 0.08);
      background: rgba(255, 255, 255, 0.85);
      color: #28406f;
      font-size: 1.05rem;
      line-height: 1;
      cursor: pointer;
      display: grid;
      place-items: center;
    }

    .match-modal-title {
      font-family: 'Outfit', sans-serif;
      font-size: 1.2rem;
      font-weight: 700;
      color: #1a2f58;
      margin-right: 0;
    }

    .match-modal-content {
      display: grid;
      gap: 0;
      padding: 24px;
    }

    .match-modal-section {
      padding: 0;
    }

    .match-modal-section + .match-modal-section {
      margin-top: 22px;
      padding-top: 22px;
      border-top: 1px solid rgba(0, 0, 0, 0.06);
    }

    .match-modal-summary {
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 12px;
      background: rgba(0, 0, 0, 0.02);
      padding: 18px;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.65);
      position: relative;
      overflow: hidden;
      max-width: 78ch;
    }

    .match-modal-summary::before {
      content: '';
      position: absolute;
      inset: 0 auto 0 0;
      width: 4px;
      background: #9eb1d6;
    }

    .match-modal-summary.winner-red::before {
      background: linear-gradient(180deg, rgba(188, 28, 47, 0.9), rgba(188, 28, 47, 0.55));
    }

    .match-modal-summary.winner-blue::before {
      background: linear-gradient(180deg, rgba(13, 52, 120, 0.9), rgba(13, 52, 120, 0.55));
    }

    .match-modal-summary.winner-tie::before {
      background: linear-gradient(180deg, rgba(122, 132, 151, 0.9), rgba(122, 132, 151, 0.55));
    }

    .match-modal-summary-label {
      margin: 0 0 6px;
      color: rgba(0, 0, 0, 0.6);
      text-transform: uppercase;
      letter-spacing: 0.06em;
      font-size: 0.72rem;
      font-weight: 800;
    }

    .match-modal-summary-text {
      margin: 0;
      color: #22375f;
      line-height: 1.58;
      font-size: 0.96rem;
      white-space: pre-wrap;
    }

    .match-modal-meta {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      align-items: center;
    }

    .match-modal-chip {
      border: 1px solid #d8e3f6;
      background: #f7faff;
      color: #243c68;
      border-radius: 999px;
      padding: 6px 10px;
      font-size: 0.79rem;
      font-weight: 700;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }

    .match-modal-chip .label {
      color: rgba(0, 0, 0, 0.6);
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      font-size: 0.7rem;
    }

    .match-modal-matchup {
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 14px;
      background: #fbfdff;
      padding: 16px;
      display: grid;
      grid-template-columns: 1fr auto 1fr;
      gap: 20px;
      align-items: stretch;
    }

    .match-modal-side {
      display: grid;
      gap: 10px;
      align-content: start;
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 12px;
      padding: 14px;
      background: rgba(255, 255, 255, 0.92);
      box-shadow: 0 6px 18px rgba(17, 34, 68, 0.05);
      min-height: 100%;
    }

    .match-modal-side.red .side-title { color: var(--red-deep); }
    .match-modal-side.blue .side-title { color: var(--blue-deep); }

    .match-modal-side.red.is-winner {
      background: #fff;
      border-color: rgba(188, 28, 47, 0.22);
    }

    .match-modal-side.blue.is-winner {
      background: #fff;
      border-color: rgba(13, 52, 120, 0.22);
    }

    .match-modal-side .side-title {
      font-family: 'Outfit', sans-serif;
      font-size: 0.95rem;
      font-weight: 800;
      letter-spacing: 0.04em;
      text-transform: uppercase;
    }

    .match-modal-vs {
      font-family: 'Outfit', sans-serif;
      font-size: 1.25rem;
      font-weight: 900;
      color: #27447a;
      align-self: center;
      padding: 0 4px;
    }

    .match-modal-players {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(110px, 1fr));
      gap: 12px;
      align-items: stretch;
    }

    .match-modal-player {
      border: 1px solid rgba(0, 0, 0, 0.05);
      background: #fff;
      border-radius: 12px;
      padding: 10px;
      display: grid;
      justify-items: center;
      gap: 8px;
      text-align: center;
    }

    .match-modal-player.red.is-winner {
      background: linear-gradient(180deg, rgba(188, 28, 47, 0.12), rgba(188, 28, 47, 0.05));
      border-color: rgba(188, 28, 47, 0.24);
    }

    .match-modal-player.blue.is-winner {
      background: linear-gradient(180deg, rgba(13, 52, 120, 0.12), rgba(13, 52, 120, 0.05));
      border-color: rgba(13, 52, 120, 0.24);
    }

    .match-modal-player img,
    .match-modal-player .placeholder {
      width: 54px;
      height: 54px;
      border-radius: 50%;
      object-fit: cover;
      border: 2px solid #d7e2f6;
      background: #f0f4fb;
    }

    .match-modal-player .placeholder {
      display: grid;
      place-items: center;
      font-family: 'Outfit', sans-serif;
      font-weight: 800;
      color: #415886;
      font-size: 0.9rem;
    }

    .match-modal-player .name {
      font-size: 0.86rem;
      color: #263a63;
      font-weight: 700;
      line-height: 1.2;
      word-break: break-word;
    }

    .match-holeboards {
      display: grid;
      gap: 14px;
    }

    .match-holeboards-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 12px;
    }

    .match-holeboards-grid.two {
      grid-template-columns: 1fr 1fr;
    }

    .match-holeboard {
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 14px;
      overflow: auto;
      background: #fff;
      position: relative;
      -webkit-overflow-scrolling: touch;
      box-shadow: 0 4px 14px rgba(17, 34, 68, 0.03);
    }

    .match-holeboard::before,
    .match-holeboard::after {
      content: '';
      position: absolute;
      top: 0;
      bottom: 0;
      width: 12px;
      pointer-events: none;
      z-index: 1;
    }

    .match-holeboard::before {
      left: 0;
      display: none;
    }

    .match-holeboard::after {
      right: 0;
      display: none;
    }

    .match-holeboard table {
      width: 100%;
      min-width: 0;
      border-collapse: collapse;
      table-layout: fixed;
    }

    .match-holeboard td {
      border-bottom: 1px solid rgba(0, 0, 0, 0.06);
      padding: 6px 4px;
      white-space: nowrap;
      font-size: 0.78rem;
      text-align: center;
      color: #2b406d;
    }

    .match-holeboard tr:last-child td {
      border-bottom: 0;
    }

    .match-holeboard td:first-child {
      text-align: left;
      width: 120px;
      padding-left: 8px;
      font-weight: 700;
      position: sticky;
      left: 0;
      z-index: 1;
      background: #fff;
    }

    .match-holeboard td:last-child {
      width: 40px;
      font-weight: 800;
    }

    .match-holeboard td.seg-total {
      width: 40px;
      font-weight: 800;
      background: rgba(0, 0, 0, 0.03);
    }

    .match-holeboard td.seg-divider {
      border-left: 2px solid #d7e2f6;
    }

    .match-holeboard .meta-row td.seg-divider {
      border-left-color: rgba(255, 255, 255, 0.2);
    }

    .match-holeboard .meta-row td {
      background: #17367e;
      color: #fff;
      border-bottom-color: rgba(255, 255, 255, 0.08);
      font-style: italic;
      font-weight: 800;
    }

    .match-holeboard .meta-row td:first-child {
      background: #17367e;
      z-index: 2;
    }

    .match-holeboard .meta-row td:first-child {
      letter-spacing: 0.05em;
    }

    .match-holeboard .meta-row td.seg-total {
      background: #2a4a94;
      color: #f3f7ff;
      font-weight: 800;
    }

    .match-holeboard .meta-row:first-child td.seg-total {
      background: #3458ab;
      color: #ffffff;
      letter-spacing: 0.06em;
      font-style: normal;
      text-transform: uppercase;
    }

    .match-holeboard .score-row:nth-child(even) td {
      background: rgba(0, 0, 0, 0.015);
    }

    .match-holeboard .score-row:nth-child(even) td:first-child {
      background: rgba(0, 0, 0, 0.015);
    }

    .match-holeboard .score-row td:last-child {
      background: rgba(0, 0, 0, 0.03);
    }

    .match-holeboard .score-row td:first-child {
      font-weight: 700;
      font-style: normal;
      white-space: normal;
      line-height: 1.15;
      overflow-wrap: break-word;
      word-break: normal;
    }

    .match-holeboard .score-row.red td:first-child {
      color: var(--red-deep);
    }

    .match-holeboard .score-row.blue td:first-child {
      color: var(--blue-deep);
    }

    .match-holeboard .cell-score {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-width: 24px;
      height: 24px;
      padding: 0 5px;
      border-radius: 999px;
      line-height: 1;
      font-weight: 700;
      color: #334a79;
      background: transparent;
    }

    .match-holeboard .cell-score.win-red {
      background: #c80c22;
      color: #fff;
    }

    .match-holeboard .cell-score.win-blue {
      background: #143482;
      color: #fff;
    }

    .match-holeboard .cell-score.missing {
      opacity: 0.45;
    }

    .match-holeboard.combined-18 table {
      min-width: 0;
      table-layout: fixed;
    }

    .match-holeboard.combined-18 td {
      padding: 5px 2px;
      font-size: 0.72rem;
    }

    .match-holeboard.combined-18 td:first-child {
      width: 92px;
      padding-left: 6px;
      font-size: 0.72rem;
    }

    .match-holeboard.combined-18 td:last-child,
    .match-holeboard.combined-18 td.seg-total {
      width: 34px;
    }

    .match-holeboard.combined-18 .cell-score {
      min-width: 20px;
      height: 20px;
      padding: 0 4px;
      font-size: 0.72rem;
    }

    .match-holeboards-empty {
      border: 1px dashed #cfd9ea;
      border-radius: 12px;
      padding: 10px 12px;
      color: #596a8c;
      font-size: 0.88rem;
      background: #f7faff;
    }

    .match-holeboards-note {
      margin: 0 0 8px;
      color: #4e6492;
      font-size: 0.78rem;
      font-weight: 700;
      letter-spacing: 0.01em;
    }

    .match-projection {
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 12px;
      background: rgba(0, 0, 0, 0.02);
      padding: 16px 18px 14px;
    }

    .match-projection-title {
      margin: 0 0 8px;
      text-align: center;
      font-size: 1.05rem;
      font-weight: 600;
      color: #1e315f;
    }

    .match-projection-chart {
      width: 100%;
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
      padding-top: 10px;
    }

    .match-projection-chart svg {
      display: block;
      width: 100%;
      min-width: 640px;
      height: auto;
    }

    .match-projection-empty {
      color: #5c709c;
      font-size: 0.85rem;
      padding: 4px 2px 6px;
    }

    .match-projection-summary {
      margin-top: 6px;
      border-top: 1px solid #e4ebf8;
    }

    .match-projection-summary-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 7px 0;
      border-bottom: 1px solid #eef3fb;
      font-size: 0.92rem;
      font-weight: 700;
    }

    .match-projection-summary-row .label.blue { color: #17367e; }
    .match-projection-summary-row .label.tie { color: #8d919a; }
    .match-projection-summary-row .label.red { color: #a10a19; }

    .match-projection-footer {
      margin-top: 6px;
      text-align: right;
      color: #7d8799;
      font-size: 0.72rem;
      font-weight: 700;
      letter-spacing: 0.02em;
    }

    .match-projection-footer b {
      color: #111;
      font-weight: 800;
    }

    .player-modal-content {
      display: grid;
      gap: 0;
    }

    .player-profile-head {
      display: grid;
      grid-template-columns: auto 1fr;
      gap: 14px;
      align-items: center;
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 14px;
      background: linear-gradient(180deg, #fbfdff 0%, #f7faff 100%);
      padding: 16px 18px;
    }

    .player-profile-head.red {
      border-color: rgba(188, 28, 47, 0.16);
      box-shadow: inset 4px 0 0 rgba(188, 28, 47, 0.7);
    }

    .player-profile-head.blue {
      border-color: rgba(13, 52, 120, 0.16);
      box-shadow: inset 4px 0 0 rgba(13, 52, 120, 0.7);
    }

    .player-profile-head img,
    .player-profile-head .placeholder {
      width: 76px;
      height: 76px;
      border-radius: 50%;
      object-fit: cover;
      border: 2px solid #dbe5f7;
      background: #f1f5fc;
    }

    .player-profile-head .placeholder {
      display: grid;
      place-items: center;
      font-family: 'Outfit', sans-serif;
      font-weight: 800;
      color: #3f5786;
      font-size: 1.05rem;
    }

    .player-profile-head .title {
      display: grid;
      gap: 5px;
      min-width: 0;
    }

    .player-profile-head .player-name {
      margin: 0;
      font-family: 'Outfit', sans-serif;
      font-size: 1.15rem;
      font-weight: 800;
      color: #1e315c;
      line-height: 1.1;
    }

    .player-profile-head .meta {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      align-items: center;
      color: #546987;
      font-size: 0.82rem;
      font-weight: 700;
    }

    .player-profile-section-title {
      margin: 0 0 10px;
      font-family: 'Outfit', sans-serif;
      font-size: 0.96rem;
      font-weight: 800;
      color: #233963;
      letter-spacing: 0.02em;
    }

    .player-profile-bio {
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 12px;
      background: rgba(0, 0, 0, 0.02);
      padding: 16px 18px;
      color: #22375f;
      font-size: 0.93rem;
      line-height: 1.55;
      max-width: 80ch;
      white-space: pre-wrap;
    }

    .player-profile-overall-grid {
      display: grid;
      grid-template-columns: repeat(6, minmax(0, 1fr));
      gap: 10px;
    }

    .player-profile-metric {
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 12px;
      background: #fff;
      padding: 10px;
      display: grid;
      gap: 4px;
      align-content: start;
    }

    .player-profile-metric .label {
      color: rgba(0, 0, 0, 0.6);
      font-size: 0.72rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }

    .player-profile-metric .value {
      color: #213962;
      font-size: 0.98rem;
      font-weight: 800;
      line-height: 1.1;
    }

    .player-profile-record-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 14px;
    }

    .player-profile-record-card {
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 12px;
      background: #fff;
      padding: 14px;
      min-width: 0;
    }

    .player-profile-table-wrap {
      overflow: auto;
      -webkit-overflow-scrolling: touch;
      border-radius: 10px;
      border: 1px solid #e8eef9;
    }

    .player-profile-table {
      width: 100%;
      border-collapse: collapse;
      min-width: 420px;
    }

    .player-profile-table th,
    .player-profile-table td {
      padding: 8px 10px;
      border-bottom: 1px solid #eef3fb;
      text-align: left;
      color: #28406f;
      font-size: 0.82rem;
      white-space: nowrap;
    }

    .player-profile-table th {
      background: #f5f8fe;
      color: #4f658e;
      font-size: 0.74rem;
      letter-spacing: 0.05em;
      text-transform: uppercase;
      font-weight: 800;
    }

    .player-profile-table tbody tr:nth-child(even) td {
      background: rgba(0, 0, 0, 0.012);
    }

    .player-profile-table td:last-child,
    .player-profile-table th:last-child {
      text-align: right;
    }

    .player-profile-table td.num {
      text-align: right;
      font-variant-numeric: tabular-nums;
    }

    .player-profile-empty-state {
      border: 1px dashed #d4deef;
      border-radius: 12px;
      padding: 12px 14px;
      color: #60718f;
      background: #f7faff;
      font-size: 0.87rem;
    }

    .player-profile-personal-card {
      border: 1px solid rgba(0, 0, 0, 0.05);
      border-radius: 12px;
      background: #fff;
      padding: 14px;
    }

    .player-profile-personal-list {
      display: grid;
      gap: 0;
      border: 1px solid #e8eef9;
      border-radius: 10px;
      overflow: hidden;
    }

    .player-profile-personal-row {
      display: grid;
      grid-template-columns: minmax(220px, 1fr) 1.4fr;
      gap: 10px;
      align-items: start;
      padding: 10px 12px;
      border-bottom: 1px solid #eef3fb;
      background: #fff;
    }

    .player-profile-personal-row:nth-child(even) {
      background: rgba(0, 0, 0, 0.012);
    }

    .player-profile-personal-row:last-child {
      border-bottom: 0;
    }

    .player-profile-personal-row .label {
      color: #516889;
      font-size: 0.8rem;
      font-weight: 700;
      line-height: 1.2;
    }

    .player-profile-personal-row .value {
      color: #213962;
      font-size: 0.86rem;
      font-weight: 700;
      line-height: 1.25;
    }

    .player-profile-personal-row .value .record-line + .record-line {
      margin-top: 4px;
    }

    .player-profile-personal-row .value .subtle {
      color: #5f739a;
      font-weight: 600;
    }

    .status {
      margin-top: 10px;
      padding: 10px 12px;
      border-radius: 11px;
      background: #f2f5fb;
      border: 1px solid #d9e2f1;
      color: #324466;
      font-size: 0.9rem;
      display: none;
    }

    .loading {
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }

    .spinner {
      width: 14px;
      height: 14px;
      border-radius: 50%;
      border: 2px solid #9cb2de;
      border-top-color: #274b8e;
      animation: spin 0.8s linear infinite;
    }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    @keyframes matchModalPanelIn {
      from {
        opacity: 0;
        transform: translateY(10px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .match-modal:not([hidden]) .match-modal-backdrop {
      animation: matchModalBackdropIn 180ms ease-out;
    }

    @keyframes matchModalBackdropIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    @media (max-width: 760px) {
      .hero {
        grid-template-columns: 1fr;
        justify-items: center;
        text-align: center;
      }

      .logo {
        width: 96px;
        height: 96px;
      }

      .filters label {
        min-width: 47%;
      }

      .h2h-picker-shell,
      .h2h-summary-row {
        grid-template-columns: 1fr;
      }

      .player-profiles-shell {
        grid-template-columns: 1fr;
        gap: 12px;
      }

      .player-profiles-divider {
        width: 100%;
        height: 1px;
      }

      .player-profiles-grid {
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 12px 10px;
      }

      .player-profile-tile .avatar-wrap {
        width: 68px;
        height: 68px;
      }

      .player-profile-tile img {
        width: 60px;
        height: 60px;
      }

      .h2h-vs {
        text-align: center;
        padding: 2px 0;
      }

      .h2h-compare-head,
      .h2h-compare-row {
        grid-template-columns: 1fr;
      }

      .h2h-compare-vs {
        text-align: center;
      }

      .h2h-compare-label {
        min-width: 0;
      }

      .match-modal-matchup {
        grid-template-columns: 1fr;
        gap: 12px;
        padding: 14px;
      }

      .match-modal-vs {
        text-align: center;
        padding-top: 0;
      }

      .match-modal-content {
        padding: 18px;
      }

      .match-modal-header {
        padding: 14px 16px 10px;
      }

      .match-modal-panel {
        width: min(980px, 96vw);
      }

      .player-profile-head {
        grid-template-columns: 1fr;
        justify-items: center;
        text-align: center;
      }

      .player-profile-head .meta {
        justify-content: center;
      }

      .player-profile-overall-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
      }

      .player-profile-record-grid {
        grid-template-columns: 1fr;
      }

      .player-profile-personal-row {
        grid-template-columns: 1fr;
        gap: 4px;
      }

      .match-holeboards-grid.two {
        grid-template-columns: 1fr;
      }

      .match-holeboard td:first-child {
        width: 110px;
      }
    }
  </style>
</head>
<body>
  <div class="wrap">
    <header class="hero">
      <img class="logo" src="./assets/bcc_large_font.PNG" alt="Bluff City Cup logo">
      <div>
        <h1>Bluff City Cup Player Records</h1>
        <p>Interactive tournament history with team trends, player rankings, pairing records, and full match outcomes.</p>
      </div>
    </header>

    <main class="content">
      <section class="card">
        <h2>Points by Team by Year</h2>
        <p class="sub">Total points earned each year by Red and Blue.</p>
        <div class="chart-wrap">
          <canvas id="pointsChart"></canvas>
        </div>
        <div id="status" class="status"></div>
      </section>

      <section class="card">
        <h2>Player Profiles</h2>
        <p class="sub">Select a player photo to view a profile with bio and historical records.</p>
        <div class="player-profiles-shell">
          <div class="player-profiles-team red">
            <h3>Red Team</h3>
            <div id="playerProfileRedGrid" class="player-profiles-grid"></div>
          </div>
          <div class="player-profiles-divider" aria-hidden="true"></div>
          <div class="player-profiles-team blue">
            <h3>Blue Team</h3>
            <div id="playerProfileBlueGrid" class="player-profiles-grid"></div>
          </div>
        </div>
      </section>

      <section class="card">
        <h2>Overall Records by Team and Format</h2>
        <p class="sub">Filter by year.</p>
        <div class="filters">
          <label>Year
            <select id="teamFormatYear" multiple data-multi="true" data-placeholder="All years"></select>
          </label>
        </div>
        <div id="teamFormatSummary" class="h2h-summary"></div>
      </section>

      <section class="card">
        <h2>Head-to-Head Player Matchups</h2>
        <p class="sub">Select one Red player and one Blue player (players with uploaded photos only). Includes all formats, including partnered matches.</p>
        <div id="h2hPickerShell" class="h2h-picker-shell">
          <div class="h2h-team-panel red">
            <h3>Red Team</h3>
            <div id="h2hRedPicker" class="h2h-player-grid"></div>
          </div>
          <div class="h2h-team-panel blue">
            <h3>Blue Team</h3>
            <div id="h2hBluePicker" class="h2h-player-grid"></div>
          </div>
        </div>
        <div id="h2hSummary" class="h2h-summary"></div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Year</th>
                <th>Format</th>
                <th>Red Side</th>
                <th>Blue Side</th>
                <th>Result</th>
                <th>Score</th>
              </tr>
            </thead>
            <tbody id="h2hBody"></tbody>
          </table>
        </div>
      </section>

      <section class="card">
        <h2>Overall Records by Player</h2>
        <p class="sub">Filter by team, year, and format.</p>
        <div class="filters">
          <label>Team
            <select id="playerTeam"></select>
          </label>
          <label>Year
            <select id="playerYear" multiple data-multi="true" data-placeholder="All years"></select>
          </label>
          <label>Format
            <select id="playerFormat" multiple data-multi="true" data-placeholder="All formats"></select>
          </label>
          <label>Player
            <select id="playerPlayer" multiple data-multi="true" data-placeholder="All players"></select>
          </label>
          <label>Min Matches
            <input id="playerMinMatches" type="number" min="0" step="1" value="0">
          </label>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th class="sortable" data-table="player" data-key="rank">Rank</th>
                <th class="sortable" data-table="player" data-key="player">Player</th>
                <th class="sortable" data-table="player" data-key="team">Team</th>
                <th class="sortable" data-table="player" data-key="matches">Matches</th>
                <th class="sortable" data-table="player" data-key="wlt">W-L-T</th>
                <th class="sortable" data-table="player" data-key="points">Points</th>
                <th class="sortable" data-table="player" data-key="winPctValue">Win %</th>
                <th class="sortable" data-table="player" data-key="winTiePctValue">Win + Tie %</th>
              </tr>
            </thead>
            <tbody id="playerBody"></tbody>
          </table>
        </div>
      </section>

      <section class="card">
        <h2>Overall Records by 2-Man Pairings</h2>
        <p class="sub">Formats: Best Ball, Mod. Alt. Shot, 2-Man Scramble, Shamble. Filter by team, year, format, and player included.</p>
        <div class="filters">
          <label>Team
            <select id="pairTeam"></select>
          </label>
          <label>Year
            <select id="pairYear" multiple data-multi="true" data-placeholder="All years"></select>
          </label>
          <label id="pairFormatFilterLabel">Format
            <select id="pairFormat" multiple data-multi="true" data-placeholder="All formats"></select>
          </label>
          <label>Player Included
            <select id="pairPlayer" multiple data-multi="true" data-placeholder="All players"></select>
          </label>
          <label>Min Matches
            <input id="pairMinMatches" type="number" min="0" step="1" value="0">
          </label>
          <label class="check-filter">Format Detail
            <span><input id="pairIncludeFormatDetails" type="checkbox"> Include format breakdown</span>
          </label>
        </div>
        <div class="table-wrap">
          <table id="pairTable">
            <thead>
              <tr>
                <th class="sortable" data-table="pair" data-key="rank">Rank</th>
                <th class="sortable" data-table="pair" data-key="pair">Pairing</th>
                <th class="sortable" data-table="pair" data-key="team">Team</th>
                <th class="sortable pair-format-col" data-table="pair" data-key="format">Format</th>
                <th class="sortable" data-table="pair" data-key="matches">Matches</th>
                <th class="sortable" data-table="pair" data-key="wlt">W-L-T</th>
                <th class="sortable" data-table="pair" data-key="points">Points</th>
                <th class="sortable" data-table="pair" data-key="winPctValue">Win %</th>
                <th class="sortable" data-table="pair" data-key="winTiePctValue">Win + Tie %</th>
              </tr>
            </thead>
            <tbody id="pairBody"></tbody>
          </table>
        </div>
      </section>

      <section class="card">
        <h2>All Match Outcomes</h2>
        <p class="sub">Filter by team, year, format, and player included.</p>
        <div class="filters">
          <label>Team
            <select id="logTeam"></select>
          </label>
          <label>Year
            <select id="logYear" multiple data-multi="true" data-placeholder="All years"></select>
          </label>
          <label>Format
            <select id="logFormat" multiple data-multi="true" data-placeholder="All formats"></select>
          </label>
          <label>Player Included
            <select id="logPlayer"></select>
          </label>
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th class="sortable" data-table="log" data-key="year">Year</th>
                <th class="sortable" data-table="log" data-key="format">Format</th>
                <th class="sortable" data-table="log" data-key="redPlayers">Red Side</th>
                <th class="sortable" data-table="log" data-key="bluePlayers">Blue Side</th>
                <th class="sortable" data-table="log" data-key="winner">Winner</th>
                <th class="sortable" data-table="log" data-key="score">Score</th>
              </tr>
            </thead>
            <tbody id="logBody"></tbody>
          </table>
        </div>
      </section>
    </main>
  </div>

  <div id="matchModal" class="match-modal" hidden>
    <div class="match-modal-backdrop" data-match-modal-close></div>
    <div class="match-modal-panel" role="dialog" aria-modal="true" aria-labelledby="matchModalTitle">
      <div class="match-modal-header">
        <div id="matchModalTitle" class="match-modal-title">Match Details</div>
        <button id="matchModalClose" class="match-modal-close" type="button" aria-label="Close match details">×</button>
      </div>
      <div id="matchModalContent" class="match-modal-content"></div>
    </div>
  </div>

  <div id="playerProfileModal" class="match-modal" hidden>
    <div class="match-modal-backdrop" data-player-modal-close></div>
    <div class="match-modal-panel" role="dialog" aria-modal="true" aria-labelledby="playerProfileModalTitle">
      <div class="match-modal-header">
        <div id="playerProfileModalTitle" class="match-modal-title">Player Profile</div>
        <button id="playerProfileModalClose" class="match-modal-close" type="button" aria-label="Close player profile">×</button>
      </div>
      <div id="playerProfileModalContent" class="match-modal-content player-modal-content"></div>
    </div>
  </div>

  <script src="./assets/match_prob_tables.js"></script>
  <script>
    const TWO_MAN_FORMATS = new Set(['Best Ball', 'Mod. Alt. Shot', '2-Man Scramble', 'Shamble']);
    const SINGLES_FORMAT = 'Singles';
    const MATCH_PROJECTION_TABLES = (window.BCC_MATCH_PROB_TABLES && typeof window.BCC_MATCH_PROB_TABLES === 'object')
      ? window.BCC_MATCH_PROB_TABLES
      : {};

    const state = {
      rows: [],
      yearOutcomes: [],
      matchCourses: [],
      matchSummaries: [],
      playerBios: [],
      holes: [],
      holeScores: [],
      playerHandicaps: [],
      coursesMeta: [],
      tournamentSettings: [],
      playerPictures: [],
      headToHead: { Red: null, Blue: null },
      h2hMatchRows: [],
      logMatchRows: [],
      chart: null,
    };

    const sortState = {
      teamFormat: { key: 'format', dir: 'asc' },
      player: { key: 'rank', dir: 'asc' },
      pair: { key: 'rank', dir: 'asc' },
      singles: { key: 'rank', dir: 'asc' },
      log: { key: 'year', dir: 'desc' },
    };
    const multiControlState = {
      globalListenersBound: false,
      controls: new Map(),
    };

    const el = {
      status: document.getElementById('status'),
      playerProfileRedGrid: document.getElementById('playerProfileRedGrid'),
      playerProfileBlueGrid: document.getElementById('playerProfileBlueGrid'),
      teamFormatYear: document.getElementById('teamFormatYear'),
      teamFormatSummary: document.getElementById('teamFormatSummary'),
      h2hPickerShell: document.getElementById('h2hPickerShell'),
      h2hRedPicker: document.getElementById('h2hRedPicker'),
      h2hBluePicker: document.getElementById('h2hBluePicker'),
      h2hSummary: document.getElementById('h2hSummary'),
      h2hBody: document.getElementById('h2hBody'),
      playerTeam: document.getElementById('playerTeam'),
      playerYear: document.getElementById('playerYear'),
      playerFormat: document.getElementById('playerFormat'),
      playerPlayer: document.getElementById('playerPlayer'),
      playerMinMatches: document.getElementById('playerMinMatches'),
      playerBody: document.getElementById('playerBody'),
      pairTeam: document.getElementById('pairTeam'),
      pairYear: document.getElementById('pairYear'),
      pairFormatFilterLabel: document.getElementById('pairFormatFilterLabel'),
      pairFormat: document.getElementById('pairFormat'),
      pairPlayer: document.getElementById('pairPlayer'),
      pairMinMatches: document.getElementById('pairMinMatches'),
      pairIncludeFormatDetails: document.getElementById('pairIncludeFormatDetails'),
      pairTable: document.getElementById('pairTable'),
      pairBody: document.getElementById('pairBody'),
      logTeam: document.getElementById('logTeam'),
      logYear: document.getElementById('logYear'),
      logFormat: document.getElementById('logFormat'),
      logPlayer: document.getElementById('logPlayer'),
      logBody: document.getElementById('logBody'),
      matchModal: document.getElementById('matchModal'),
      matchModalClose: document.getElementById('matchModalClose'),
      matchModalContent: document.getElementById('matchModalContent'),
      playerProfileModal: document.getElementById('playerProfileModal'),
      playerProfileModalClose: document.getElementById('playerProfileModalClose'),
      playerProfileModalContent: document.getElementById('playerProfileModalContent'),
    };

    function showStatus(text, isError = false, loading = false) {
      el.status.style.display = 'block';
      el.status.style.background = isError ? '#ffe9ec' : '#f2f5fb';
      el.status.style.borderColor = isError ? '#f0b4bb' : '#d9e2f1';
      el.status.style.color = isError ? '#8f1a28' : '#324466';
      if (loading) {
        el.status.innerHTML = `<span class="loading"><span class="spinner"></span>${escapeHtml(text)}</span>`;
        return;
      }
      el.status.textContent = text;
    }

    function hideStatus() {
      el.status.style.display = 'none';
      el.status.textContent = '';
    }

    function initCollapsibleSections() {
      const cards = [...document.querySelectorAll('.content > .card')];
      cards.slice(1).forEach((card, index) => {
        if (card.dataset.collapsibleInitialized === 'true') {
          return;
        }

        const heading = card.querySelector('h2');
        if (!heading) {
          return;
        }

        const subtitle = card.querySelector('.sub');
        const anchorNode = subtitle || heading;
        const childNodes = [...card.childNodes];
        const anchorIndex = childNodes.indexOf(anchorNode);
        if (anchorIndex < 0) {
          return;
        }

        const body = document.createElement('div');
        body.className = 'collapsible-body';
        body.id = `collapsible-body-${index + 1}`;

        const toMove = childNodes.slice(anchorIndex + 1).filter(node => {
          if (node.nodeType === Node.TEXT_NODE) {
            return node.textContent.trim() !== '';
          }
          return true;
        });

        toMove.forEach(node => body.appendChild(node));
        if (!body.childNodes.length) {
          return;
        }

        const toggle = document.createElement('button');
        toggle.type = 'button';
        toggle.className = 'collapse-toggle';
        toggle.setAttribute('aria-expanded', 'true');
        toggle.setAttribute('aria-controls', body.id);
        toggle.setAttribute('aria-label', 'Collapse section');
        toggle.title = 'Collapse section';
        toggle.textContent = '▾';

        toggle.addEventListener('click', () => {
          const isOpen = !body.hidden;
          body.hidden = isOpen;
          toggle.setAttribute('aria-expanded', String(!isOpen));
          toggle.setAttribute('aria-label', isOpen ? 'Expand section' : 'Collapse section');
          toggle.title = isOpen ? 'Expand section' : 'Collapse section';
          toggle.textContent = isOpen ? '▸' : '▾';
        });

        anchorNode.insertAdjacentElement('afterend', body);
        card.appendChild(toggle);
        card.classList.add('collapsible-card');

        if (index >= 2) {
          body.hidden = true;
          toggle.setAttribute('aria-expanded', 'false');
          toggle.setAttribute('aria-label', 'Expand section');
          toggle.title = 'Expand section';
          toggle.textContent = '▸';
        }

        card.dataset.collapsibleInitialized = 'true';
      });
    }

    function normalize(value) {
      return String(value ?? '').trim();
    }

    function points(value) {
      const n = Number.parseFloat(String(value ?? '0'));
      return Number.isFinite(n) ? n : 0;
    }

    function minMatchesValue(input) {
      const value = Number.parseInt(String(input?.value ?? '0'), 10);
      return Number.isFinite(value) && value > 0 ? value : 0;
    }

    function pct(wins, ties, matches) {
      if (!matches) {
        return '0.0%';
      }
      return `${(((wins + (0.5 * ties)) / matches) * 100).toFixed(1)}%`;
    }

    function winTiePct(wins, ties, matches) {
      if (!matches) {
        return '0.0%';
      }
      return `${(((wins + ties) / matches) * 100).toFixed(1)}%`;
    }

    function playersInRow(row) {
      return [row.player1, row.player2, row.player3, row.player4]
        .map(normalize)
        .filter(Boolean);
    }

    function playerLastName(fullName) {
      const parts = normalize(fullName).split(/\s+/).filter(Boolean);
      return parts.length ? parts[parts.length - 1] : '';
    }

    function playerInitials(fullName) {
      const parts = normalize(fullName).split(/\s+/).filter(Boolean);
      if (!parts.length) {
        return '?';
      }
      if (parts.length === 1) {
        return parts[0].slice(0, 2).toUpperCase();
      }
      return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }

    function tournamentLocationForYear(year) {
      const targetYear = normalize(year);
      const match = (Array.isArray(state.yearOutcomes) ? state.yearOutcomes : []).find(item =>
        normalize(item.year) === targetYear
      );
      return normalize(match?.location);
    }

    function matchMetaForMatch(year, round, matchNum) {
      const targetYear = normalize(year);
      const targetRound = normalize(round);
      const targetMatch = normalize(matchNum);
      return (Array.isArray(state.matchCourses) ? state.matchCourses : []).find(item =>
        normalize(item.year) === targetYear &&
        normalize(item.round) === targetRound &&
        normalize(item.match) === targetMatch
      );
    }

    function matchSummaryForMatch(year, round, matchNum) {
      const targetYear = normalize(year);
      const targetRound = normalize(round);
      const targetMatch = normalize(matchNum);
      return (Array.isArray(state.matchSummaries) ? state.matchSummaries : []).find(item =>
        normalize(item.year) === targetYear &&
        normalize(item.round) === targetRound &&
        normalize(item.match) === targetMatch
      ) || null;
    }

    function courseForMatch(year, round, matchNum) {
      const match = matchMetaForMatch(year, round, matchNum);
      return normalize(match?.course);
    }

    function teesForMatch(year, round, matchNum) {
      const match = matchMetaForMatch(year, round, matchNum);
      return normalize(match?.tees);
    }

    function matchLengthForMatch(year, round, matchNum) {
      const match = matchMetaForMatch(year, round, matchNum);
      return normalize(match?.matchlength);
    }

    function floatOrNull(value) {
      const n = Number.parseFloat(normalize(value));
      return Number.isFinite(n) ? n : null;
    }

    function normalizeMatchFormatForHandicap(format) {
      const f = normalize(format);
      if (f === 'Mod. Alt. Shot' || f === 'Mod. Alt. Shot.') {
        return 'Alternate Shot';
      }
      if (f === '2-Man Scramble') {
        return 'Two Man Scramble';
      }
      if (f === '4-Man Scramble') {
        return 'Four Man Scramble';
      }
      return f;
    }

    function playerLookupKey(name) {
      return normalize(name).toLowerCase();
    }

    function courseMetaForCourseTees(course, tees) {
      const targetCourse = normalize(course);
      const targetTees = normalize(tees);
      return (Array.isArray(state.coursesMeta) ? state.coursesMeta : []).find(item =>
        normalize(item.course) === targetCourse &&
        normalize(item.tees) === targetTees
      ) || null;
    }

    function tournamentMaxHandicapForYear(year) {
      const targetYear = normalize(year);
      const item = (Array.isArray(state.tournamentSettings) ? state.tournamentSettings : []).find(row =>
        normalize(row.year) === targetYear
      );
      const value = intOrNull(item?.maxhandicap);
      return Number.isFinite(value) && value > 0 ? value : 30;
    }

    function playerHandicapIndexForYear(name, year, team = '') {
      const targetName = normalize(name);
      const targetYear = normalize(year);
      const targetTeam = normalize(team);
      const rows = (Array.isArray(state.playerHandicaps) ? state.playerHandicaps : []).filter(item =>
        normalize(item.year) === targetYear &&
        normalize(item.name) === targetName
      );
      if (!rows.length) {
        return null;
      }
      const exactTeam = rows.find(item => normalize(item.team) === targetTeam);
      const match = exactTeam || rows[0];
      return floatOrNull(match?.handicap);
    }

    function courseHandicapFromIndex(playerHandicap, slope, rating, par, maxHandicap) {
      if (![playerHandicap, slope, rating, par, maxHandicap].every(Number.isFinite)) {
        return null;
      }
      return Math.min(Math.round((playerHandicap * (slope / 113)) + (rating - par)), maxHandicap);
    }

    function shambleCourseHandicapFromIndex(playerHandicap, slope, rating, par, maxHandicap) {
      if (![playerHandicap, slope, rating, par, maxHandicap].every(Number.isFinite)) {
        return null;
      }
      return Math.min(Math.round(0.8 * ((playerHandicap * (slope / 113)) + (rating - par))), maxHandicap);
    }

    function fourManScrambleTeamHandicapFromIndexes(indexes, slope, maxHandicap) {
      if (!Array.isArray(indexes) || indexes.length < 4 || !Number.isFinite(slope) || !Number.isFinite(maxHandicap)) {
        return null;
      }
      const weights = [0.20, 0.15, 0.10, 0.05];
      const courseHdcps = indexes.map(value => {
        if (!Number.isFinite(value)) {
          return null;
        }
        return Math.min(Math.round(value * (slope / 113)), maxHandicap);
      });
      if (courseHdcps.some(value => !Number.isFinite(value))) {
        return null;
      }
      return Math.round(courseHdcps.reduce((sum, value, idx) => sum + (value * weights[idx]), 0));
    }

    function twoPlayerTeamHandicapFromIndexes(format, p1Index, p2Index, slope, rating, par, maxHandicap) {
      const p1 = courseHandicapFromIndex(p1Index, slope, rating, par, maxHandicap);
      const p2 = courseHandicapFromIndex(p2Index, slope, rating, par, maxHandicap);
      if (!Number.isFinite(p1) || !Number.isFinite(p2)) {
        return null;
      }
      if (format === 'Alternate Shot') {
        return Math.round((p1 * 0.5) + (p2 * 0.5));
      }
      if (format === 'Two Man Scramble') {
        return Math.round((p1 * 0.35) + (p2 * 0.15));
      }
      return null;
    }

    function handicapScoreForDisplay(actualScore, matchHandicap, holeHandicap) {
      if (!Number.isFinite(actualScore)) {
        return null;
      }
      if (!Number.isFinite(matchHandicap) || !Number.isFinite(holeHandicap) || actualScore <= 0) {
        return actualScore;
      }
      if (matchHandicap >= 36) {
        return actualScore - (((matchHandicap - 36) >= holeHandicap) ? 3 : 2);
      }
      if (matchHandicap >= 18) {
        return actualScore - (((matchHandicap - 18) >= holeHandicap) ? 2 : 1);
      }
      return actualScore - (matchHandicap >= holeHandicap ? 1 : 0);
    }

    function buildNetScoreContext(match, course, tees, redPlayers, bluePlayers) {
      const courseMeta = courseMetaForCourseTees(course, tees);
      const slope = intOrNull(courseMeta?.slope);
      const rating = floatOrNull(courseMeta?.rating);
      const par = floatOrNull(courseMeta?.par);
      const maxHandicap = tournamentMaxHandicapForYear(match.year);
      if (![slope, rating, par, maxHandicap].every(Number.isFinite)) {
        return { enabled: false, label: 'Actual', reason: 'course-meta' };
      }

      const format = normalizeMatchFormatForHandicap(match.format);
      const allPlayers = [
        ...redPlayers.map(name => ({ name, team: 'Red' })),
        ...bluePlayers.map(name => ({ name, team: 'Blue' })),
      ].filter(item => normalize(item.name));

      const playerIndexes = new Map();
      for (const player of allPlayers) {
        const index = playerHandicapIndexForYear(player.name, match.year, player.team);
        if (!Number.isFinite(index)) {
          return { enabled: false, label: 'Actual', reason: 'player-handicap' };
        }
        playerIndexes.set(playerLookupKey(player.name), Number(index));
      }

      const playerStrokes = new Map();
      const teamStrokes = new Map();
      const redKey = 'red';
      const blueKey = 'blue';

      const singlesCourseHdcpFor = (name) => courseHandicapFromIndex(
        playerIndexes.get(playerLookupKey(name)),
        slope,
        rating,
        par,
        maxHandicap
      );
      const shambleCourseHdcpFor = (name) => shambleCourseHandicapFromIndex(
        playerIndexes.get(playerLookupKey(name)),
        slope,
        rating,
        par,
        maxHandicap
      );

      if (format === 'Singles') {
        const participants = [...redPlayers, ...bluePlayers].filter(Boolean);
        const hdcps = participants.map(name => ({ name, value: singlesCourseHdcpFor(name) }));
        if (!hdcps.length || hdcps.some(item => !Number.isFinite(item.value))) {
          return { enabled: false, label: 'Actual', reason: 'singles-hdcps' };
        }
        const low = Math.min(...hdcps.map(item => Number(item.value)));
        hdcps.forEach(item => playerStrokes.set(playerLookupKey(item.name), Number(item.value) - low));
        return { enabled: true, label: 'Net', playerStrokes, teamStrokes };
      }

      if (format === 'Best Ball') {
        const hdcps = allPlayers.map(item => ({ name: item.name, value: singlesCourseHdcpFor(item.name) }));
        if (!hdcps.length || hdcps.some(item => !Number.isFinite(item.value))) {
          return { enabled: false, label: 'Actual', reason: 'bestball-hdcps' };
        }
        const low = Math.min(...hdcps.map(item => Number(item.value)));
        hdcps.forEach(item => playerStrokes.set(playerLookupKey(item.name), Number(item.value) - low));
        return { enabled: true, label: 'Net', playerStrokes, teamStrokes };
      }

      if (format === 'Shamble') {
        const hdcps = allPlayers.map(item => ({ name: item.name, value: shambleCourseHdcpFor(item.name) }));
        if (!hdcps.length || hdcps.some(item => !Number.isFinite(item.value))) {
          return { enabled: false, label: 'Actual', reason: 'shamble-hdcps' };
        }
        const low = Math.min(...hdcps.map(item => Number(item.value)));
        hdcps.forEach(item => playerStrokes.set(playerLookupKey(item.name), Number(item.value) - low));
        return { enabled: true, label: 'Net', playerStrokes, teamStrokes };
      }

      if (format === 'Alternate Shot' || format === 'Two Man Scramble') {
        const redIndexes = redPlayers.map(name => playerIndexes.get(playerLookupKey(name))).filter(Number.isFinite);
        const blueIndexes = bluePlayers.map(name => playerIndexes.get(playerLookupKey(name))).filter(Number.isFinite);

        let redTeam = null;
        let blueTeam = null;

        if (redIndexes.length >= 2) {
          redTeam = twoPlayerTeamHandicapFromIndexes(format, redIndexes[0], redIndexes[1], slope, rating, par, maxHandicap);
        } else if (redIndexes.length === 1) {
          redTeam = courseHandicapFromIndex(redIndexes[0], slope, rating, par, maxHandicap);
        }

        if (blueIndexes.length >= 2) {
          blueTeam = twoPlayerTeamHandicapFromIndexes(format, blueIndexes[0], blueIndexes[1], slope, rating, par, maxHandicap);
        } else if (blueIndexes.length === 1) {
          blueTeam = courseHandicapFromIndex(blueIndexes[0], slope, rating, par, maxHandicap);
        }

        if (!Number.isFinite(redTeam) || !Number.isFinite(blueTeam)) {
          return { enabled: false, label: 'Actual', reason: 'team-hdcps' };
        }

        if (blueTeam < redTeam) {
          teamStrokes.set(blueKey, 0);
          teamStrokes.set(redKey, redTeam - blueTeam);
        } else {
          teamStrokes.set(redKey, 0);
          teamStrokes.set(blueKey, blueTeam - redTeam);
        }
        return { enabled: true, label: 'Net', playerStrokes, teamStrokes };
      }

      if (format === 'Four Man Scramble') {
        const redIndexes = redPlayers.map(name => playerIndexes.get(playerLookupKey(name)));
        const blueIndexes = bluePlayers.map(name => playerIndexes.get(playerLookupKey(name)));
        const redTeam = fourManScrambleTeamHandicapFromIndexes(redIndexes, slope, maxHandicap);
        const blueTeam = fourManScrambleTeamHandicapFromIndexes(blueIndexes, slope, maxHandicap);
        if (!Number.isFinite(redTeam) || !Number.isFinite(blueTeam)) {
          return { enabled: false, label: 'Actual', reason: '4man-team-hdcps' };
        }
        if (blueTeam < redTeam) {
          teamStrokes.set(blueKey, 0);
          teamStrokes.set(redKey, redTeam - blueTeam);
        } else {
          teamStrokes.set(redKey, 0);
          teamStrokes.set(blueKey, blueTeam - redTeam);
        }
        return { enabled: true, label: 'Net', playerStrokes, teamStrokes };
      }

      return { enabled: false, label: 'Actual', reason: 'unsupported-format' };
    }

    function intOrNull(value) {
      const n = Number.parseInt(normalize(value), 10);
      return Number.isFinite(n) ? n : null;
    }

    function sumNullableNumbers(values) {
      return values.reduce((sum, value) => sum + (Number.isFinite(value) ? Number(value) : 0), 0);
    }

    function isBestBallFormat(format) {
      return normalize(format) === 'Best Ball';
    }

    function isTeamAggregateScoreFormat(format) {
      const f = normalize(format);
      return f === '2-Man Scramble'
        || f === 'Mod. Alt. Shot'
        || f === 'Shamble'
        || f === '4-Man Scramble';
    }

    function buildHoleBoardModel(match) {
      const meta = matchMetaForMatch(match.year, match.round, match.match);
      const course = normalize(meta?.course);
      const tees = normalize(meta?.tees);
      const matchLength = intOrNull(meta?.matchlength);
      const startHoleRaw = intOrNull(meta?.startinghole);
      if (!course || !tees || !matchLength) {
        return null;
      }
      const startHole = Number.isFinite(startHoleRaw) && startHoleRaw >= 1 && startHoleRaw <= 18
        ? startHoleRaw
        : 1;
      const endHole = Math.min(18, startHole + matchLength - 1);
      if (endHole < startHole) {
        return null;
      }

      const holeDefs = (Array.isArray(state.holes) ? state.holes : [])
        .filter(item =>
          normalize(item.course) === course &&
          normalize(item.tees) === tees
        )
        .map(item => ({
          hole: intOrNull(item.holenumber),
          handicap: intOrNull(item.handicap),
          par: intOrNull(item.par),
          length: intOrNull(item.length),
        }))
        .filter(item => item.hole !== null && item.hole >= startHole && item.hole <= endHole)
        .sort((a, b) => Number(a.hole) - Number(b.hole));

      if (!holeDefs.length) {
        return null;
      }

      const redPlayers = (Array.isArray(match.redPlayers) ? match.redPlayers : []).map(normalize).filter(Boolean);
      const bluePlayers = (Array.isArray(match.bluePlayers) ? match.bluePlayers : []).map(normalize).filter(Boolean);
      const holeHandicapByHole = new Map(holeDefs.map(def => [Number(def.hole), intOrNull(def.handicap)]));
      const netContext = buildNetScoreContext(match, course, tees, redPlayers, bluePlayers);
      const participantSet = new Set([...redPlayers, ...bluePlayers].map(name => name.toLowerCase()));
      const targetYear = normalize(match.year);
      const targetRound = normalize(match.round);

      const scoreLookup = new Map();
      (Array.isArray(state.holeScores) ? state.holeScores : []).forEach(item => {
        if (normalize(item.year) !== targetYear) {
          return;
        }
        if (normalize(item.round) !== targetRound) {
          return;
        }
        if (course && normalize(item.course) !== course) {
          return;
        }
        const player = normalize(item.player);
        if (!participantSet.has(player.toLowerCase())) {
          return;
        }
        const hole = intOrNull(item.hole);
        const score = intOrNull(item.actualscore);
        if (hole === null || score === null || hole < startHole || hole > endHole) {
          return;
        }
        scoreLookup.set(`${player.toLowerCase()}|${hole}`, score);
      });

      const holeNumbers = holeDefs.map(h => Number(h.hole));
      const scoreForPlayerHole = (player, hole) => {
        const key = `${normalize(player).toLowerCase()}|${hole}`;
        return scoreLookup.has(key) ? scoreLookup.get(key) : null;
      };

      const displayScoreForPlayerHole = (player, hole) => {
        const actual = scoreForPlayerHole(player, hole);
        if (!netContext.enabled) {
          return actual;
        }
        const strokes = netContext.playerStrokes.get(playerLookupKey(player));
        const holeHandicap = holeHandicapByHole.get(Number(hole));
        return handicapScoreForDisplay(actual, strokes, holeHandicap);
      };

      const displayScoreForTeamHole = (team, players, hole) => {
        const actual = players
          .map(player => scoreForPlayerHole(player, hole))
          .find(value => value !== null && Number.isFinite(value));
        if (!netContext.enabled) {
          return actual ?? null;
        }
        const strokes = netContext.teamStrokes.get(normalize(team).toLowerCase());
        const holeHandicap = holeHandicapByHole.get(Number(hole));
        return handicapScoreForDisplay(actual ?? null, strokes, holeHandicap);
      };

      const makePlayerRow = (team, player) => ({
        team,
        label: playerLastName(player),
        values: new Map(holeNumbers.map(hole => [hole, displayScoreForPlayerHole(player, hole)])),
        highlightHoles: new Set(),
      });

      const makeTeamRow = (team, players) => ({
        team,
        label: players.map(playerLastName).join(' / '),
        values: new Map(holeNumbers.map(hole => [hole, displayScoreForTeamHole(team, players, hole)])),
        highlightHoles: new Set(),
      });

      let rows = [];
      if (isTeamAggregateScoreFormat(match.format)) {
        rows = [
          makeTeamRow('Red', redPlayers),
          makeTeamRow('Blue', bluePlayers),
        ];
      } else if (isBestBallFormat(match.format)) {
        rows = [
          ...redPlayers.map(player => makePlayerRow('Red', player)),
          ...bluePlayers.map(player => makePlayerRow('Blue', player)),
        ];
      } else {
        rows = [
          ...redPlayers.map(player => makePlayerRow('Red', player)),
          ...bluePlayers.map(player => makePlayerRow('Blue', player)),
        ];
      }

      const redIndexes = rows.map((row, index) => row.team === 'Red' ? index : -1).filter(index => index >= 0);
      const blueIndexes = rows.map((row, index) => row.team === 'Blue' ? index : -1).filter(index => index >= 0);

      holeNumbers.forEach(hole => {
        const redScores = redIndexes
          .map(index => ({ index, score: rows[index].values.get(hole) }))
          .filter(item => Number.isFinite(item.score));
        const blueScores = blueIndexes
          .map(index => ({ index, score: rows[index].values.get(hole) }))
          .filter(item => Number.isFinite(item.score));

        if (!redScores.length || !blueScores.length) {
          return;
        }

        if (isBestBallFormat(match.format)) {
          const redBest = Math.min(...redScores.map(item => Number(item.score)));
          const blueBest = Math.min(...blueScores.map(item => Number(item.score)));
          if (redBest < blueBest) {
            redScores.filter(item => Number(item.score) === redBest).forEach(item => rows[item.index].highlightHoles.add(hole));
          } else if (blueBest < redBest) {
            blueScores.filter(item => Number(item.score) === blueBest).forEach(item => rows[item.index].highlightHoles.add(hole));
          }
          return;
        }

        const redBest = Math.min(...redScores.map(item => Number(item.score)));
        const blueBest = Math.min(...blueScores.map(item => Number(item.score)));
        if (redBest < blueBest) {
          redScores.filter(item => Number(item.score) === redBest).forEach(item => rows[item.index].highlightHoles.add(hole));
        } else if (blueBest < redBest) {
          blueScores.filter(item => Number(item.score) === blueBest).forEach(item => rows[item.index].highlightHoles.add(hole));
        }
      });

      const front = holeDefs.filter(h => Number(h.hole) <= 9);
      const back = holeDefs.filter(h => Number(h.hole) >= 10);
      const segments = [];
      if (front.length) {
        segments.push({ label: back.length ? 'OUT' : 'TOTAL', holes: front });
      }
      if (back.length) {
        segments.push({ label: 'IN', holes: back });
      }

      return { course, tees, matchLength, segments, rows, scoreDisplay: netContext.enabled ? 'Net' : 'Actual' };
    }

    function renderHoleBoardSegment(segment, rows) {
      const holeNums = segment.holes.map(h => Number(h.hole));
      const cellHtml = (value, classes = '') => {
        const missing = value === null || value === undefined || !Number.isFinite(value);
        const text = missing ? '-' : String(value);
        const cls = ['cell-score', missing ? 'missing' : '', classes].filter(Boolean).join(' ');
        return `<span class="${cls}">${escapeHtml(text)}</span>`;
      };
      const metaTotal = (key) => sumNullableNumbers(segment.holes.map(h => Number.isFinite(h[key]) ? h[key] : 0));

      const scoreRowsHtml = rows.map(row => {
        const total = sumNullableNumbers(holeNums.map(hole => row.values.get(hole)));
        return `<tr class="score-row ${normalize(row.team).toLowerCase()}">
          <td>${escapeHtml(row.label)}</td>
          ${holeNums.map(hole => {
            const value = row.values.get(hole);
            const winClass = row.highlightHoles.has(hole) ? `win-${normalize(row.team).toLowerCase()}` : '';
            return `<td>${cellHtml(value, winClass)}</td>`;
          }).join('')}
          <td>${escapeHtml(String(total))}</td>
        </tr>`;
      }).join('');

      return `
        <div class="match-holeboard">
          <table>
            <tbody>
              <tr class="meta-row">
                <td>HOLE</td>
                ${segment.holes.map(h => `<td>${escapeHtml(String(h.hole))}</td>`).join('')}
                <td>${escapeHtml(segment.label)}</td>
              </tr>
              <tr class="meta-row">
                <td>HDCP</td>
                ${segment.holes.map(h => `<td>${escapeHtml(String(h.handicap ?? '-'))}</td>`).join('')}
                <td></td>
              </tr>
              <tr class="meta-row">
                <td>PAR</td>
                ${segment.holes.map(h => `<td>${escapeHtml(String(h.par ?? '-'))}</td>`).join('')}
                <td>${escapeHtml(String(metaTotal('par')))}</td>
              </tr>
              <tr class="meta-row">
                <td>YDS</td>
                ${segment.holes.map(h => `<td>${escapeHtml(String(h.length ?? '-'))}</td>`).join('')}
                <td>${escapeHtml(String(metaTotal('length')))}</td>
              </tr>
              ${scoreRowsHtml}
            </tbody>
          </table>
        </div>
      `;
    }

    function renderCombinedHoleBoard(model) {
      const front = model.segments[0];
      const back = model.segments[1];
      if (!front || !back) {
        return '';
      }

      const frontHoleNums = front.holes.map(h => Number(h.hole));
      const backHoleNums = back.holes.map(h => Number(h.hole));
      const cellHtml = (value, classes = '') => {
        const missing = value === null || value === undefined || !Number.isFinite(value);
        const text = missing ? '-' : String(value);
        const cls = ['cell-score', missing ? 'missing' : '', classes].filter(Boolean).join(' ');
        return `<span class="${cls}">${escapeHtml(text)}</span>`;
      };
      const segTotal = (holes, key) => sumNullableNumbers(holes.map(h => Number.isFinite(h[key]) ? h[key] : 0));

      const rowHtml = (label, frontCells, frontTotalCell, backCells, backTotalCell, rowClass = '') => `
        <tr class="${rowClass}">
          <td>${label}</td>
          ${frontCells}
          ${frontTotalCell}
          ${backCells}
          ${backTotalCell}
        </tr>
      `;

      const metaFrontCells = (key) => front.holes.map(h => `<td>${escapeHtml(String(h[key] ?? '-'))}</td>`).join('');
      const metaBackCells = (key) => back.holes.map((h, idx) => `<td class="${idx === 0 ? 'seg-divider' : ''}">${escapeHtml(String(h[key] ?? '-'))}</td>`).join('');

      const scoreRowsHtml = model.rows.map(row => {
        const frontTotal = sumNullableNumbers(frontHoleNums.map(hole => row.values.get(hole)));
        const backTotal = sumNullableNumbers(backHoleNums.map(hole => row.values.get(hole)));
        const frontCells = frontHoleNums.map(hole => {
          const value = row.values.get(hole);
          const winClass = row.highlightHoles.has(hole) ? `win-${normalize(row.team).toLowerCase()}` : '';
          return `<td>${cellHtml(value, winClass)}</td>`;
        }).join('');
        const backCells = backHoleNums.map((hole, idx) => {
          const value = row.values.get(hole);
          const winClass = row.highlightHoles.has(hole) ? `win-${normalize(row.team).toLowerCase()}` : '';
          return `<td class="${idx === 0 ? 'seg-divider' : ''}">${cellHtml(value, winClass)}</td>`;
        }).join('');
        return rowHtml(
          escapeHtml(row.label),
          frontCells,
          `<td class="seg-total">${escapeHtml(String(frontTotal))}</td>`,
          backCells,
          `<td class="seg-total">${escapeHtml(String(backTotal))}</td>`,
          `score-row ${normalize(row.team).toLowerCase()}`
        );
      }).join('');

      return `
        <div class="match-holeboard combined-18">
          <table>
            <tbody>
              ${rowHtml(
                'HOLE',
                front.holes.map(h => `<td>${escapeHtml(String(h.hole))}</td>`).join(''),
                `<td class="seg-total">${escapeHtml(front.label)}</td>`,
                back.holes.map((h, idx) => `<td class="${idx === 0 ? 'seg-divider' : ''}">${escapeHtml(String(h.hole))}</td>`).join(''),
                `<td class="seg-total">${escapeHtml(back.label)}</td>`,
                'meta-row'
              )}
              ${rowHtml(
                'HDCP',
                metaFrontCells('handicap'),
                '<td class="seg-total"></td>',
                metaBackCells('handicap'),
                '<td class="seg-total"></td>',
                'meta-row'
              )}
              ${rowHtml(
                'PAR',
                metaFrontCells('par'),
                `<td class="seg-total">${escapeHtml(String(segTotal(front.holes, 'par')))}</td>`,
                metaBackCells('par'),
                `<td class="seg-total">${escapeHtml(String(segTotal(back.holes, 'par')))}</td>`,
                'meta-row'
              )}
              ${rowHtml(
                'YDS',
                metaFrontCells('length'),
                `<td class="seg-total">${escapeHtml(String(segTotal(front.holes, 'length')))}</td>`,
                metaBackCells('length'),
                `<td class="seg-total">${escapeHtml(String(segTotal(back.holes, 'length')))}</td>`,
                'meta-row'
              )}
              ${scoreRowsHtml}
            </tbody>
          </table>
        </div>
      `;
    }

    function renderHoleBoards(match) {
      const model = buildHoleBoardModel(match);
      if (!model || !Array.isArray(model.segments) || !model.segments.length) {
        return '<div class="match-holeboards-empty">Hole-by-hole scores are not available for this match.</div>';
      }
      const isNet = normalize(model.scoreDisplay) === 'Net';
      const noteHtml = `<div class="match-holeboards-note">Hole-by-hole scores shown are ${isNet ? 'NET (handicap-adjusted)' : 'actual'}.</div>`;

      if (model.segments.length === 2) {
        return `<div class="match-holeboards">${noteHtml}${renderCombinedHoleBoard(model)}</div>`;
      }

      const gridClass = `match-holeboards-grid ${model.segments.length > 1 ? 'two' : 'one'}`;
      return `
        <div class="match-holeboards">
          ${noteHtml}
          <div class="${gridClass}">
            ${model.segments.map(segment => renderHoleBoardSegment(segment, model.rows)).join('')}
          </div>
        </div>
      `;
    }

    function pctNumber(probabilityText) {
      const value = Number.parseFloat(normalize(probabilityText));
      return Number.isFinite(value) ? (value * 100) : null;
    }

    function projectionFormatForTable(format) {
      return normalizeMatchFormatForHandicap(format);
    }

    function projectionLookupStatic(format, matchLength, startingHole, hole, scoreDiff) {
      const fmt = projectionFormatForTable(format);
      const lengthKey = String(intOrNull(matchLength) ?? '');
      const relativeHole = (intOrNull(hole) ?? 0) - (intOrNull(startingHole) ?? 0) + 1;
      const relativeKey = String(relativeHole);
      const diffKey = String(intOrNull(scoreDiff) ?? 0);
      const row = MATCH_PROJECTION_TABLES?.[fmt]?.[lengthKey]?.[relativeKey]?.[diffKey];
      if (!row || typeof row !== 'object') {
        return null;
      }
      return {
        blue: (Number(row.blueWin) * 100),
        red: (Number(row.redWin) * 100),
        tie: (Number(row.tie) * 100),
      };
    }

    function projectionPathFromPoints(points, xFor, yFor, key) {
      let path = '';
      points.forEach((point, idx) => {
        const value = point[key];
        if (!Number.isFinite(value)) {
          return;
        }
        const x = xFor(idx);
        const y = yFor(value);
        path += `${path ? ' L ' : 'M '}${x} ${y}`;
      });
      return path;
    }

    function projectionDots(points, xFor, yFor, key, cls) {
      return points.map((point, idx) => {
        const value = point[key];
        if (!Number.isFinite(value)) {
          return '';
        }
        const x = xFor(idx);
        const y = yFor(value);
        return `<circle class="${cls}" cx="${x}" cy="${y}" r="4"></circle>`;
      }).join('');
    }

    function renderMatchProjection(match) {
      const model = buildHoleBoardModel(match);
      const meta = matchMetaForMatch(match.year, match.round, match.match);
      if (!model || !meta) {
        return '';
      }
      const startingHole = intOrNull(meta.startinghole) ?? intOrNull(model.segments?.[0]?.holes?.[0]?.hole) ?? 1;
      const matchLength = intOrNull(meta.matchlength) ?? intOrNull(model.matchLength) ?? 9;
      const projectionFormat = projectionFormatForTable(match.format);
      if (!MATCH_PROJECTION_TABLES?.[projectionFormat]?.[String(matchLength)]) {
        return `<div class="match-projection"><div class="match-projection-title">Match Projections</div><div class="match-projection-empty">Projection model is not available for ${escapeHtml(match.format)}.</div></div>`;
      }

      const holeOrder = model.segments.flatMap(segment => segment.holes.map(h => Number(h.hole)));
      const redRows = model.rows.filter(row => normalize(row.team) === 'Red');
      const blueRows = model.rows.filter(row => normalize(row.team) === 'Blue');
      if (!holeOrder.length || !redRows.length || !blueRows.length) {
        return '';
      }

      const bestTeamScore = (teamRows, hole) => {
        const values = teamRows.map(row => row.values.get(hole)).filter(value => Number.isFinite(value));
        return values.length ? Math.min(...values.map(Number)) : null;
      };

      const played = [];
      holeOrder.forEach(hole => {
        const redBest = bestTeamScore(redRows, hole);
        const blueBest = bestTeamScore(blueRows, hole);
        if (!Number.isFinite(redBest) || !Number.isFinite(blueBest)) {
          return;
        }
        let winner = 'AS';
        if (blueBest < redBest) {
          winner = 'Blue';
        } else if (redBest < blueBest) {
          winner = 'Red';
        }
        played.push({ hole, winner });
      });

      const points = [];
      const winnerTag = normalize(match.winner);
      const deterministicFinal = () => {
        if (winnerTag === 'Blue') return { blue: 100, red: 0, tie: 0 };
        if (winnerTag === 'Red') return { blue: 0, red: 100, tie: 0 };
        if (winnerTag === 'Tie') return { blue: 0, red: 0, tie: 100 };
        return null;
      };

      if (!played.length) {
        const initial = projectionLookupStatic(match.format, matchLength, startingHole, startingHole, 0);
        if (initial) {
          points.push({ hole: startingHole, diff: 0, ...initial });
        }
      } else {
        const firstHole = played[0].hole;
        const initial = projectionLookupStatic(match.format, matchLength, startingHole, firstHole, 0);
        if (initial) {
          points.push({ hole: firstHole, diff: 0, ...initial });
        }

        let blueWins = 0;
        let redWins = 0;
        for (let idx = 1; idx < played.length; idx += 1) {
          const prev = played[idx - 1];
          if (prev.winner === 'Blue') {
            blueWins += 1;
          } else if (prev.winner === 'Red') {
            redWins += 1;
          }
          const diff = blueWins - redWins;
          const hole = played[idx].hole;
          const prob = projectionLookupStatic(match.format, matchLength, startingHole, hole, diff);
          if (!prob) {
            continue;
          }
          points.push({
            hole,
            diff,
            blue: prob.blue,
            tie: prob.tie,
            red: prob.red,
          });
        }
      }

      if (!points.length) {
        return '<div class="match-projection"><div class="match-projection-title">Match Projections</div><div class="match-projection-empty">Projection values were not found for this match state.</div></div>';
      }

      points.forEach(point => {
        if (!Number.isFinite(point.blue)) point.blue = null;
        if (!Number.isFinite(point.tie)) point.tie = null;
        if (!Number.isFinite(point.red)) point.red = null;
      });

      const finalPoint = points[points.length - 1];

      if (!Number.isFinite(finalPoint.blue) || !Number.isFinite(finalPoint.tie) || !Number.isFinite(finalPoint.red)) {
        return '<div class="match-projection"><div class="match-projection-title">Match Projections</div><div class="match-projection-empty">Projection values are incomplete for this match state.</div></div>';
      }

      const normalizedPoints = points.map(point => ({
        hole: point.hole,
        diff: point.diff,
        blue: point.blue,
        tie: point.tie,
        red: point.red,
      }));

      const finalDisplay = normalizedPoints[normalizedPoints.length - 1];
      const summaryDisplay = deterministicFinal() || finalDisplay;

      const pctText = value => `${(Number.isFinite(value) ? value : 0).toFixed(1)}%`;

      const width = 720;
      const height = 260;
      const margin = { top: 18, right: 44, bottom: 34, left: 34 };
      const plotWidth = width - margin.left - margin.right;
      const plotHeight = height - margin.top - margin.bottom;
      const step = normalizedPoints.length > 1 ? (plotWidth / (normalizedPoints.length - 1)) : 0;
      const xFor = idx => Math.round((margin.left + (idx * step)) * 10) / 10;
      const yFor = value => Math.round((margin.top + ((100 - value) / 100) * plotHeight) * 10) / 10;

      const gridVals = [0, 25, 50, 75, 100];
      const xLabelY = height - 8;
      const bluePath = projectionPathFromPoints(normalizedPoints, xFor, yFor, 'blue');
      const tiePath = projectionPathFromPoints(normalizedPoints, xFor, yFor, 'tie');
      const redPath = projectionPathFromPoints(normalizedPoints, xFor, yFor, 'red');

      const svg = `
        <svg viewBox="0 0 ${width} ${height}" role="img" aria-label="Match projection probabilities by hole">
          ${gridVals.map(val => {
            const y = yFor(val);
            const dashed = (val === 25 || val === 75) ? ' stroke-dasharray=\"6 6\"' : '';
            return `<line x1="${margin.left}" y1="${y}" x2="${width - margin.right}" y2="${y}" stroke="#d8dfec" stroke-width="1"${dashed}></line>`;
          }).join('')}
          <line x1="${margin.left}" y1="${margin.top}" x2="${margin.left}" y2="${height - margin.bottom}" stroke="#dbe3f2" stroke-width="1"></line>
          <line x1="${margin.left}" y1="${height - margin.bottom}" x2="${width - margin.right}" y2="${height - margin.bottom}" stroke="#dbe3f2" stroke-width="1"></line>
          ${bluePath ? `<path d="${bluePath}" fill="none" stroke="#17367e" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"></path>` : ''}
          ${tiePath ? `<path d="${tiePath}" fill="none" stroke="#8d919a" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"></path>` : ''}
          ${redPath ? `<path d="${redPath}" fill="none" stroke="#b20b1c" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"></path>` : ''}
          ${projectionDots(normalizedPoints, xFor, yFor, 'blue', 'proj-dot-blue')}
          ${projectionDots(normalizedPoints, xFor, yFor, 'tie', 'proj-dot-tie')}
          ${projectionDots(normalizedPoints, xFor, yFor, 'red', 'proj-dot-red')}
          ${normalizedPoints.map((point, idx) => `<text x="${xFor(idx)}" y="${xLabelY}" fill="#7f8898" font-size="12" text-anchor="middle">${escapeHtml(String(point.hole))}</text>`).join('')}
          <text x="${width - margin.right + 6}" y="${yFor(100) + 4}" fill="#7f8898" font-size="12" text-anchor="start">100</text>
          <text x="${width - margin.right + 6}" y="${yFor(50) + 4}" fill="#7f8898" font-size="12" text-anchor="start">50</text>
          <text x="${width - margin.right + 6}" y="${yFor(0) + 4}" fill="#7f8898" font-size="12" text-anchor="start">0</text>
          <style>
            .proj-dot-blue { fill: #fff; stroke: #17367e; stroke-width: 2; }
            .proj-dot-red { fill: #fff; stroke: #b20b1c; stroke-width: 2; }
            .proj-dot-tie { fill: #fff; stroke: #8d919a; stroke-width: 2; }
          </style>
        </svg>`;

      return `
        <div class="match-projection">
          <div class="match-projection-title">Match Projections</div>
          <div class="match-projection-chart">${svg}</div>
          <div class="match-projection-summary">
            <div class="match-projection-summary-row"><span class="label blue">Blue</span><span>${escapeHtml(pctText(summaryDisplay.blue))}</span></div>
            <div class="match-projection-summary-row"><span class="label tie">Tie</span><span>${escapeHtml(pctText(summaryDisplay.tie))}</span></div>
            <div class="match-projection-summary-row"><span class="label red">Red</span><span>${escapeHtml(pctText(summaryDisplay.red))}</span></div>
          </div>
          <div class="match-projection-footer">Powered by <b>MontyRatings AI</b></div>
        </div>
      `;
    }

    function playerNameKey(fullName) {
      const parts = normalize(fullName).toLowerCase().split(/\s+/).filter(Boolean);
      if (parts.length < 2) {
        return '';
      }
      return `${parts[0]}_${parts[parts.length - 1]}`;
    }

    function headToHeadPlayerPools() {
      const byTeam = { Red: new Map(), Blue: new Map() };

      state.rows.forEach(row => {
        const team = normalize(row.team);
        if (!(team in byTeam)) {
          return;
        }
        playersInRow(row).forEach(player => {
          const key = playerNameKey(player);
          if (key && !byTeam[team].has(key)) {
            byTeam[team].set(key, player);
          }
        });
      });

      const pools = { Red: [], Blue: [] };
      (Array.isArray(state.playerPictures) ? state.playerPictures : []).forEach(pic => {
        const team = normalize(pic.team);
        if (!(team in byTeam)) {
          return;
        }
        const key = normalize(pic.key).toLowerCase();
        const playerName = byTeam[team].get(key);
        if (!playerName) {
          return;
        }
        if (pools[team].some(p => p.name === playerName)) {
          return;
        }
        pools[team].push({
          team,
          name: playerName,
          key,
          url: pic.url,
        });
      });

      pools.Red.sort((a, b) => a.name.localeCompare(b.name));
      pools.Blue.sort((a, b) => a.name.localeCompare(b.name));
      return pools;
    }

    function renderHeadToHeadPicker(team, players, container) {
      if (!container) {
        return;
      }
      const selected = state.headToHead[team];
      if (!players.length) {
        container.innerHTML = '<div class="h2h-empty-picker">No matching player photos found.</div>';
        return;
      }

      container.innerHTML = players.map(player => `
        <button type="button" class="h2h-avatar-btn ${normalize(team).toLowerCase()} ${selected === player.name ? 'is-selected' : ''}" data-h2h-team="${team}" data-h2h-player="${escapeHtml(player.name)}">
          <span class="avatar-wrap">
            <img src="${escapeHtml(player.url)}" alt="${escapeHtml(player.name)} headshot">
          </span>
          <span class="name">${escapeHtml(player.name)}</span>
        </button>
      `).join('');

      container.querySelectorAll('.h2h-avatar-btn').forEach(btn => {
        btn.addEventListener('click', () => {
          const nextPlayer = btn.dataset.h2hPlayer || null;
          state.headToHead[team] = state.headToHead[team] === nextPlayer ? null : nextPlayer;
          renderHeadToHeadSection();
        });
      });
    }

    function bindHeadToHeadPickerClear() {
      if (!el.h2hPickerShell || el.h2hPickerShell.dataset.clearBound === 'true') {
        return;
      }

      el.h2hPickerShell.addEventListener('click', event => {
        if (event.target.closest('.h2h-avatar-btn')) {
          return;
        }
        if (!state.headToHead.Red && !state.headToHead.Blue) {
          return;
        }
        state.headToHead.Red = null;
        state.headToHead.Blue = null;
        renderHeadToHeadSection();
      });

      el.h2hPickerShell.dataset.clearBound = 'true';
    }

    function buildHeadToHeadMatches(redPlayer, bluePlayer) {
      const grouped = new Map();
      state.rows.forEach(row => {
        const key = [
          normalize(row.year),
          normalize(row.round),
          normalize(row.match),
          normalize(row.format),
        ].join('|');

        if (!grouped.has(key)) {
          grouped.set(key, { red: null, blue: null });
        }
        const team = normalize(row.team);
        if (team === 'Red') {
          grouped.get(key).red = row;
        } else if (team === 'Blue') {
          grouped.get(key).blue = row;
        }
      });

      const matches = [];
      grouped.forEach(pair => {
        if (!pair.red || !pair.blue) {
          return;
        }
        if (!playersInRow(pair.red).includes(redPlayer)) {
          return;
        }
        if (!playersInRow(pair.blue).includes(bluePlayer)) {
          return;
        }

        const redPlayerList = playersInRow(pair.red);
        const bluePlayerList = playersInRow(pair.blue);
        matches.push({
          year: normalize(pair.red.year),
          round: normalize(pair.red.round),
          match: normalize(pair.red.match),
          format: normalize(pair.red.format),
          redPlayerList,
          bluePlayerList,
          redPlayers: redPlayerList.join(', '),
          bluePlayers: bluePlayerList.join(', '),
          redResult: normalize(pair.red.win_or_loss),
          blueResult: normalize(pair.blue.win_or_loss),
          redPoints: points(pair.red.points),
          bluePoints: points(pair.blue.points),
          score: normalize(pair.red.score || pair.blue.score),
        });
      });

      matches.sort((a, b) =>
        Number.parseInt(a.year, 10) - Number.parseInt(b.year, 10) ||
        Number.parseInt(a.round, 10) - Number.parseInt(b.round, 10) ||
        Number.parseInt(a.match, 10) - Number.parseInt(b.match, 10) ||
        a.format.localeCompare(b.format)
      );

      return matches;
    }

    function headToHeadStats(matches, side) {
      const stats = createRecord();
      matches.forEach(m => {
        applyResult(stats, side === 'Red' ? m.redResult : m.blueResult, side === 'Red' ? m.redPoints : m.bluePoints);
      });
      return stats;
    }

    function headToHeadFormatBreakout(matches) {
      const byFormat = new Map();
      matches.forEach(m => {
        const format = normalize(m.format) || 'Unknown';
        if (!byFormat.has(format)) {
          byFormat.set(format, { format, red: createRecord(), blue: createRecord() });
        }
        const bucket = byFormat.get(format);
        applyResult(bucket.red, m.redResult, m.redPoints);
        applyResult(bucket.blue, m.blueResult, m.bluePoints);
      });

      return [...byFormat.values()]
        .map(item => ({
          format: item.format,
          matches: Math.max(item.red.matches, item.blue.matches),
          redWlt: `${item.red.wins}-${item.red.losses}-${item.red.ties}`,
          redWinPctValue: item.red.matches ? (((item.red.wins + (0.5 * item.red.ties)) / item.red.matches) * 100) : 0,
          redWinPct: pct(item.red.wins, item.red.ties, item.red.matches),
          blueWlt: `${item.blue.wins}-${item.blue.losses}-${item.blue.ties}`,
          blueWinPctValue: item.blue.matches ? (((item.blue.wins + (0.5 * item.blue.ties)) / item.blue.matches) * 100) : 0,
          blueWinPct: pct(item.blue.wins, item.blue.ties, item.blue.matches),
        }))
        .sort((a, b) => {
          if (b.matches !== a.matches) {
            return b.matches - a.matches;
          }
          return a.format.localeCompare(b.format);
        });
    }

    function playerPictureUrl(team, name) {
      const key = playerNameKey(name);
      const match = (Array.isArray(state.playerPictures) ? state.playerPictures : []).find(pic =>
        normalize(pic.team) === team && normalize(pic.key).toLowerCase() === key
      );
      return match ? match.url : '';
    }

    function playerBioForPlayer(team, name) {
      const targetName = normalize(name);
      const targetTeam = normalize(team);
      return (Array.isArray(state.playerBios) ? state.playerBios : []).find(row =>
        normalize(row.player_name) === targetName &&
        (!targetTeam || normalize(row.team) === targetTeam)
      ) || (Array.isArray(state.playerBios) ? state.playerBios : []).find(row =>
        normalize(row.player_name) === targetName
      ) || null;
    }

    function matchScoreMargin(scoreText) {
      const score = normalize(scoreText).toUpperCase();
      if (!score || score === 'AS' || score === 'A/S') {
        return 0;
      }
      let m = score.match(/(\d+)\s*&\s*(\d+)/);
      if (m) {
        return Number.parseInt(m[1], 10) || 0;
      }
      m = score.match(/(\d+)\s*UP/);
      if (m) {
        return Number.parseInt(m[1], 10) || 0;
      }
      return 0;
    }

    function matchScoreHolesLeft(scoreText) {
      const score = normalize(scoreText).toUpperCase();
      if (!score || score === 'AS' || score === 'A/S') {
        return 0;
      }
      const m = score.match(/(\d+)\s*&\s*(\d+)/);
      if (m) {
        return Number.parseInt(m[2], 10) || 0;
      }
      // "UP" scores finish on the last hole, so there are no holes left.
      return 0;
    }

    function tiedMarginLeadersWithFinishPriority(matches) {
      if (!Array.isArray(matches) || !matches.length) {
        return [];
      }
      const maxMargin = Math.max(...matches.map(m => Number(m.margin) || 0));
      const marginTies = matches.filter(m => (Number(m.margin) || 0) === maxMargin);
      if (!marginTies.length) {
        return [];
      }
      // Prefer the earliest clinch (more holes left), e.g. 3&2 over 3&1.
      const bestFinish = Math.max(...marginTies.map(m => Number(m.holesLeft) || 0));
      return marginTies.filter(m => (Number(m.holesLeft) || 0) === bestFinish);
    }

    function groupedMatchSidesMap() {
      const map = new Map();
      (Array.isArray(state.rows) ? state.rows : []).forEach(row => {
        const key = [
          normalize(row.year),
          normalize(row.round),
          normalize(row.match),
        ].join('|');
        if (!map.has(key)) {
          map.set(key, { Red: null, Blue: null });
        }
        const team = normalize(row.team);
        if (team === 'Red' || team === 'Blue') {
          map.get(key)[team] = row;
        }
      });
      return map;
    }

    function personalRecordDisplay(value, fallback = 'N/A') {
      return value ? value : `<span class="subtle">${escapeHtml(fallback)}</span>`;
    }

    function tiedRecordLeaders(items, valueFn, mode = 'max', epsilon = 0) {
      if (!Array.isArray(items) || !items.length || typeof valueFn !== 'function') {
        return [];
      }
      const numeric = items
        .map(item => ({ item, value: Number(valueFn(item)) }))
        .filter(entry => Number.isFinite(entry.value));
      if (!numeric.length) {
        return [];
      }
      const leaderValue = numeric.reduce((best, entry) => {
        if (!Number.isFinite(best)) {
          return entry.value;
        }
        return mode === 'min'
          ? Math.min(best, entry.value)
          : Math.max(best, entry.value);
      }, Number.NaN);
      return numeric
        .filter(entry => Math.abs(entry.value - leaderValue) <= epsilon)
        .map(entry => entry.item);
    }

    function playerProfilePools() {
      const pools = headToHeadPlayerPools();
      return {
        Red: (Array.isArray(pools.Red) ? pools.Red : []).slice(0, 9),
        Blue: (Array.isArray(pools.Blue) ? pools.Blue : []).slice(0, 9),
      };
    }

    function renderPlayerProfileGrid(team, players, container) {
      if (!container) {
        return;
      }
      if (!Array.isArray(players) || !players.length) {
        container.innerHTML = '<div class="player-profile-empty">No player photos available.</div>';
        return;
      }
      container.innerHTML = players.map(player => `
        <button type="button" class="player-profile-tile ${normalize(team).toLowerCase()}" data-player-profile-team="${escapeHtml(team)}" data-player-profile-name="${escapeHtml(player.name)}">
          <span class="avatar-wrap">
            <img src="${escapeHtml(player.url)}" alt="${escapeHtml(player.name)} profile photo">
          </span>
          <span class="name">${escapeHtml(player.name)}</span>
        </button>
      `).join('');
    }

    function renderPlayerProfilesSection() {
      const pools = playerProfilePools();
      renderPlayerProfileGrid('Red', pools.Red, el.playerProfileRedGrid);
      renderPlayerProfileGrid('Blue', pools.Blue, el.playerProfileBlueGrid);

      [el.playerProfileRedGrid, el.playerProfileBlueGrid].forEach(container => {
        if (!container || container.dataset.bound === 'true') {
          return;
        }
        container.addEventListener('click', event => {
          const btn = event.target.closest('[data-player-profile-team][data-player-profile-name]');
          if (!btn) {
            return;
          }
          openPlayerProfileModal({
            team: btn.dataset.playerProfileTeam || '',
            name: btn.dataset.playerProfileName || '',
          });
        });
        container.dataset.bound = 'true';
      });
    }

    function buildPlayerRecordProfile(playerName) {
      const target = normalize(playerName);
      const rows = (Array.isArray(state.rows) ? state.rows : [])
        .filter(row => playersInRow(row).includes(target));
      const groupedSides = groupedMatchSidesMap();

      const overall = createRecord();
      const byFormat = new Map();
      const byYear = new Map();
      const teammateStats = new Map();
      const opponentStats = new Map();
      const playerMatchDetails = [];
      let team = '';

      rows.forEach(row => {
        if (!team) {
          team = normalize(row.team);
        }
        applyResult(overall, row.win_or_loss, points(row.points));

        const format = normalize(row.format) || 'Unknown';
        if (!byFormat.has(format)) {
          byFormat.set(format, createRecord());
        }
        applyResult(byFormat.get(format), row.win_or_loss, points(row.points));

        const year = normalize(row.year) || 'Unknown';
        if (!byYear.has(year)) {
          byYear.set(year, createRecord());
        }
        applyResult(byYear.get(year), row.win_or_loss, points(row.points));

        const matchKey = [normalize(row.year), normalize(row.round), normalize(row.match)].join('|');
        const matchSides = groupedSides.get(matchKey);
        const myTeam = normalize(row.team);
        const oppTeam = myTeam === 'Red' ? 'Blue' : (myTeam === 'Blue' ? 'Red' : '');
        const oppRow = matchSides ? matchSides[oppTeam] : null;
        const teammates = playersInRow(row).filter(name => normalize(name) !== target);
        const opponents = oppRow ? playersInRow(oppRow) : [];
        const playerResult = normalize(row.win_or_loss);
        const pts = points(row.points);

        teammates.forEach(name => {
          const key = normalize(name);
          if (!teammateStats.has(key)) {
            teammateStats.set(key, createRecord());
          }
          applyResult(teammateStats.get(key), playerResult, pts);
        });

        opponents.forEach(name => {
          const key = normalize(name);
          if (!opponentStats.has(key)) {
            opponentStats.set(key, createRecord());
          }
          applyResult(opponentStats.get(key), playerResult, pts);
        });

        playerMatchDetails.push({
          year: normalize(row.year),
          round: normalize(row.round),
          match: normalize(row.match),
          format,
          result: playerResult,
          score: normalize(row.score),
          margin: matchScoreMargin(row.score),
          holesLeft: matchScoreHolesLeft(row.score),
          opponents,
          teammates,
        });
      });

      const formats = [...byFormat.entries()]
        .map(([format, stats]) => ({
          format,
          matches: stats.matches,
          wins: stats.wins,
          losses: stats.losses,
          ties: stats.ties,
          wlt: `${stats.wins}-${stats.losses}-${stats.ties}`,
          points: Number(stats.points.toFixed(2)),
          winPct: pct(stats.wins, stats.ties, stats.matches),
          winTiePct: winTiePct(stats.wins, stats.ties, stats.matches),
          winPctValue: stats.matches ? (((stats.wins + (0.5 * stats.ties)) / stats.matches) * 100) : 0,
        }))
        .sort((a, b) =>
          b.matches - a.matches ||
          b.points - a.points ||
          b.winPctValue - a.winPctValue ||
          a.format.localeCompare(b.format)
        );

      const years = [...byYear.entries()]
        .map(([year, stats]) => ({
          year,
          matches: stats.matches,
          wins: stats.wins,
          losses: stats.losses,
          ties: stats.ties,
          wlt: `${stats.wins}-${stats.losses}-${stats.ties}`,
          points: Number(stats.points.toFixed(2)),
          winPct: pct(stats.wins, stats.ties, stats.matches),
          winTiePct: winTiePct(stats.wins, stats.ties, stats.matches),
        }))
        .sort((a, b) => Number.parseInt(b.year, 10) - Number.parseInt(a.year, 10));

      const uniqueYears = sortedUnique(rows.map(row => row.year), true, false);

      const yearPointRows = [...byYear.entries()]
        .map(([year, stats]) => ({ year, points: Number(stats.points.toFixed(2)) }))
        .sort((a, b) => b.points - a.points || Number.parseInt(b.year, 10) - Number.parseInt(a.year, 10));

      const handicapRows = (() => {
        const source = (Array.isArray(state.playerHandicaps) ? state.playerHandicaps : [])
          .filter(item => normalize(item.name) === target);
        const byYearHandicap = new Map();
        source.forEach(item => {
          const year = normalize(item.year);
          if (!year) {
            return;
          }
          const current = byYearHandicap.get(year);
          const candidateTeam = normalize(item.team);
          const currentTeam = current ? normalize(current.team) : '';
          const teamMatches = team && candidateTeam === team;
          const currentMatches = team && currentTeam === team;
          if (!current || (teamMatches && !currentMatches)) {
            byYearHandicap.set(year, item);
          }
        });
        return [...byYearHandicap.values()]
          .map(item => ({
            year: normalize(item.year),
            handicap: Number.parseFloat(normalize(item.handicap)),
          }))
          .filter(item => Number.isFinite(item.handicap));
      })();

      const handicapRowsByLowest = [...handicapRows].sort((a, b) => a.handicap - b.handicap || Number.parseInt(a.year, 10) - Number.parseInt(b.year, 10));
      const handicapRowsByHighest = [...handicapRows].sort((a, b) => b.handicap - a.handicap || Number.parseInt(b.year, 10) - Number.parseInt(a.year, 10));

      const eligibleIndividualRoundKeys = new Set(
        rows
          .filter(row => {
            const format = normalize(row.format);
            return format === 'Singles' || format === 'Best Ball';
          })
          .map(row => [normalize(row.year), normalize(row.round)].join('|'))
      );

      const roundScoreRows = (() => {
        const map = new Map();
        (Array.isArray(state.holeScores) ? state.holeScores : []).forEach(item => {
          if (normalize(item.player) !== target) {
            return;
          }
          const actual = intOrNull(item.actualscore);
          if (!Number.isFinite(actual)) {
            return;
          }
          const year = normalize(item.year);
          const round = normalize(item.round);
          const roundKey = [year, round].join('|');
          if (!eligibleIndividualRoundKeys.has(roundKey)) {
            return;
          }
          const course = normalize(item.course);
          const key = [year, round, course].join('|');
          if (!map.has(key)) {
            map.set(key, { year, round, course, total: 0, holes: 0 });
          }
          const entry = map.get(key);
          entry.total += actual;
          entry.holes += 1;
        });
        // Personal "round" records should only consider complete 18-hole rounds.
        return [...map.values()].filter(entry => entry.holes === 18);
      })();

      const roundRowsByLowest = [...roundScoreRows].sort((a, b) =>
        a.total - b.total || b.holes - a.holes || Number.parseInt(a.year, 10) - Number.parseInt(b.year, 10)
      );
      const roundRowsByHighest = [...roundScoreRows].sort((a, b) =>
        b.total - a.total || b.holes - a.holes || Number.parseInt(b.year, 10) - Number.parseInt(a.year, 10)
      );

      const matchWins = playerMatchDetails
        .filter(m => normalize(m.result).toLowerCase() === 'win' && m.margin > 0)
        .sort((a, b) => b.margin - a.margin || Number.parseInt(b.year, 10) - Number.parseInt(a.year, 10));
      const matchLosses = playerMatchDetails
        .filter(m => normalize(m.result).toLowerCase() === 'loss' && m.margin > 0)
        .sort((a, b) => b.margin - a.margin || Number.parseInt(b.year, 10) - Number.parseInt(a.year, 10));

      const teammateLeadersSorted = [...teammateStats.entries()]
        .map(([name, stats]) => ({ name, stats }))
        .sort((a, b) =>
          b.stats.matches - a.stats.matches ||
          b.stats.points - a.stats.points ||
          a.name.localeCompare(b.name)
        );
      const opponentLeadersSorted = [...opponentStats.entries()]
        .map(([name, stats]) => ({ name, stats }))
        .sort((a, b) =>
          b.stats.matches - a.stats.matches ||
          b.stats.points - a.stats.points ||
          a.name.localeCompare(b.name)
        );

      const personalRecords = {
        mostPointsTournament: tiedRecordLeaders(yearPointRows, row => row.points, 'max', 0.0001),
        lowestHandicap: tiedRecordLeaders(handicapRowsByLowest, row => row.handicap, 'min', 0.0001),
        highestHandicap: tiedRecordLeaders(handicapRowsByHighest, row => row.handicap, 'max', 0.0001),
        lowestRound: tiedRecordLeaders(roundRowsByLowest, row => row.total, 'min', 0),
        highestRound: tiedRecordLeaders(roundRowsByHighest, row => row.total, 'max', 0),
        biggestWin: tiedMarginLeadersWithFinishPriority(matchWins),
        biggestLoss: tiedMarginLeadersWithFinishPriority(matchLosses),
        mostFreqTeammate: tiedRecordLeaders(teammateLeadersSorted, row => row.stats.matches, 'max', 0),
        mostFreqOpponent: tiedRecordLeaders(opponentLeadersSorted, row => row.stats.matches, 'max', 0),
      };

      return {
        team,
        rows,
        overall: {
          matches: overall.matches,
          wins: overall.wins,
          losses: overall.losses,
          ties: overall.ties,
          wlt: `${overall.wins}-${overall.losses}-${overall.ties}`,
          points: Number(overall.points.toFixed(2)),
          winPct: pct(overall.wins, overall.ties, overall.matches),
          winTiePct: winTiePct(overall.wins, overall.ties, overall.matches),
          years: uniqueYears.length,
        },
        byFormat: formats,
        byYear: years,
        personalRecords,
      };
    }

    function playerProfileTableHtml(type, rows) {
      if (!Array.isArray(rows) || !rows.length) {
        return '<div class="player-profile-empty-state">No history found for this player.</div>';
      }
      const firstColKey = type === 'format' ? 'format' : 'year';
      const firstColLabel = type === 'format' ? 'Format' : 'Year';
      return `
        <div class="player-profile-table-wrap">
          <table class="player-profile-table">
            <thead>
              <tr>
                <th>${firstColLabel}</th>
                <th>Matches</th>
                <th>W-L-T</th>
                <th>Points</th>
                <th>Win %</th>
              </tr>
            </thead>
            <tbody>
              ${rows.map(row => `
                <tr>
                  <td>${escapeHtml(row[firstColKey])}</td>
                  <td class="num">${row.matches}</td>
                  <td>${escapeHtml(row.wlt)}</td>
                  <td class="num">${Number(row.points).toFixed(2)}</td>
                  <td class="num">${escapeHtml(row.winPct)}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      `;
    }

    function playerPersonalRecordsHtml(profile) {
      const pr = profile?.personalRecords || {};
      const asArray = value => Array.isArray(value) ? value : (value ? [value] : []);
      const multiLine = lines => {
        const clean = (Array.isArray(lines) ? lines : []).filter(Boolean);
        if (!clean.length) {
          return '';
        }
        return clean.map(line => `<div class="record-line">${line}</div>`).join('');
      };

      const rows = [
        {
          label: 'Most points in a tournament',
          value: multiLine(asArray(pr.mostPointsTournament).map(item =>
            `${Number(item.points).toFixed(2)} points <span class="subtle">(${escapeHtml(item.year)})</span>`
          )),
        },
        {
          label: 'Lowest handicap',
          value: multiLine(asArray(pr.lowestHandicap).map(item =>
            `${item.handicap.toFixed(1)} <span class="subtle">(${escapeHtml(item.year)})</span>`
          )),
        },
        {
          label: 'Highest handicap',
          value: multiLine(asArray(pr.highestHandicap).map(item =>
            `${item.handicap.toFixed(1)} <span class="subtle">(${escapeHtml(item.year)})</span>`
          )),
        },
        {
          label: 'Lowest individual round',
          value: multiLine(asArray(pr.lowestRound).map(item =>
            `${item.total} <span class="subtle">• ${escapeHtml(item.course)} (${escapeHtml(item.year)})</span>`
          )),
        },
        {
          label: 'Highest individual round',
          value: multiLine(asArray(pr.highestRound).map(item =>
            `${item.total} <span class="subtle">• ${escapeHtml(item.course)} (${escapeHtml(item.year)})</span>`
          )),
        },
        {
          label: 'Highest margin of victory',
          value: multiLine(asArray(pr.biggestWin).map(item => {
            const opp = Array.isArray(item.opponents) ? item.opponents.map(playerLastName).join(' / ') : '';
            return `${escapeHtml(item.format)} <span class="subtle">vs ${escapeHtml(opp || 'Opponents')}</span> • ${escapeHtml(item.score)} <span class="subtle">(${escapeHtml(item.year)})</span>`;
          })),
        },
        {
          label: 'Highest margin of defeat',
          value: multiLine(asArray(pr.biggestLoss).map(item => {
            const opp = Array.isArray(item.opponents) ? item.opponents.map(playerLastName).join(' / ') : '';
            return `${escapeHtml(item.format)} <span class="subtle">vs ${escapeHtml(opp || 'Opponents')}</span> • ${escapeHtml(item.score)} <span class="subtle">(${escapeHtml(item.year)})</span>`;
          })),
        },
        {
          label: 'Most frequent teammate',
          value: multiLine(asArray(pr.mostFreqTeammate).map(item => {
            const record = `${item.stats.wins}-${item.stats.losses}-${item.stats.ties}`;
            return `${escapeHtml(item.name)} <span class="subtle">• ${item.stats.matches} matches, ${escapeHtml(record)}</span>`;
          })),
        },
        {
          label: 'Most frequent opponent',
          value: multiLine(asArray(pr.mostFreqOpponent).map(item => {
            const record = `${item.stats.wins}-${item.stats.losses}-${item.stats.ties}`;
            return `${escapeHtml(item.name)} <span class="subtle">• ${item.stats.matches} matches, ${escapeHtml(record)}</span>`;
          })),
        },
      ];

      return `
        <div class="player-profile-personal-card">
          <h4 class="player-profile-section-title">Personal Records</h4>
          <div class="player-profile-personal-list">
            ${rows.map(item => `
              <div class="player-profile-personal-row">
                <div class="label">${escapeHtml(item.label)}</div>
                <div class="value">${personalRecordDisplay(item.value)}</div>
              </div>
            `).join('')}
          </div>
        </div>
      `;
    }

    function syncModalBodyScrollLock() {
      const matchOpen = el.matchModal && !el.matchModal.hidden;
      const playerOpen = el.playerProfileModal && !el.playerProfileModal.hidden;
      document.body.style.overflow = (matchOpen || playerOpen) ? 'hidden' : '';
    }

    function openPlayerProfileModal(player) {
      if (!el.playerProfileModal || !el.playerProfileModalContent) {
        return;
      }
      const name = normalize(player?.name);
      const team = normalize(player?.team);
      if (!name) {
        return;
      }

      const pictureUrl = playerPictureUrl(team, name);
      const bioRow = playerBioForPlayer(team, name);
      const bioText = normalize(bioRow?.bio);
      const profile = buildPlayerRecordProfile(name);
      const effectiveTeam = profile.team || team;
      const yearsPlayed = profile.overall.years ? `${profile.overall.years} ${profile.overall.years === 1 ? 'year' : 'years'}` : 'No years';

      el.playerProfileModalContent.innerHTML = `
        <section class="match-modal-section">
          <div class="player-profile-head ${normalize(effectiveTeam).toLowerCase()}">
            ${pictureUrl
              ? `<img src="${escapeHtml(pictureUrl)}" alt="${escapeHtml(name)}">`
              : `<div class="placeholder">${escapeHtml(playerInitials(name))}</div>`}
            <div class="title">
              <h3 class="player-name">${escapeHtml(name)}</h3>
              <div class="meta">
                ${effectiveTeam === 'Red' || effectiveTeam === 'Blue' ? teamTag(effectiveTeam) : ''}
                <span>${profile.overall.matches} matches</span>
                <span>${escapeHtml(yearsPlayed)}</span>
              </div>
            </div>
          </div>
        </section>

        <section class="match-modal-section">
          <h4 class="player-profile-section-title">Bio</h4>
          ${bioText
            ? `<div class="player-profile-bio">${escapeHtml(bioText)}</div>`
            : '<div class="player-profile-empty-state">No bio found for this player.</div>'}
        </section>

        <section class="match-modal-section">
          <h4 class="player-profile-section-title">Overall Record</h4>
          <div class="player-profile-overall-grid">
            <div class="player-profile-metric"><div class="label">Matches</div><div class="value">${profile.overall.matches}</div></div>
            <div class="player-profile-metric"><div class="label">Record</div><div class="value">${escapeHtml(profile.overall.wlt)}</div></div>
            <div class="player-profile-metric"><div class="label">Points</div><div class="value">${profile.overall.points.toFixed(2)}</div></div>
            <div class="player-profile-metric"><div class="label">Win %</div><div class="value">${escapeHtml(profile.overall.winPct)}</div></div>
            <div class="player-profile-metric"><div class="label">Win + Tie %</div><div class="value">${escapeHtml(profile.overall.winTiePct)}</div></div>
            <div class="player-profile-metric"><div class="label">Tournaments</div><div class="value">${profile.overall.years}</div></div>
          </div>
        </section>

        <section class="match-modal-section">
          <div class="player-profile-record-grid">
            <div class="player-profile-record-card">
              <h4 class="player-profile-section-title">Record by Format</h4>
              ${playerProfileTableHtml('format', profile.byFormat)}
            </div>
            <div class="player-profile-record-card">
              <h4 class="player-profile-section-title">Record by Year</h4>
              ${playerProfileTableHtml('year', profile.byYear)}
            </div>
          </div>
        </section>

        <section class="match-modal-section">
          ${playerPersonalRecordsHtml(profile)}
        </section>
      `;

      el.playerProfileModal.hidden = false;
      syncModalBodyScrollLock();
    }

    function closePlayerProfileModal() {
      if (!el.playerProfileModal) {
        return;
      }
      el.playerProfileModal.hidden = true;
      syncModalBodyScrollLock();
    }

    function bindPlayerProfileModal() {
      if (!el.playerProfileModal || el.playerProfileModal.dataset.bound === 'true') {
        return;
      }

      el.playerProfileModal.addEventListener('click', event => {
        if (event.target.closest('[data-player-modal-close]') || event.target === el.playerProfileModalClose) {
          closePlayerProfileModal();
        }
      });

      document.addEventListener('keydown', event => {
        if (event.key === 'Escape' && !el.playerProfileModal.hidden) {
          closePlayerProfileModal();
        }
      });

      el.playerProfileModal.dataset.bound = 'true';
    }

    function matchResultMarkup(winner) {
      const w = normalize(winner);
      if (w === 'Red' || w === 'Blue') {
        return teamTag(w);
      }
      return resultTag(w || 'Tie');
    }

    function matchModalPlayersHtml(team, players, winner) {
      const names = Array.isArray(players) ? players : [];
      const isWinner = normalize(winner) === normalize(team);
      if (!names.length) {
        return '<div class="h2h-empty-state">No participants listed.</div>';
      }

      return `<div class="match-modal-players">${names.map(name => {
        const photoUrl = playerPictureUrl(team, name);
        return `
          <div class="match-modal-player ${normalize(team).toLowerCase()} ${isWinner ? 'is-winner' : ''}">
            ${photoUrl ? `<img src="${escapeHtml(photoUrl)}" alt="${escapeHtml(name)}">` : `<div class="placeholder">${escapeHtml(playerInitials(name))}</div>`}
            <div class="name">${escapeHtml(name)}</div>
          </div>
        `;
      }).join('')}</div>`;
    }

    function openMatchModal(match) {
      if (!el.matchModal || !el.matchModalContent || !match) {
        return;
      }
      const location = tournamentLocationForYear(match.year);
      const course = courseForMatch(match.year, match.round, match.match);
      const tees = teesForMatch(match.year, match.round, match.match);
      const matchLength = matchLengthForMatch(match.year, match.round, match.match);
      const summaryRow = matchSummaryForMatch(match.year, match.round, match.match);
      const summaryText = normalize(summaryRow?.summary);
      const winnerClass = normalize(match.winner) === 'Red'
        ? 'winner-red'
        : (normalize(match.winner) === 'Blue' ? 'winner-blue' : 'winner-tie');
      const summarySectionHtml = summaryText ? `
        <section class="match-modal-section">
          <div class="match-modal-summary ${winnerClass}">
            <div class="match-modal-summary-label">Match Summary</div>
            <p class="match-modal-summary-text">${escapeHtml(summaryText)}</p>
          </div>
        </section>
      ` : '';

      el.matchModalContent.innerHTML = `
        <section class="match-modal-section">
          <div class="match-modal-matchup">
            <div class="match-modal-side red ${normalize(match.winner) === 'Red' ? 'is-winner' : ''}">
              <div class="side-title">Red</div>
              ${matchModalPlayersHtml('Red', match.redPlayers, match.winner)}
            </div>
            <div class="match-modal-vs">VS</div>
            <div class="match-modal-side blue ${normalize(match.winner) === 'Blue' ? 'is-winner' : ''}">
              <div class="side-title">Blue</div>
              ${matchModalPlayersHtml('Blue', match.bluePlayers, match.winner)}
            </div>
          </div>
        </section>
        <section class="match-modal-section">
          <div class="match-modal-meta">
            <span class="match-modal-chip"><span class="label">Year</span> ${escapeHtml(match.year)}</span>
            <span class="match-modal-chip"><span class="label">Format</span> ${escapeHtml(match.format)}</span>
            ${location ? `<span class="match-modal-chip"><span class="label">Location</span> ${escapeHtml(location)}</span>` : ''}
            ${course ? `<span class="match-modal-chip"><span class="label">Course</span> ${escapeHtml(course)}</span>` : ''}
            ${tees ? `<span class="match-modal-chip"><span class="label">Tees</span> ${escapeHtml(tees)}</span>` : ''}
            ${matchLength ? `<span class="match-modal-chip"><span class="label">Length</span> ${escapeHtml(matchLength)} holes</span>` : ''}
            ${normalize(match.score) ? `<span class="match-modal-chip"><span class="label">Score</span> ${escapeHtml(match.score)}</span>` : ''}
          </div>
        </section>
        <section class="match-modal-section">
          ${renderHoleBoards(match)}
        </section>
        ${summarySectionHtml}
        <section class="match-modal-section">
          ${renderMatchProjection(match)}
        </section>
      `;

      el.matchModal.hidden = false;
      syncModalBodyScrollLock();
    }

    function closeMatchModal() {
      if (!el.matchModal) {
        return;
      }
      el.matchModal.hidden = true;
      syncModalBodyScrollLock();
    }

    function bindMatchModal() {
      if (!el.matchModal || el.matchModal.dataset.bound === 'true') {
        return;
      }

      el.matchModal.addEventListener('click', event => {
        if (event.target.closest('[data-match-modal-close]') || event.target === el.matchModalClose) {
          closeMatchModal();
        }
      });

      document.addEventListener('keydown', event => {
        if (event.key === 'Escape' && !el.matchModal.hidden) {
          closeMatchModal();
        }
      });

      el.matchModal.dataset.bound = 'true';
    }

    function bindMatchRowPopups() {
      if (el.h2hBody && el.h2hBody.dataset.matchPopupBound !== 'true') {
        el.h2hBody.addEventListener('click', event => {
          const row = event.target.closest('tr[data-match-source="h2h"][data-match-index]');
          if (!row) {
            return;
          }
          const index = Number.parseInt(row.dataset.matchIndex || '', 10);
          if (!Number.isFinite(index) || !state.h2hMatchRows[index]) {
            return;
          }
          const match = state.h2hMatchRows[index];
          openMatchModal({
            year: match.year,
            round: match.round,
            match: match.match,
            format: match.format,
            result: '',
            winner: normalize(match.redResult).toLowerCase() === 'win' ? 'Red' : (normalize(match.blueResult).toLowerCase() === 'win' ? 'Blue' : 'Tie'),
            score: match.score,
            redPlayers: Array.isArray(match.redPlayerList) ? match.redPlayerList : [],
            bluePlayers: Array.isArray(match.bluePlayerList) ? match.bluePlayerList : [],
          });
        });
        el.h2hBody.dataset.matchPopupBound = 'true';
      }

      if (el.logBody && el.logBody.dataset.matchPopupBound !== 'true') {
        el.logBody.addEventListener('click', event => {
          const row = event.target.closest('tr[data-match-source="log"][data-match-index]');
          if (!row) {
            return;
          }
          const index = Number.parseInt(row.dataset.matchIndex || '', 10);
          if (!Number.isFinite(index) || !state.logMatchRows[index]) {
            return;
          }
          const match = state.logMatchRows[index];
          openMatchModal({
            year: match.year,
            round: match.round,
            match: match.match,
            format: match.format,
            winner: match.winner,
            score: match.score,
            redPlayers: Array.isArray(match.redPlayersFull) ? match.redPlayersFull : [],
            bluePlayers: Array.isArray(match.bluePlayersFull) ? match.bluePlayersFull : [],
          });
        });
        el.logBody.dataset.matchPopupBound = 'true';
      }
    }

    function renderHeadToHeadSection() {
      const pools = headToHeadPlayerPools();

      if (state.headToHead.Red && !pools.Red.some(p => p.name === state.headToHead.Red)) {
        state.headToHead.Red = null;
      }
      if (state.headToHead.Blue && !pools.Blue.some(p => p.name === state.headToHead.Blue)) {
        state.headToHead.Blue = null;
      }

      renderHeadToHeadPicker('Red', pools.Red, el.h2hRedPicker);
      renderHeadToHeadPicker('Blue', pools.Blue, el.h2hBluePicker);

      const redPlayer = state.headToHead.Red;
      const bluePlayer = state.headToHead.Blue;
      state.h2hMatchRows = [];

      if (!redPlayer || !bluePlayer) {
        el.h2hSummary.innerHTML = '<div class="h2h-empty-state">Select one Red player and one Blue player to view head-to-head results.</div>';
        el.h2hBody.innerHTML = emptyRow(6, 'Select one player from each team to view head-to-head matches.');
        return;
      }

      const matches = buildHeadToHeadMatches(redPlayer, bluePlayer);
      const redStats = headToHeadStats(matches, 'Red');
      const blueStats = headToHeadStats(matches, 'Blue');
      const breakout = headToHeadFormatBreakout(matches);
      const redPic = playerPictureUrl('Red', redPlayer);
      const bluePic = playerPictureUrl('Blue', bluePlayer);
      const comparisonRows = [
        {
          label: 'Overall',
          overall: true,
          redPctValue: redStats.matches ? (((redStats.wins + (0.5 * redStats.ties)) / redStats.matches) * 100) : 0,
          redPct: pct(redStats.wins, redStats.ties, redStats.matches),
          redRecord: `${redStats.wins}-${redStats.losses}-${redStats.ties}`,
          bluePctValue: blueStats.matches ? (((blueStats.wins + (0.5 * blueStats.ties)) / blueStats.matches) * 100) : 0,
          bluePct: pct(blueStats.wins, blueStats.ties, blueStats.matches),
          blueRecord: `${blueStats.wins}-${blueStats.losses}-${blueStats.ties}`,
        },
        ...breakout.map(row => ({
          label: row.format,
          overall: false,
          redPctValue: row.redWinPctValue,
          redPct: row.redWinPct,
          redRecord: row.redWlt,
          bluePctValue: row.blueWinPctValue,
          bluePct: row.blueWinPct,
          blueRecord: row.blueWlt,
        })),
      ];

      el.h2hSummary.innerHTML = `
        <div class="h2h-compare-board">
          <div class="h2h-compare-head">
            <div class="h2h-compare-player red">
              <img src="${escapeHtml(redPic)}" alt="${escapeHtml(redPlayer)}">
              <div class="name">${escapeHtml(redPlayer)}</div>
            </div>
            <div class="h2h-compare-vs">VS</div>
            <div class="h2h-compare-player blue">
              <img src="${escapeHtml(bluePic)}" alt="${escapeHtml(bluePlayer)}">
              <div class="name">${escapeHtml(bluePlayer)}</div>
            </div>
          </div>
          <div class="h2h-compare-rows">
            ${comparisonRows.map(row => `
              <div class="h2h-compare-row ${row.overall ? 'overall' : ''}" style="--row-red-fill:${Math.max(0, Math.min(100, Number(row.redPctValue) || 0)).toFixed(1)}%">
                <div class="h2h-compare-metric red">
                  <div class="pct">${escapeHtml(row.redPct)}</div>
                  <div class="record">${escapeHtml(row.redRecord)}</div>
                </div>
                <div class="h2h-compare-label">${escapeHtml(row.label)}</div>
                <div class="h2h-compare-metric blue">
                  <div class="pct">${escapeHtml(row.bluePct)}</div>
                  <div class="record">${escapeHtml(row.blueRecord)}</div>
                </div>
              </div>
            `).join('')}
          </div>
        </div>
        <div class="h2h-empty-state">${matches.length} head-to-head match${matches.length === 1 ? '' : 'es'} found.</div>
      `;

      if (!matches.length) {
        el.h2hBody.innerHTML = emptyRow(6, 'No matches found for the selected player matchup.');
        return;
      }

      state.h2hMatchRows = matches;
      el.h2hBody.innerHTML = matches.map((m, index) => `
        <tr class="match-row-trigger" data-match-source="h2h" data-match-index="${index}">
          <td>${escapeHtml(m.year)}</td>
          <td>${escapeHtml(m.format)}</td>
          <td>${escapeHtml(m.redPlayers)}</td>
          <td>${escapeHtml(m.bluePlayers)}</td>
          <td>${m.redResult.toLowerCase() === 'win' ? teamTag('Red') : (m.blueResult.toLowerCase() === 'win' ? teamTag('Blue') : resultTag('Tie'))}</td>
          <td>${escapeHtml(m.score)}</td>
        </tr>
      `).join('');
    }

    function teamTag(team) {
      const t = normalize(team);
      const cls = t.toLowerCase() === 'red' ? 'team-red' : 'team-blue';
      return `<span class="team-pill ${cls}">${escapeHtml(t || 'Unknown')}</span>`;
    }

    function resultTag(outcome) {
      const o = normalize(outcome);
      const cls = o.toLowerCase() === 'win' ? 'result-win' : (o.toLowerCase() === 'loss' ? 'result-loss' : 'result-tie');
      return `<span class="${cls}">${escapeHtml(o || 'Unknown')}</span>`;
    }

    function escapeHtml(value) {
      return String(value ?? '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
    }

    function clearBody(body) {
      body.innerHTML = '';
    }

    function emptyRow(colspan, label = 'No records found for the current filters.') {
      return `<tr><td colspan="${colspan}" style="color:#6a7490">${escapeHtml(label)}</td></tr>`;
    }

    function createRecord() {
      return { matches: 0, wins: 0, losses: 0, ties: 0, points: 0 };
    }

    function applyResult(record, outcome, pts) {
      record.matches += 1;
      record.points += pts;
      const o = normalize(outcome).toLowerCase();
      if (o === 'win') {
        record.wins += 1;
      } else if (o === 'loss') {
        record.losses += 1;
      } else {
        record.ties += 1;
      }
    }

    function getSelectedValues(select) {
      if (!select.multiple) {
        return [select.value];
      }
      return [...select.selectedOptions]
        .map(option => option.value)
        .filter(Boolean);
    }

    function pairingsIncludeFormatDetails() {
      return Boolean(el.pairIncludeFormatDetails?.checked);
    }

    function updatePairingsModeUI() {
      const includeFormat = pairingsIncludeFormatDetails();

      if (!includeFormat && sortState.pair.key === 'format') {
        sortState.pair.key = 'rank';
        sortState.pair.dir = 'asc';
        closeAllMultiDropdowns();
      }

      if (el.pairFormatFilterLabel) {
        el.pairFormatFilterLabel.style.display = includeFormat ? '' : 'none';
      }

      if (el.pairTable) {
        el.pairTable.classList.toggle('hide-pair-format', !includeFormat);
      }
    }

    function closeAllMultiDropdowns(except = null) {
      document.querySelectorAll('.multi-dropdown.open').forEach(drop => {
        if (drop !== except) {
          drop.classList.remove('open');
        }
      });
    }

    function multiTriggerText(select) {
      const options = [...select.options];
      const selected = options.filter(option => option.selected);
      const placeholder = select.dataset.placeholder || 'All';

      if (!options.length || selected.length === 0 || selected.length === options.length) {
        return placeholder;
      }
      if (selected.length <= 2) {
        return selected.map(option => option.textContent).join(', ');
      }
      return `${selected.length} selected`;
    }

    function renderMultiDropdown(select) {
      const control = multiControlState.controls.get(select.id);
      if (!control) {
        return;
      }

      const { trigger, menu } = control;
      trigger.textContent = multiTriggerText(select);
      menu.innerHTML = '';
      const options = [...select.options];
      const selectedCount = options.filter(option => option.selected).length;

      const allRow = document.createElement('label');
      allRow.className = 'multi-option';

      const allCheckbox = document.createElement('input');
      allCheckbox.type = 'checkbox';
      allCheckbox.checked = options.length > 0 && selectedCount === options.length;
      allCheckbox.indeterminate = selectedCount > 0 && selectedCount < options.length;

      const allText = document.createElement('span');
      allText.textContent = 'Select All (default)';

      allCheckbox.addEventListener('change', () => {
        options.forEach(option => {
          option.selected = allCheckbox.checked;
        });
        trigger.textContent = multiTriggerText(select);
        renderMultiDropdown(select);
        select.dispatchEvent(new Event('change', { bubbles: true }));
      });

      allRow.appendChild(allCheckbox);
      allRow.appendChild(allText);
      menu.appendChild(allRow);

      options.forEach(option => {
        const row = document.createElement('label');
        row.className = 'multi-option';

        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.checked = option.selected;

        const text = document.createElement('span');
        text.textContent = option.textContent;

        checkbox.addEventListener('change', () => {
          option.selected = checkbox.checked;
          trigger.textContent = multiTriggerText(select);
          select.dispatchEvent(new Event('change', { bubbles: true }));
        });

        row.appendChild(checkbox);
        row.appendChild(text);
        menu.appendChild(row);
      });
    }

    function ensureMultiDropdown(select) {
      if (!select.multiple || !select.dataset.multi) {
        return;
      }

      if (multiControlState.controls.has(select.id)) {
        renderMultiDropdown(select);
        return;
      }

      select.classList.add('multi-native');
      const dropdown = document.createElement('div');
      dropdown.className = 'multi-dropdown';

      const trigger = document.createElement('button');
      trigger.type = 'button';
      trigger.className = 'multi-trigger';

      const menu = document.createElement('div');
      menu.className = 'multi-menu';

      dropdown.appendChild(trigger);
      dropdown.appendChild(menu);
      select.insertAdjacentElement('afterend', dropdown);

      trigger.addEventListener('click', event => {
        event.preventDefault();
        event.stopPropagation();
        const open = !dropdown.classList.contains('open');
        closeAllMultiDropdowns(open ? dropdown : null);
        dropdown.classList.toggle('open', open);
      });

      menu.addEventListener('click', event => {
        event.stopPropagation();
      });

      multiControlState.controls.set(select.id, { dropdown, trigger, menu });
      renderMultiDropdown(select);
    }

    function initMultiDropdowns() {
      document.querySelectorAll('select[multiple][data-multi="true"]').forEach(select => {
        ensureMultiDropdown(select);
      });

      if (!multiControlState.globalListenersBound) {
        document.addEventListener('click', () => closeAllMultiDropdowns());
        document.addEventListener('keydown', event => {
          if (event.key === 'Escape') {
            closeAllMultiDropdowns();
          }
        });
        multiControlState.globalListenersBound = true;
      }
    }

    function setOptions(select, values, allLabel = 'All') {
      if (select.multiple) {
        const before = new Set(getSelectedValues(select));
        select.innerHTML = values.map(v => `<option value="${escapeHtml(v)}">${escapeHtml(v)}</option>`).join('');
        const selectAll = before.size === 0;
        [...select.options].forEach(option => {
          option.selected = selectAll || before.has(option.value);
        });
        renderMultiDropdown(select);
        return;
      }

      const before = select.value;
      const opts = [`<option value="All">${escapeHtml(allLabel)}</option>`]
        .concat(values.map(v => `<option value="${escapeHtml(v)}">${escapeHtml(v)}</option>`));
      select.innerHTML = opts.join('');
      select.value = values.includes(before) ? before : 'All';
    }

    function sortedUnique(values, asNumbers = false, desc = false) {
      const set = new Set(values.map(v => normalize(v)).filter(Boolean));
      const arr = [...set];
      if (asNumbers) {
        arr.sort((a, b) => Number.parseInt(a, 10) - Number.parseInt(b, 10));
      } else {
        arr.sort((a, b) => a.localeCompare(b));
      }
      if (desc) {
        arr.reverse();
      }
      return arr;
    }

    function singleOrMultiMatch(value, filter) {
      if (Array.isArray(filter)) {
        return filter.length === 0 || filter.includes(value);
      }
      return filter === 'All' || filter === '' || value === filter;
    }

    function baseFilter(rows, { team = 'All', year = [], format = [], player = 'All' } = {}) {
      return rows.filter(row => {
        if (!singleOrMultiMatch(normalize(row.team), team)) {
          return false;
        }
        if (!singleOrMultiMatch(normalize(row.year), year)) {
          return false;
        }
        if (!singleOrMultiMatch(normalize(row.format), format)) {
          return false;
        }
        if (player !== 'All' && !playersInRow(row).includes(player)) {
          return false;
        }
        return true;
      });
    }

    function resultValue(result) {
      const r = normalize(result).toLowerCase();
      if (r === 'win') {
        return 3;
      }
      if (r === 'tie') {
        return 2;
      }
      if (r === 'loss') {
        return 1;
      }
      return 0;
    }

    function compareValues(a, b, key) {
      if (key === 'result') {
        return resultValue(a[key]) - resultValue(b[key]);
      }

      const aValue = a[key];
      const bValue = b[key];
      if (typeof aValue === 'number' || typeof bValue === 'number') {
        return Number(aValue ?? 0) - Number(bValue ?? 0);
      }

      return normalize(aValue).localeCompare(normalize(bValue), undefined, {
        numeric: true,
        sensitivity: 'base',
      });
    }

    function sortRows(tableName, rows) {
      const { key, dir } = sortState[tableName];
      const direction = dir === 'asc' ? 1 : -1;
      return rows
        .map((row, index) => ({ ...row, _index: index }))
        .sort((a, b) => {
          const cmp = compareValues(a, b, key);
          if (cmp !== 0) {
            return cmp * direction;
          }
          return a._index - b._index;
        });
    }

    function updateSortIndicators() {
      document.querySelectorAll('th.sortable[data-table][data-key]').forEach(th => {
        const tableName = th.dataset.table;
        const key = th.dataset.key;
        const tableSort = sortState[tableName];
        const active = tableSort && tableSort.key === key;
        th.dataset.sort = active ? tableSort.dir : '';
      });
    }

    function bindSorting() {
      document.querySelectorAll('th.sortable[data-table][data-key]').forEach(th => {
        th.addEventListener('click', () => {
          const tableName = th.dataset.table;
          const key = th.dataset.key;
          const tableSort = sortState[tableName];
          if (!tableSort) {
            return;
          }

          if (tableSort.key === key) {
            tableSort.dir = tableSort.dir === 'asc' ? 'desc' : 'asc';
          } else {
            tableSort.key = key;
            tableSort.dir = 'asc';
          }

          rerenderAllTables();
        });
      });
      updateSortIndicators();
    }

    function initializeFilters() {
      const years = sortedUnique(state.rows.map(r => r.year), true, true);
      const teams = sortedUnique(state.rows.map(r => r.team));
      const formats = sortedUnique(state.rows.map(r => r.format));
      const players = sortedUnique(state.rows.flatMap(playersInRow));
      const pairFormats = formats.filter(f => TWO_MAN_FORMATS.has(f));

      setOptions(el.teamFormatYear, years);

      setOptions(el.playerTeam, teams);
      setOptions(el.playerYear, years);
      setOptions(el.playerFormat, formats);
      setOptions(el.playerPlayer, players);

      setOptions(el.pairTeam, teams);
      setOptions(el.pairYear, years);
      setOptions(el.pairFormat, pairFormats);
      setOptions(el.pairPlayer, players);

      setOptions(el.logTeam, teams);
      setOptions(el.logYear, years);
      setOptions(el.logFormat, formats);
      setOptions(el.logPlayer, players);
    }

    function renderChart() {
      const canvas = document.getElementById('pointsChart');
      const rows = state.rows;
      const years = sortedUnique(rows.map(r => r.year), true, false);
      const teams = ['Red', 'Blue'];
      const locationByYear = new Map(
        (Array.isArray(state.yearOutcomes) ? state.yearOutcomes : [])
          .map(item => [normalize(item.year), normalize(item.location)])
          .filter(([year]) => year !== '')
      );

      const byTeamYear = new Map();
      for (const row of rows) {
        const key = `${normalize(row.team)}|${normalize(row.year)}`;
        byTeamYear.set(key, (byTeamYear.get(key) || 0) + points(row.points));
      }

      const dataByTeam = team => years.map(y => {
        const key = `${team}|${y}`;
        return Number((byTeamYear.get(key) || 0).toFixed(2));
      });

      const chartData = {
        labels: years,
        datasets: [
          {
            label: 'Red Team Points',
            data: dataByTeam('Red'),
            borderColor: '#bf0f21',
            backgroundColor: 'rgba(191, 15, 33, 0.15)',
            pointBackgroundColor: '#bf0f21',
            pointRadius: 4,
            borderWidth: 3,
            tension: 0.25,
            fill: false,
          },
          {
            label: 'Blue Team Points',
            data: dataByTeam('Blue'),
            borderColor: '#0b387e',
            backgroundColor: 'rgba(11, 56, 126, 0.15)',
            pointBackgroundColor: '#0b387e',
            pointRadius: 4,
            borderWidth: 3,
            tension: 0.25,
            fill: false,
          },
        ],
      };

      if (state.chart) {
        state.chart.destroy();
      }

      state.chart = new Chart(canvas, {
        type: 'line',
        data: chartData,
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: { mode: 'index', intersect: false },
          plugins: {
            legend: { labels: { usePointStyle: true, boxWidth: 8, boxHeight: 8, padding: 18, font: { family: 'Manrope', size: 12, weight: '700' } } },
            tooltip: {
              callbacks: {
                label(ctx) {
                  return `${ctx.dataset.label}: ${ctx.parsed.y.toFixed(1)}`;
                },
                footer(items) {
                  const year = normalize(items?.[0]?.label);
                  const location = locationByYear.get(year);
                  return location ? `Location: ${location}` : '';
                },
              },
            },
          },
          scales: {
            x: {
              grid: { display: false },
              ticks: { color: '#35527f', font: { family: 'Manrope', weight: '700' } },
            },
            y: {
              beginAtZero: true,
              grid: { color: 'rgba(13, 43, 94, 0.08)' },
              ticks: { color: '#35527f', font: { family: 'Manrope', weight: '700' } },
              title: { display: true, text: 'Points', color: '#35527f', font: { family: 'Manrope', weight: '700' } },
            },
          },
        },
      });
    }

    function renderTeamFormatTable() {
      const rows = baseFilter(state.rows, {
        year: getSelectedValues(el.teamFormatYear),
      });

      const map = new Map();
      const overallRed = createRecord();
      const overallBlue = createRecord();
      for (const row of rows) {
        const format = normalize(row.format);
        const team = normalize(row.team);
        const key = format;
        if (!map.has(key)) {
          map.set(key, {
            format,
            red: createRecord(),
            blue: createRecord(),
          });
        }
        const bucket = map.get(key);
        if (team === 'Red') {
          applyResult(bucket.red, row.win_or_loss, points(row.points));
          applyResult(overallRed, row.win_or_loss, points(row.points));
        } else if (team === 'Blue') {
          applyResult(bucket.blue, row.win_or_loss, points(row.points));
          applyResult(overallBlue, row.win_or_loss, points(row.points));
        }
      }

      const breakout = [...map.values()]
        .map(item => {
          const red = item.red;
          const blue = item.blue;
          const matches = Math.max(red.matches, blue.matches);
          return {
            label: item.format,
            overall: false,
            matches,
            redPctValue: red.matches ? (((red.wins + (0.5 * red.ties)) / red.matches) * 100) : 0,
            redPct: pct(red.wins, red.ties, red.matches),
            redRecord: `${red.wins}-${red.losses}-${red.ties}`,
            bluePctValue: blue.matches ? (((blue.wins + (0.5 * blue.ties)) / blue.matches) * 100) : 0,
            bluePct: pct(blue.wins, blue.ties, blue.matches),
            blueRecord: `${blue.wins}-${blue.losses}-${blue.ties}`,
          };
        })
        .sort((a, b) => {
          if (b.matches !== a.matches) {
            return b.matches - a.matches;
          }
          return a.label.localeCompare(b.label);
        });

      if (!breakout.length) {
        el.teamFormatSummary.innerHTML = '<div class="h2h-empty-state">No records found for the current filters.</div>';
        return;
      }

      const overallMatches = Math.max(overallRed.matches, overallBlue.matches);
      const comparisonRows = [
        {
          label: 'Overall',
          overall: true,
          matches: overallMatches,
          redPctValue: overallRed.matches ? (((overallRed.wins + (0.5 * overallRed.ties)) / overallRed.matches) * 100) : 0,
          redPct: pct(overallRed.wins, overallRed.ties, overallRed.matches),
          redRecord: `${overallRed.wins}-${overallRed.losses}-${overallRed.ties}`,
          bluePctValue: overallBlue.matches ? (((overallBlue.wins + (0.5 * overallBlue.ties)) / overallBlue.matches) * 100) : 0,
          bluePct: pct(overallBlue.wins, overallBlue.ties, overallBlue.matches),
          blueRecord: `${overallBlue.wins}-${overallBlue.losses}-${overallBlue.ties}`,
        },
        ...breakout,
      ];

      el.teamFormatSummary.innerHTML = `
        <div class="h2h-compare-board">
          <div class="h2h-compare-rows">
            ${comparisonRows.map(row => `
              <div class="h2h-compare-row ${row.overall ? 'overall' : ''}" style="--row-red-fill:${Math.max(0, Math.min(100, Number(row.redPctValue) || 0)).toFixed(1)}%">
                <div class="h2h-compare-metric red">
                  <div class="pct">${escapeHtml(row.redPct)}</div>
                  <div class="record">${escapeHtml(row.redRecord)}</div>
                </div>
                <div class="h2h-compare-label">${escapeHtml(row.label)}</div>
                <div class="h2h-compare-metric blue">
                  <div class="pct">${escapeHtml(row.bluePct)}</div>
                  <div class="record">${escapeHtml(row.blueRecord)}</div>
                </div>
              </div>
            `).join('')}
          </div>
        </div>
      `;
    }

    function renderPlayerTable() {
      const rows = baseFilter(state.rows, {
        team: el.playerTeam.value,
        year: getSelectedValues(el.playerYear),
        format: getSelectedValues(el.playerFormat),
      });
      const selectedPlayers = getSelectedValues(el.playerPlayer);

      const map = new Map();
      for (const row of rows) {
        const team = normalize(row.team);
        for (const player of playersInRow(row)) {
          if (selectedPlayers.length && !selectedPlayers.includes(player)) {
            continue;
          }
          const key = `${player}|${team}`;
          if (!map.has(key)) {
            map.set(key, { player, team, stats: createRecord() });
          }
          applyResult(map.get(key).stats, row.win_or_loss, points(row.points));
        }
      }

      const performanceOrdered = [...map.values()]
        .sort((a, b) =>
          b.stats.points - a.stats.points ||
          (b.stats.wins + 0.5 * b.stats.ties) - (a.stats.wins + 0.5 * a.stats.ties) ||
          b.stats.matches - a.stats.matches ||
          a.player.localeCompare(b.player)
        )
        .map(item => {
          const s = item.stats;
          return {
            player: item.player,
            team: item.team,
            matches: s.matches,
            wins: s.wins,
            losses: s.losses,
            ties: s.ties,
            wlt: `${s.wins}-${s.losses}-${s.ties}`,
            points: Number(s.points.toFixed(2)),
            winPctValue: s.matches ? ((s.wins + (0.5 * s.ties)) / s.matches) * 100 : 0,
            winTiePctValue: s.matches ? ((s.wins + s.ties) / s.matches) * 100 : 0,
          };
        });
      const minMatches = minMatchesValue(el.playerMinMatches);
      const ranked = performanceOrdered
        .filter(item => item.matches >= minMatches)
        .map((item, index) => ({ ...item, rank: index + 1 }));
      const data = sortRows('player', ranked);

      if (!data.length) {
        el.playerBody.innerHTML = emptyRow(8);
        return;
      }

      el.playerBody.innerHTML = data.map(item => {
        return `<tr>
          <td>${item.rank}</td>
          <td>${escapeHtml(item.player)}</td>
          <td>${teamTag(item.team)}</td>
          <td>${item.matches}</td>
          <td>${item.wlt}</td>
          <td>${item.points.toFixed(2)}</td>
          <td>${pct(item.wins, item.ties, item.matches)}</td>
          <td>${winTiePct(item.wins, item.ties, item.matches)}</td>
        </tr>`;
      }).join('');
    }

    function renderPairingsTable() {
      const includeFormat = pairingsIncludeFormatDetails();
      updatePairingsModeUI();
      const selectedFormats = includeFormat ? getSelectedValues(el.pairFormat) : [];
      const selectedPairPlayers = getSelectedValues(el.pairPlayer);
      const rows = baseFilter(state.rows, {
        team: el.pairTeam.value,
        year: getSelectedValues(el.pairYear),
      }).filter(row => {
        const format = normalize(row.format);
        if (!TWO_MAN_FORMATS.has(format)) {
          return false;
        }

        if (selectedFormats.length && !selectedFormats.includes(format)) {
          return false;
        }

        const p1 = normalize(row.player1);
        const p2 = normalize(row.player2);
        if (!p1 || !p2) {
          return false;
        }

        if (selectedPairPlayers.length && !selectedPairPlayers.includes(p1) && !selectedPairPlayers.includes(p2)) {
          return false;
        }

        return true;
      });

      const map = new Map();
      for (const row of rows) {
        const team = normalize(row.team);
        const format = normalize(row.format);
        const pair = [normalize(row.player1), normalize(row.player2)].sort((a, b) => a.localeCompare(b)).join(' / ');
        const key = includeFormat ? `${pair}|${team}|${format}` : `${pair}|${team}`;
        if (!map.has(key)) {
          map.set(key, { pair, team, format: includeFormat ? format : '', stats: createRecord() });
        }
        applyResult(map.get(key).stats, row.win_or_loss, points(row.points));
      }

      const performanceOrdered = [...map.values()]
        .sort((a, b) =>
          b.stats.points - a.stats.points ||
          (b.stats.wins + 0.5 * b.stats.ties) - (a.stats.wins + 0.5 * a.stats.ties) ||
          b.stats.matches - a.stats.matches ||
          a.pair.localeCompare(b.pair)
        )
        .map(item => {
          const s = item.stats;
          return {
            pair: item.pair,
            team: item.team,
            format: item.format,
            matches: s.matches,
            wins: s.wins,
            losses: s.losses,
            ties: s.ties,
            wlt: `${s.wins}-${s.losses}-${s.ties}`,
            points: Number(s.points.toFixed(2)),
            winPctValue: s.matches ? ((s.wins + (0.5 * s.ties)) / s.matches) * 100 : 0,
            winTiePctValue: s.matches ? ((s.wins + s.ties) / s.matches) * 100 : 0,
          };
        });
      const minMatches = minMatchesValue(el.pairMinMatches);
      const ranked = performanceOrdered
        .filter(item => item.matches >= minMatches)
        .map((item, index) => ({ ...item, rank: index + 1 }));
      const data = sortRows('pair', ranked);

      if (!data.length) {
        el.pairBody.innerHTML = emptyRow(includeFormat ? 9 : 8);
        return;
      }

      el.pairBody.innerHTML = data.map(item => {
        return `<tr>
          <td>${item.rank}</td>
          <td>${escapeHtml(item.pair)}</td>
          <td>${teamTag(item.team)}</td>
          ${includeFormat ? `<td class="pair-format-col">${escapeHtml(item.format)}</td>` : ''}
          <td>${item.matches}</td>
          <td>${item.wlt}</td>
          <td>${item.points.toFixed(2)}</td>
          <td>${pct(item.wins, item.ties, item.matches)}</td>
          <td>${winTiePct(item.wins, item.ties, item.matches)}</td>
        </tr>`;
      }).join('');
    }

    function renderSinglesTable() {
      const rows = baseFilter(state.rows, {
        team: el.singlesTeam.value,
        format: SINGLES_FORMAT,
      });

      const map = new Map();
      for (const row of rows) {
        const team = normalize(row.team);
        for (const player of playersInRow(row)) {
          const key = `${player}|${team}`;
          if (!map.has(key)) {
            map.set(key, { player, team, stats: createRecord() });
          }
          applyResult(map.get(key).stats, row.win_or_loss, points(row.points));
        }
      }

      const performanceOrdered = [...map.values()]
        .sort((a, b) =>
          b.stats.points - a.stats.points ||
          (b.stats.wins + 0.5 * b.stats.ties) - (a.stats.wins + 0.5 * a.stats.ties) ||
          b.stats.matches - a.stats.matches ||
          a.player.localeCompare(b.player)
        )
        .map(item => {
          const s = item.stats;
          return {
            player: item.player,
            team: item.team,
            matches: s.matches,
            wins: s.wins,
            losses: s.losses,
            ties: s.ties,
            wlt: `${s.wins}-${s.losses}-${s.ties}`,
            points: Number(s.points.toFixed(2)),
            winPctValue: s.matches ? ((s.wins + (0.5 * s.ties)) / s.matches) * 100 : 0,
            winTiePctValue: s.matches ? ((s.wins + s.ties) / s.matches) * 100 : 0,
          };
        });
      const minMatches = minMatchesValue(el.singlesMinMatches);
      const ranked = performanceOrdered
        .filter(item => item.matches >= minMatches)
        .map((item, index) => ({ ...item, rank: index + 1 }));
      const data = sortRows('singles', ranked);

      if (!data.length) {
        el.singlesBody.innerHTML = emptyRow(8);
        return;
      }

      el.singlesBody.innerHTML = data.map(item => {
        return `<tr>
          <td>${item.rank}</td>
          <td>${escapeHtml(item.player)}</td>
          <td>${teamTag(item.team)}</td>
          <td>${item.matches}</td>
          <td>${item.wlt}</td>
          <td>${item.points.toFixed(2)}</td>
          <td>${pct(item.wins, item.ties, item.matches)}</td>
          <td>${winTiePct(item.wins, item.ties, item.matches)}</td>
        </tr>`;
      }).join('');
    }

    function renderLogTable() {
      const teamFilter = el.logTeam.value;
      const yearFilter = getSelectedValues(el.logYear);
      const formatFilter = getSelectedValues(el.logFormat);
      const playerFilter = el.logPlayer.value;

      const filtered = baseFilter(state.rows, {
        year: yearFilter,
        format: formatFilter,
      });

      const grouped = new Map();
      filtered.forEach(row => {
        const key = [
          normalize(row.year),
          normalize(row.round),
          normalize(row.match),
        ].join('|');
        if (!grouped.has(key)) {
          grouped.set(key, { red: null, blue: null });
        }
        const team = normalize(row.team);
        if (team === 'Red') {
          grouped.get(key).red = row;
        } else if (team === 'Blue') {
          grouped.get(key).blue = row;
        }
      });

      const data = sortRows('log', [...grouped.values()]
        .filter(pair => pair.red && pair.blue)
        .map(pair => {
          const redPlayers = playersInRow(pair.red);
          const bluePlayers = playersInRow(pair.blue);
          const redResult = normalize(pair.red.win_or_loss);
          const blueResult = normalize(pair.blue.win_or_loss);
          let winner = '';
          if (redResult.toLowerCase() === 'win') {
            winner = 'Red';
          } else if (blueResult.toLowerCase() === 'win') {
            winner = 'Blue';
          } else if (redResult.toLowerCase() === 'tie' || blueResult.toLowerCase() === 'tie') {
            winner = 'Tie';
          }

          return {
            year: normalize(pair.red.year || pair.blue.year),
            round: normalize(pair.red.round || pair.blue.round),
            match: normalize(pair.red.match || pair.blue.match),
            format: normalize(pair.red.format || pair.blue.format),
            redPlayers: redPlayers.map(playerLastName).join(', '),
            bluePlayers: bluePlayers.map(playerLastName).join(', '),
            redPlayersFull: redPlayers,
            bluePlayersFull: bluePlayers,
            winner,
            score: normalize(pair.red.score || pair.blue.score),
          };
        })
        .filter(row => {
          if (playerFilter === 'All' && teamFilter !== 'All' && row.winner !== teamFilter) {
            return false;
          }
          if (playerFilter !== 'All') {
            const inRed = row.redPlayersFull.includes(playerFilter);
            const inBlue = row.bluePlayersFull.includes(playerFilter);
            if (teamFilter === 'Red' && !inRed) {
              return false;
            }
            if (teamFilter === 'Blue' && !inBlue) {
              return false;
            }
            if (teamFilter === 'All' && !inRed && !inBlue) {
              return false;
            }
          }
          return true;
        }));

      state.logMatchRows = data;
      if (!data.length) {
        el.logBody.innerHTML = emptyRow(6);
        return;
      }

      el.logBody.innerHTML = data.map((row, index) => {
        return `<tr class="match-row-trigger" data-match-source="log" data-match-index="${index}">
          <td>${escapeHtml(row.year)}</td>
          <td>${escapeHtml(row.format)}</td>
          <td>${escapeHtml(row.redPlayers)}</td>
          <td>${escapeHtml(row.bluePlayers)}</td>
          <td>${row.winner === 'Red' || row.winner === 'Blue' ? teamTag(row.winner) : resultTag(row.winner || 'Tie')}</td>
          <td>${escapeHtml(row.score)}</td>
        </tr>`;
      }).join('');
    }

    function rerenderAllTables() {
      renderTeamFormatTable();
      renderHeadToHeadSection();
      renderPlayerTable();
      renderPairingsTable();
      renderLogTable();
      updateSortIndicators();
    }

    function bindFilters() {
      const controls = [
        el.teamFormatYear,
        el.playerTeam,
        el.playerYear,
        el.playerFormat,
        el.playerPlayer,
        el.playerMinMatches,
        el.pairTeam,
        el.pairYear,
        el.pairFormat,
        el.pairPlayer,
        el.pairMinMatches,
        el.pairIncludeFormatDetails,
        el.logTeam,
        el.logYear,
        el.logFormat,
        el.logPlayer,
      ];

      controls.forEach(control => {
        control.addEventListener('change', rerenderAllTables);
        if (control.tagName === 'INPUT') {
          control.addEventListener('input', rerenderAllTables);
        }
      });
    }

    async function loadData() {
      showStatus('Loading tournament data...', false, true);
      try {
        const response = await fetch('./api.php', { cache: 'no-store' });
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`);
        }
        const payload = await response.json();
        if (!payload.success) {
          throw new Error(payload.error || 'Unable to load data.');
        }

        state.rows = Array.isArray(payload.rows) ? payload.rows : [];
        state.yearOutcomes = Array.isArray(payload.yearOutcomes) ? payload.yearOutcomes : [];
        state.matchCourses = Array.isArray(payload.matchCourses) ? payload.matchCourses : [];
        state.matchSummaries = Array.isArray(payload.matchSummaries) ? payload.matchSummaries : [];
        state.playerBios = Array.isArray(payload.playerBios) ? payload.playerBios : [];
        state.holes = Array.isArray(payload.holes) ? payload.holes : [];
        state.holeScores = Array.isArray(payload.scores) ? payload.scores : [];
        state.playerHandicaps = Array.isArray(payload.playerHandicaps) ? payload.playerHandicaps : [];
        state.coursesMeta = Array.isArray(payload.coursesMeta) ? payload.coursesMeta : [];
        state.tournamentSettings = Array.isArray(payload.tournamentSettings) ? payload.tournamentSettings : [];
        state.playerPictures = Array.isArray(payload.playerPictures) ? payload.playerPictures : [];

        if (!state.rows.length) {
          showStatus('No rows were returned from the database.', true);
          return;
        }

        initializeFilters();
        initMultiDropdowns();
        bindHeadToHeadPickerClear();
        bindMatchModal();
        bindPlayerProfileModal();
        bindMatchRowPopups();
        bindFilters();
        bindSorting();
        renderPlayerProfilesSection();
        renderChart();
        rerenderAllTables();
        hideStatus();
      } catch (error) {
        showStatus(`Data load failed: ${error.message}`, true);
        clearBody(el.teamFormatSummary);
        clearBody(el.h2hBody);
        clearBody(el.playerBody);
        clearBody(el.pairBody);
        clearBody(el.logBody);
        el.teamFormatSummary.innerHTML = '<div class="h2h-empty-state">Data unavailable. Confirm database credentials in api.php.</div>';
        el.h2hSummary.innerHTML = '<div class="h2h-empty-state">Data unavailable. Confirm database credentials in api.php.</div>';
        el.h2hBody.innerHTML = emptyRow(6, 'Data unavailable. Confirm database credentials in api.php.');
        el.playerBody.innerHTML = emptyRow(8, 'Data unavailable. Confirm database credentials in api.php.');
        el.pairBody.innerHTML = emptyRow(9, 'Data unavailable. Confirm database credentials in api.php.');
        el.logBody.innerHTML = emptyRow(6, 'Data unavailable. Confirm database credentials in api.php.');
      }
    }

    initCollapsibleSections();
    loadData();
  </script>
</body>
</html>
