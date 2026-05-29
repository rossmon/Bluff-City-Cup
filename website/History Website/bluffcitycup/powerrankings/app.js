const state = {
  payload: null,
  chart: null,
  years: [],
  rankingsByYear: new Map(),
  rankingsByPlayer: new Map(),
  seriesByPlayer: new Map(),
  playerSummary: new Map(),
  matchResultsByPlayer: new Map(),
  avatarCache: new Map(),
  spotlightYear: 2025,
  viewMode: 'cumulative',
  ratingMode: 'net',
  teamFilter: 'All',
  selectedPlayer: '',
  isMobile: false,
};

const CHART_AVATAR_SIZE = 57;

const el = {
  status: document.getElementById('status'),
  chartCanvas: document.getElementById('rankingsChart'),
  viewMode: document.getElementById('viewMode'),
  ratingMode: document.getElementById('ratingMode'),
  teamFilter: document.getElementById('teamFilter'),
  playerFilter: document.getElementById('playerFilter'),
  leaderboard: document.getElementById('leaderboard'),
  profile: document.getElementById('profile'),
  modelExplanation: document.getElementById('modelExplanation'),
  selectionSummary: document.getElementById('selectionSummary'),
  leaderboardMeta: document.getElementById('leaderboardMeta'),
  profileMeta: document.getElementById('profileMeta'),
};

function detectMobileLayout() {
  const ua = navigator.userAgent || '';
  const uaDataMobile = navigator.userAgentData && typeof navigator.userAgentData.mobile === 'boolean'
    ? navigator.userAgentData.mobile
    : false;
  const mobileAgent = uaDataMobile || /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile/i.test(ua);
  const narrowViewport = window.matchMedia('(max-width: 900px)').matches;
  return mobileAgent || narrowViewport;
}

function applyDeviceMode({ rerender = false } = {}) {
  const nextMobile = detectMobileLayout();
  if (state.isMobile === nextMobile) {
    document.body.classList.toggle('mobile-browser', nextMobile);
    return;
  }
  state.isMobile = nextMobile;
  document.body.classList.toggle('mobile-browser', nextMobile);
  if (rerender && state.payload) {
    renderAll();
  }
}

function teamClass(team) {
  return String(team || '').toLowerCase() === 'red' ? 'red' : 'blue';
}

function teamLabel() {
  return state.teamFilter === 'All' ? 'All Teams' : `${state.teamFilter} Team`;
}

function formatTrend(value) {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return { label: 'New', className: 'flat' };
  }
  if (value > 0) {
    return { label: `+${value}`, className: 'up' };
  }
  if (value < 0) {
    return { label: `${value}`, className: 'down' };
  }
  return { label: 'EVEN', className: 'flat' };
}

function initialsForPlayer(name) {
  return String(name || '')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map(part => part[0].toUpperCase())
    .join('');
}

function formatPct(value) {
  return `${(Number(value || 0) * 100).toFixed(1)}%`;
}

function clamp01(value) {
  return Math.max(0, Math.min(1, Number(value) || 0));
}

function modePrefix() {
  return state.viewMode === 'cumulative' ? 'cumulative' : 'yearly';
}

function modeField(name) {
  return `${modePrefix()}_${name}`;
}

function ratingModeLabel() {
  return state.ratingMode === 'net' ? 'Net of Handicap' : 'Power Ratings';
}

function selectedRankField() {
  return state.ratingMode === 'net'
    ? modeField('net_handicap_rank')
    : modeField('rank');
}

function selectedScoreField() {
  return state.ratingMode === 'net'
    ? modeField('score_performance_adj')
    : modeField('power_score');
}

function selectedTrendField() {
  return state.ratingMode === 'net'
    ? modeField('net_handicap_trend')
    : modeField('trend');
}

function pointModeValue(point, metric) {
  const mapping = {
    score: state.ratingMode === 'net'
      ? (state.viewMode === 'cumulative' ? point.cumulativeScorePerformance : point.yearlyScorePerformance)
      : (state.viewMode === 'cumulative' ? point.cumulativeScore : point.yearlyScore),
    rank: state.ratingMode === 'net'
      ? (state.viewMode === 'cumulative' ? point.cumulativeNetHandicapRank : point.yearlyNetHandicapRank)
      : (state.viewMode === 'cumulative' ? point.cumulativeRank : point.yearlyRank),
    scorePerformance: state.viewMode === 'cumulative' ? point.cumulativeScorePerformance : point.yearlyScorePerformance,
    weightedWinPct: state.viewMode === 'cumulative' ? point.cumulativeWeightedWinPct : point.yearlyWeightedWinPct,
    overallWinPct: state.viewMode === 'cumulative' ? point.cumulativeOverallWinPct : point.yearlyOverallWinPct,
    singlesWinPct: state.viewMode === 'cumulative' ? point.cumulativeSinglesWinPct : point.yearlySinglesWinPct,
  };
  return mapping[metric] ?? null;
}

function formatModeLabel() {
  return state.viewMode === 'cumulative' ? 'Cumulative' : 'Year-by-Year';
}

function cumulativeWindowStartYear(year = state.spotlightYear) {
  const minYear = state.years.length ? Math.min(...state.years) : Number(year);
  return Math.max(minYear, Number(year) - 4);
}

function numberOrNull(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function fillSelect(select, options, selectedValue) {
  select.innerHTML = options
    .map(option => `<option value="${option.value}">${option.label}</option>`)
    .join('');
  select.value = selectedValue;
}

function createFallbackAvatar(player, team, size = CHART_AVATAR_SIZE) {
  const canvas = document.createElement('canvas');
  canvas.width = size;
  canvas.height = size;
  const ctx = canvas.getContext('2d');
  const gradient = ctx.createLinearGradient(0, 0, size, size);
  if (team === 'Red') {
    gradient.addColorStop(0, '#bf0f21');
    gradient.addColorStop(1, '#8f0b19');
  } else {
    gradient.addColorStop(0, '#0b387e');
    gradient.addColorStop(1, '#062558');
  }
  ctx.fillStyle = gradient;
  ctx.beginPath();
  ctx.arc(size / 2, size / 2, size / 2, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = '#fff';
  ctx.font = `700 ${Math.round(size * 0.3)}px Manrope`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(initialsForPlayer(player), size / 2, size / 2 + 1);
  return canvas;
}

async function avatarCanvasForPlayer(player) {
  if (state.avatarCache.has(player)) {
    return state.avatarCache.get(player);
  }

  const summary = state.playerSummary.get(player);
  const team = summary?.team_2025 || 'Blue';
  const fallback = createFallbackAvatar(player, team, CHART_AVATAR_SIZE);
  if (!summary?.avatar_url) {
    state.avatarCache.set(player, fallback);
    return fallback;
  }

  const image = new Image();
  image.decoding = 'async';
  image.src = summary.avatar_url;

  const promise = new Promise(resolve => {
    image.onload = () => {
      const canvas = document.createElement('canvas');
      canvas.width = CHART_AVATAR_SIZE;
      canvas.height = CHART_AVATAR_SIZE;
      const center = CHART_AVATAR_SIZE / 2;
      const imageRadius = (CHART_AVATAR_SIZE / 2) - 3;
      const ctx = canvas.getContext('2d');
      ctx.clearRect(0, 0, CHART_AVATAR_SIZE, CHART_AVATAR_SIZE);
      ctx.save();
      ctx.beginPath();
      ctx.arc(center, center, imageRadius, 0, Math.PI * 2);
      ctx.closePath();
      ctx.clip();
      ctx.drawImage(image, 0, 0, CHART_AVATAR_SIZE, CHART_AVATAR_SIZE);
      ctx.restore();
      ctx.lineWidth = 2.25;
      ctx.strokeStyle = team === 'Red' ? '#bf0f21' : '#0b387e';
      ctx.beginPath();
      ctx.arc(center, center, imageRadius, 0, Math.PI * 2);
      ctx.stroke();
      resolve(canvas);
    };
    image.onerror = () => resolve(fallback);
  });

  state.avatarCache.set(player, promise);
  return promise;
}

function normalizeResult(result) {
  const normalized = String(result || '').toLowerCase();
  if (normalized === 'win') {
    return 'Win';
  }
  if (normalized === 'loss') {
    return 'Loss';
  }
  return 'Tie';
}

function resultClass(result) {
  return normalizeResult(result).toLowerCase();
}

function formatPlayers(list) {
  return Array.isArray(list) && list.length ? list.join(', ') : '—';
}

function getYearRows(year) {
  return state.rankingsByYear.get(Number(year)) || [];
}

function getVisibleYearRows() {
  const rows = getYearRows(state.spotlightYear);
  return rows
    .filter(row => state.teamFilter === 'All' || row.team_2025 === state.teamFilter)
    .sort((a, b) =>
      (Number(a[selectedRankField()]) - Number(b[selectedRankField()]))
      || String(a.player).localeCompare(String(b.player))
    );
}

function getSelectablePlayers() {
  return state.payload.players
    .filter(player => state.teamFilter === 'All' || player.team_2025 === state.teamFilter)
    .sort((a, b) => String(a.player).localeCompare(String(b.player)));
}

function updatePlayerFilterOptions(preferredPlayer = state.selectedPlayer) {
  const options = [
    { value: '', label: 'Auto highlight' },
    ...getSelectablePlayers().map(player => ({ value: player.player, label: player.player })),
  ];
  const stillValid = options.some(option => option.value === preferredPlayer);
  if (!stillValid) {
    state.selectedPlayer = '';
    preferredPlayer = '';
  } else {
    state.selectedPlayer = preferredPlayer;
  }
  fillSelect(el.playerFilter, options, preferredPlayer);
}

function getSelectedPlayer() {
  if (state.selectedPlayer) {
    return state.selectedPlayer;
  }
  return getVisibleYearRows()[0]?.player || getSelectablePlayers()[0]?.player || '';
}

function getCurrentRowForPlayer(player) {
  const history = state.rankingsByPlayer.get(player) || [];
  return history.find(row => Number(row.year) === Number(state.spotlightYear))
    || [...history].filter(row => Number(row.year) <= Number(state.spotlightYear)).slice(-1)[0]
    || history.slice(-1)[0]
    || null;
}

function getPlayerScopedMatches(player, year = state.spotlightYear, mode = state.viewMode) {
  const allMatches = state.matchResultsByPlayer.get(player) || [];
  const startYear = cumulativeWindowStartYear(year);
  return allMatches
    .filter(match => (
      mode === 'cumulative'
        ? Number(match.year) >= startYear && Number(match.year) <= Number(year)
        : Number(match.year) === Number(year)
    ))
    .sort((a, b) =>
      Number(b.year) - Number(a.year)
      || Number(b.round) - Number(a.round)
      || Number(b.match) - Number(a.match)
    );
}

function summarizeOfficialMatches(matches) {
  const summary = {
    matches: 0,
    wins: 0,
    losses: 0,
    ties: 0,
    points: 0,
    singlesMatches: 0,
    singlesWins: 0,
    singlesLosses: 0,
    singlesTies: 0,
  };

  matches.forEach(match => {
    summary.matches += 1;
    summary.points += Number(match.points || 0);
    const result = normalizeResult(match.result);
    if (result === 'Win') {
      summary.wins += 1;
    } else if (result === 'Loss') {
      summary.losses += 1;
    } else {
      summary.ties += 1;
    }

    if (String(match.format) === 'Singles') {
      summary.singlesMatches += 1;
      if (result === 'Win') {
        summary.singlesWins += 1;
      } else if (result === 'Loss') {
        summary.singlesLosses += 1;
      } else {
        summary.singlesTies += 1;
      }
    }
  });

  summary.winPctValue = summary.matches
    ? (summary.wins + (0.5 * summary.ties)) / summary.matches
    : 0;
  summary.winPctLabel = formatPct(summary.winPctValue);
  summary.recordLabel = `${summary.wins}-${summary.losses}-${summary.ties}`;
  summary.singlesRecordLabel = `${summary.singlesWins}-${summary.singlesLosses}-${summary.singlesTies}`;
  return summary;
}

function percentileFromValues(values, target) {
  const numericValues = values
    .map(value => Number(value))
    .filter(value => Number.isFinite(value));
  const numericTarget = Number(target);
  if (!numericValues.length || !Number.isFinite(numericTarget)) {
    return 0.5;
  }
  if (numericValues.length === 1) {
    return 1;
  }
  const epsilon = 1e-9;
  const lower = numericValues.filter(value => value < (numericTarget - epsilon)).length;
  const equal = numericValues.filter(value => Math.abs(value - numericTarget) <= epsilon).length;
  const averageIndex = lower + (Math.max(1, equal) - 1) / 2;
  return clamp01(averageIndex / (numericValues.length - 1));
}

function gradientColorForPercentile(percentile) {
  const safe = clamp01(percentile);
  const hue = Math.round(safe * 120);
  return `hsl(${hue} 72% 42%)`;
}

function comparisonSnapshot(year, mode) {
  const comparisonRows = getYearRows(year);
  const scoreValues = comparisonRows
    .map(row => Number(row[mode === 'cumulative' ? 'cumulative_score_performance_adj' : 'yearly_score_performance_adj']))
    .filter(value => Number.isFinite(value));
  const officialWinValues = comparisonRows
    .map(row => summarizeOfficialMatches(getPlayerScopedMatches(row.player, year, mode)).winPctValue)
    .filter(value => Number.isFinite(value));

  return {
    fieldSize: comparisonRows.length,
    scoreValues,
    officialWinValues,
  };
}

function getScoreBounds() {
  const teamFilteredSeries = state.payload.series.filter(series =>
    state.teamFilter === 'All' || series.team === state.teamFilter
  );
  const scores = teamFilteredSeries
    .flatMap(series => series.points.map(point => pointModeValue(point, 'score')))
    .filter(value => value !== null && value !== undefined)
    .map(value => Number(value))
    .filter(value => Number.isFinite(value));

  if (!scores.length) {
    return state.ratingMode === 'net'
      ? { min: -3, max: 3 }
      : { min: 40, max: 60 };
  }

  const minScore = Math.min(...scores);
  const maxScore = Math.max(...scores);
  const padding = state.ratingMode === 'net'
    ? Math.max(0.6, (maxScore - minScore) * 0.12)
    : Math.max(3.5, (maxScore - minScore) * 0.1);
  return {
    min: state.ratingMode === 'net' ? (minScore - padding) : Math.max(0, minScore - padding),
    max: maxScore + padding,
  };
}

function formatSelectedMetricValue(value) {
  const numeric = Number(value ?? 0);
  if (state.ratingMode === 'net') {
    return `${numeric.toFixed(2)} strokes/18`;
  }
  return numeric.toFixed(1);
}

function latestMarkerOffset() {
  return state.isMobile ? 0.18 : 0.24;
}

function playerSeriesDataset(series) {
  const isSelected = state.selectedPlayer === series.player;
  const dimmed = state.selectedPlayer && !isSelected;
  const alpha = isSelected ? 1 : (dimmed ? 0.24 : 0.82);
  const color = series.lineColor;
  const latestIndex = series.points.reduce(
    (found, point, index) => (pointModeValue(point, 'score') !== null ? index : found),
    -1,
  );

  return {
    label: series.player,
    playerName: series.player,
    team: series.team,
    data: series.points.map((point, index) => {
      const isLatestPoint = index === latestIndex;
      const rank = pointModeValue(point, 'rank');
      const score = pointModeValue(point, 'score');
      return {
        x: point.x + (isLatestPoint ? latestMarkerOffset() : 0),
        season: point.x,
        y: score,
        rank,
        powerScore: score,
        scorePerformance: pointModeValue(point, 'scorePerformance'),
        winPctWeighted: pointModeValue(point, 'weightedWinPct'),
        winPctOverall: pointModeValue(point, 'overallWinPct'),
        winPctSingles: pointModeValue(point, 'singlesWinPct'),
      };
    }),
    borderColor: `${color}${Math.round(alpha * 255).toString(16).padStart(2, '0')}`,
    backgroundColor: `${color}${Math.round(alpha * 255).toString(16).padStart(2, '0')}`,
    borderWidth: isSelected ? 3.4 : 2,
    spanGaps: false,
    clip: false,
    tension: 0.28,
    segment: {
      borderColor: ctx => (
        ctx.p0.skip || ctx.p1.skip
          ? 'transparent'
          : `${color}${Math.round(alpha * 255).toString(16).padStart(2, '0')}`
      ),
    },
    pointRadius: context => {
      const point = context.raw;
      if (point?.y === null) {
        return 0;
      }
      if (context.dataIndex === latestIndex) {
        return state.isMobile
          ? (isSelected ? 4.5 : 3.8)
          : (isSelected ? 11.1 : 9.3);
      }
      return state.isMobile
        ? (isSelected ? 1.8 : 1.4)
        : (isSelected ? 3.3 : 2.5);
    },
    pointHoverRadius: context => (context.dataIndex === latestIndex ? (state.isMobile ? 8 : 14.25) : (state.isMobile ? 4 : 6)),
    pointHitRadius: context => (context.dataIndex === latestIndex ? (state.isMobile ? 11 : 22.5) : (state.isMobile ? 5 : 8)),
    pointBorderWidth: 0,
    pointBackgroundColor: context => (context.dataIndex === latestIndex ? `${color}00` : color),
    pointStyle: context => (
      context.dataIndex === latestIndex
        ? (state.avatarCache.get(series.player) || 'circle')
        : 'circle'
    ),
    order: isSelected ? 1 : 10,
  };
}

function renderSelectionSummary() {
  const playerLabel = getSelectedPlayer();
  const playerText = playerLabel ? ` · Highlight ${playerLabel}` : '';
  const scopeText = state.viewMode === 'cumulative'
    ? `Rolling ${cumulativeWindowStartYear()}-${state.spotlightYear}`
    : `Selected season ${state.spotlightYear}`;
  el.selectionSummary.textContent = `${ratingModeLabel()} · ${formatModeLabel()} view · ${teamLabel()} · ${scopeText}${playerText}`;
  el.leaderboardMeta.textContent = `${state.spotlightYear} board · ${state.viewMode === 'cumulative' ? 'rolling 5-year scope' : 'year-by-year scope'} · Win % matches the player records page formula`;
}

function renderLeaderboard() {
  const rows = getVisibleYearRows();
  if (!rows.length) {
    el.leaderboard.innerHTML = '<div class="empty-state">No players match the current team filter for that season.</div>';
    return;
  }

  el.leaderboard.innerHTML = rows.map(row => {
    const trend = formatTrend(row[selectedTrendField()]);
    const selectedClass = getSelectedPlayer() === row.player ? 'is-active' : '';
    const official = summarizeOfficialMatches(getPlayerScopedMatches(row.player, state.spotlightYear, state.viewMode));
    return `
      <button class="leaderboard-row ${selectedClass}" data-player="${row.player}">
        <div class="leaderboard-rank">#${row[selectedRankField()]}</div>
        <img class="avatar" src="${row.avatar_url || ''}" alt="${row.player}">
        <div>
          <div class="leaderboard-name">${row.player}</div>
          <span class="leaderboard-meta">${row.team_2025} · Record ${official.recordLabel} · Win ${official.winPctLabel}</span>
        </div>
        <div class="leaderboard-score">
          <span class="value">${state.ratingMode === 'net' ? Number(row[selectedScoreField()]).toFixed(2) : Number(row[selectedScoreField()]).toFixed(1)}</span>
          <span class="trend ${trend.className}">${trend.label}</span>
        </div>
      </button>
    `;
  }).join('');
}

function renderProfile() {
  const player = getSelectedPlayer();
  if (!player) {
    el.profileMeta.textContent = 'Select a player to inspect the board.';
    el.profile.innerHTML = '<div class="empty-state">No player is available for the current filters.</div>';
    return;
  }

  state.selectedPlayer = player;
  el.playerFilter.value = player;

  const summary = state.playerSummary.get(player);
  const current = getCurrentRowForPlayer(player);
  const trend = formatTrend(current?.[selectedTrendField()]);
  const comparisonYear = Number(current?.year ?? state.spotlightYear);
  const scopedMatches = getPlayerScopedMatches(player, state.spotlightYear, state.viewMode);
  const official = summarizeOfficialMatches(scopedMatches);
  const selectionYearText = current && Number(current.year) !== Number(state.spotlightYear)
    ? `Latest active season before selection: ${current.year}`
    : `Selected season ${state.spotlightYear}`;
  const snapshot = comparisonSnapshot(comparisonYear, state.viewMode);
  const scorePerformanceValue = Number(current?.[modeField('score_performance_adj')] || 0);
  const scorePercentile = percentileFromValues(snapshot.scoreValues, scorePerformanceValue);
  const officialWinPercentile = percentileFromValues(snapshot.officialWinValues, official.winPctValue);
  const scoreFieldLabel = snapshot.fieldSize
    ? `Relative to ${snapshot.fieldSize} players in this ${state.viewMode === 'cumulative' ? 'rolling 5-year window' : 'season'}`
    : 'Relative to the current field';
  const winFieldLabel = snapshot.fieldSize
    ? `Better than about ${Math.round(scorePercentile * 100)}% of the field on score performance`
    : '';
  const officialFieldLabel = snapshot.fieldSize
    ? `Better than about ${Math.round(officialWinPercentile * 100)}% of the field on official win rate`
    : '';
  const scoreBarColor = gradientColorForPercentile(scorePercentile);
  const officialBarColor = gradientColorForPercentile(officialWinPercentile);
  const ratingMetricLabel = state.ratingMode === 'net' ? 'Net of Handicap' : 'Power Score';
  const rankMetricLabel = state.ratingMode === 'net' ? `${formatModeLabel()} Net Rank` : `${formatModeLabel()} Power Rank`;

  el.profileMeta.textContent = `${player} · ${ratingModeLabel()} · ${state.viewMode === 'cumulative' ? `rolling five-season scope through ${state.spotlightYear}` : `${state.spotlightYear}`}`;

  const resultsRows = scopedMatches.length
    ? scopedMatches.map(match => `
        <tr>
          <td>${match.year}</td>
          <td>R${match.round} · M${match.match}</td>
          <td>${match.format}</td>
          <td>${formatPlayers(match.teammates)}</td>
          <td>${formatPlayers(match.opponents)}</td>
          <td><span class="result-pill ${resultClass(match.result)}">${normalizeResult(match.result)}</span></td>
          <td>${match.score || '—'}</td>
        </tr>
      `).join('')
    : `<tr><td colspan="7">No matches found for this player in the selected ${state.viewMode} scope.</td></tr>`;

  const resultsCards = scopedMatches.length
    ? scopedMatches.map(match => `
        <article class="result-card">
          <div class="result-card-top">
            <div>
              <div class="result-card-title">${match.year} · R${match.round} · M${match.match}</div>
              <div class="result-card-format">${match.format}</div>
            </div>
            <span class="result-pill ${resultClass(match.result)}">${normalizeResult(match.result)}</span>
          </div>
          <div class="result-card-grid">
            <div><span class="key">With</span><span class="value">${formatPlayers(match.teammates)}</span></div>
            <div><span class="key">Vs</span><span class="value">${formatPlayers(match.opponents)}</span></div>
            <div><span class="key">Score</span><span class="value">${match.score || '—'}</span></div>
          </div>
        </article>
      `).join('')
    : '<div class="empty-state">No matches found for this player in the selected view.</div>';

  el.profile.innerHTML = `
    <div class="profile-shell">
      <div class="profile-head">
        <img class="avatar" src="${summary?.avatar_url || ''}" alt="${player}">
        <div>
          <h3 class="profile-name">${player}</h3>
          <span class="team-pill ${teamClass(summary?.team_2025)}">${summary?.team_2025 || 'BCC'}</span>
        </div>
        <div class="profile-score">
          <span class="label">${rankMetricLabel}</span>
          <span class="value">#${current?.[selectedRankField()] ?? '—'}</span>
          <span class="trend ${trend.className}">${trend.label}</span>
        </div>
      </div>

      <div class="selection-meta">${selectionYearText}</div>

      <div class="profile-grid">
        <div class="profile-metric">
          <span class="label">${ratingMetricLabel}</span>
          <span class="value">${formatSelectedMetricValue(current?.[selectedScoreField()] ?? 0)}</span>
        </div>
        <div class="profile-metric">
          <span class="label">Official Win %</span>
          <span class="value">${official.winPctLabel}</span>
        </div>
        <div class="profile-metric">
          <span class="label">Official Record</span>
          <span class="value">${official.recordLabel}</span>
        </div>
      </div>

      <div class="profile-breakdown">
        <div class="bar-row">
          <div class="label"><span>Score performance vs expected</span><span>${Number(current?.[modeField('score_performance_adj')] || 0).toFixed(2)} strokes/18</span></div>
          <span class="meta">${scoreFieldLabel}. ${winFieldLabel}</span>
          <div class="bar-track"><div class="bar-fill" style="width:${Math.max(7, Math.round(scorePercentile * 1000) / 10)}%;background:${scoreBarColor}"></div></div>
        </div>
        <div class="bar-row">
          <div class="label"><span>Official win rate</span><span>${official.winPctLabel}</span></div>
          <span class="meta">${scoreFieldLabel}. ${officialFieldLabel}</span>
          <div class="bar-track"><div class="bar-fill" style="width:${Math.max(7, Math.round(officialWinPercentile * 1000) / 10)}%;background:${officialBarColor}"></div></div>
        </div>
      </div>

      <details class="results-shell">
        <summary class="results-summary">Player match results</summary>
        <div class="results-shell-body">
          <div class="results-cards">${resultsCards}</div>
          <div class="results-table-wrap">
            <table class="results-table">
              <thead>
                <tr>
                  <th>Year</th>
                  <th>Match</th>
                  <th>Format</th>
                  <th>With</th>
                  <th>Vs</th>
                  <th>Result</th>
                  <th>Score</th>
                </tr>
              </thead>
              <tbody>${resultsRows}</tbody>
            </table>
          </div>
        </div>
      </details>
    </div>
  `;
}

function rebuildChart() {
  const datasets = state.payload.series
    .filter(series => state.teamFilter === 'All' || series.team === state.teamFilter)
    .map(playerSeriesDataset);
  const scoreBounds = getScoreBounds();
  const minChartYear = state.years.length ? Math.min(...state.years) : 2017;
  const maxChartYear = Math.max(2026, ...(state.years.length ? state.years : [2025]));

  const baseOptions = {
    animation: false,
    responsive: true,
    maintainAspectRatio: false,
    interaction: {
      mode: 'nearest',
      intersect: false,
    },
    onClick(event, elements, chart) {
      const points = chart.getElementsAtEventForMode(
        event,
        'nearest',
        { intersect: false },
        true,
      );
      if (!points.length) {
        return;
      }
      const point = points[0];
      const dataset = chart.data.datasets[point.datasetIndex];
      const raw = dataset.data[point.index];
      state.selectedPlayer = dataset.playerName || '';
      state.spotlightYear = Number(raw.season || raw.x || state.spotlightYear);
      updatePlayerFilterOptions();
      el.playerFilter.value = state.selectedPlayer;
      renderAll();
    },
    onHover(event, elements, chart) {
      chart.canvas.style.cursor = elements.length ? 'pointer' : 'default';
    },
    layout: {
      padding: state.isMobile
        ? { top: 22, right: 42, bottom: 6, left: 2 }
        : { top: 34, right: 112, bottom: 10, left: 12 },
    },
    plugins: {
      legend: { display: false },
      tooltip: {
        enabled: !state.isMobile,
        padding: 12,
        cornerRadius: 14,
        displayColors: false,
        callbacks: {
          title(items) {
            return `Season ${items[0].raw.season ?? items[0].raw.x}`;
          },
          label(item) {
            const series = state.seriesByPlayer.get(item.dataset.playerName);
            const row = (state.rankingsByPlayer.get(series.player) || [])
              .find(entry => Number(entry.year) === Number(item.raw.season ?? item.raw.x));
            const rankValue = row?.[selectedRankField()] ?? item.raw.rank ?? '—';
            return `${series.player} · ${state.ratingMode === 'net' ? `${Number(item.raw.y).toFixed(2)} strokes/18` : `${ratingModeLabel()} ${Number(item.raw.y).toFixed(1)}`} · Rank #${rankValue}`;
          },
          afterLabel(item) {
            const series = state.seriesByPlayer.get(item.dataset.playerName);
            const row = (state.rankingsByPlayer.get(series.player) || [])
              .find(entry => Number(entry.year) === Number(item.raw.season ?? item.raw.x));
            const official = summarizeOfficialMatches(
              getPlayerScopedMatches(series.player, Number(item.raw.season ?? item.raw.x), state.viewMode),
            );
            if (!row) {
              return '';
            }
            return [
              state.ratingMode === 'net'
                ? `Net of Handicap ${Number(row[selectedScoreField()]).toFixed(2)} strokes/18`
                : `${ratingModeLabel()} ${Number(row[selectedScoreField()]).toFixed(1)}`,
              `Score perf ${Number(row[modeField('score_performance_adj')]).toFixed(2)} · Official win ${official.winPctLabel}`,
            ];
          },
        },
      },
    },
    scales: {
      x: {
        type: 'linear',
        min: minChartYear,
        max: maxChartYear,
        ticks: {
          stepSize: 1,
          color: '#5f6e8d',
          font: { weight: 700, size: state.isMobile ? 10 : 12 },
          callback: value => (Number.isInteger(value) ? String(value) : ''),
        },
        grid: {
          color: 'rgba(95, 110, 141, 0.10)',
        },
      },
      y: {
        min: scoreBounds.min,
        max: scoreBounds.max,
        ticks: {
          color: '#5f6e8d',
          font: { weight: 700, size: state.isMobile ? 10 : 12 },
          callback: value => state.ratingMode === 'net' ? Number(value).toFixed(1) : Number(value).toFixed(0),
        },
        grid: {
          color: 'rgba(95, 110, 141, 0.12)',
        },
        title: {
          display: true,
          text: state.ratingMode === 'net' ? 'Net of Handicap (strokes/18)' : 'Power Score',
          color: '#42526f',
          font: { weight: 800, size: state.isMobile ? 11 : 13 },
        },
      },
    },
  };

  if (!state.chart) {
    state.chart = new Chart(el.chartCanvas, {
      type: 'line',
      data: { datasets },
      options: baseOptions,
    });
    return;
  }

  state.chart.data.datasets = datasets;
  state.chart.options = baseOptions;
  state.chart.update();
}

function renderAll() {
  renderSelectionSummary();
  renderLeaderboard();
  renderProfile();
  rebuildChart();
}

function syncControls({ fromPlayerSelect = false } = {}) {
  state.viewMode = el.viewMode.value;
  state.ratingMode = el.ratingMode.value;
  state.teamFilter = el.teamFilter.value;
  if (fromPlayerSelect) {
    state.selectedPlayer = el.playerFilter.value;
    updatePlayerFilterOptions(state.selectedPlayer);
  } else {
    updatePlayerFilterOptions(state.selectedPlayer);
  }
  if (!fromPlayerSelect && state.selectedPlayer) {
    el.playerFilter.value = state.selectedPlayer;
  }
  renderAll();
}

function initControls() {
  fillSelect(
    el.viewMode,
    [
      { value: 'yearly', label: 'Year-by-Year' },
      { value: 'cumulative', label: 'Cumulative' },
    ],
    state.viewMode,
  );
  fillSelect(
    el.ratingMode,
    [
      { value: 'power', label: 'Power Ratings' },
      { value: 'net', label: 'Net of Handicap' },
    ],
    state.ratingMode,
  );
  fillSelect(
    el.teamFilter,
    [
      { value: 'All', label: 'All Teams' },
      { value: 'Red', label: 'Red Team' },
      { value: 'Blue', label: 'Blue Team' },
    ],
    state.teamFilter,
  );
  updatePlayerFilterOptions();

  el.viewMode.addEventListener('change', () => syncControls());
  el.ratingMode.addEventListener('change', () => syncControls());
  el.teamFilter.addEventListener('change', () => syncControls());
  el.playerFilter.addEventListener('change', () => syncControls({ fromPlayerSelect: true }));

  el.leaderboard.addEventListener('click', event => {
    const row = event.target.closest('[data-player]');
    if (!row) {
      return;
    }
    state.selectedPlayer = row.dataset.player || '';
    updatePlayerFilterOptions();
    el.playerFilter.value = state.selectedPlayer;
    renderAll();
  });
}

async function bootstrap() {
  try {
    applyDeviceMode();
    const response = await fetch('./api.php', { cache: 'no-store' });
    const payload = await response.json();
    if (!payload.success) {
      throw new Error(payload.error || 'Unable to load rankings.');
    }

    state.payload = payload;
    state.years = Array.isArray(payload.years) ? payload.years.map(Number) : [];
    state.spotlightYear = payload.cohortYear || 2025;
    state.viewMode = 'cumulative';
    state.ratingMode = 'net';

    payload.rankings.forEach(row => {
      row.year = Number(row.year);
      row.yearly_rank = Number(row.yearly_rank);
      row.yearly_power_score = Number(row.yearly_power_score);
      row.yearly_net_handicap_rank = Number(row.yearly_net_handicap_rank);
      row.yearly_net_handicap_score = Number(row.yearly_net_handicap_score);
      row.yearly_score_performance_raw = Number(row.yearly_score_performance_raw);
      row.yearly_score_performance_adj = Number(row.yearly_score_performance_adj);
      row.yearly_score_index = Number(row.yearly_score_index);
      row.yearly_win_pct_weighted = Number(row.yearly_win_pct_weighted);
      row.yearly_win_pct_overall = Number(row.yearly_win_pct_overall);
      row.yearly_win_pct_singles = Number(row.yearly_win_pct_singles);
      row.yearly_rounds_played = Number(row.yearly_rounds_played);
      row.yearly_matches_played = Number(row.yearly_matches_played);
      row.yearly_singles_matches = Number(row.yearly_singles_matches);
      row.yearly_weighted_match_units = Number(row.yearly_weighted_match_units);
      row.cumulative_rank = Number(row.cumulative_rank);
      row.cumulative_power_score = Number(row.cumulative_power_score);
      row.cumulative_net_handicap_rank = Number(row.cumulative_net_handicap_rank);
      row.cumulative_net_handicap_score = Number(row.cumulative_net_handicap_score);
      row.cumulative_score_performance_raw = Number(row.cumulative_score_performance_raw);
      row.cumulative_score_performance_adj = Number(row.cumulative_score_performance_adj);
      row.cumulative_score_index = Number(row.cumulative_score_index);
      row.cumulative_win_pct_weighted = Number(row.cumulative_win_pct_weighted);
      row.cumulative_win_pct_overall = Number(row.cumulative_win_pct_overall);
      row.cumulative_win_pct_singles = Number(row.cumulative_win_pct_singles);
      row.cumulative_rounds_played = Number(row.cumulative_rounds_played);
      row.cumulative_matches_played = Number(row.cumulative_matches_played);
      row.cumulative_singles_matches = Number(row.cumulative_singles_matches);
      row.cumulative_weighted_match_units = Number(row.cumulative_weighted_match_units);
      row.cumulative_years_scored = Number(row.cumulative_years_scored);
      row.handicap_index = numberOrNull(row.handicap_index);
      row.yearly_trend = row.yearly_trend === null ? null : Number(row.yearly_trend);
      row.yearly_net_handicap_trend = row.yearly_net_handicap_trend === null ? null : Number(row.yearly_net_handicap_trend);
      row.cumulative_trend = row.cumulative_trend === null ? null : Number(row.cumulative_trend);
      row.cumulative_net_handicap_trend = row.cumulative_net_handicap_trend === null ? null : Number(row.cumulative_net_handicap_trend);

      if (!state.rankingsByYear.has(row.year)) {
        state.rankingsByYear.set(row.year, []);
      }
      state.rankingsByYear.get(row.year).push(row);

      if (!state.rankingsByPlayer.has(row.player)) {
        state.rankingsByPlayer.set(row.player, []);
      }
      state.rankingsByPlayer.get(row.player).push(row);
    });

    payload.players.forEach(player => {
      state.playerSummary.set(player.player, player);
    });

    payload.series.forEach(series => {
      state.seriesByPlayer.set(series.player, series);
    });

    Object.entries(payload.playerResults || {}).forEach(([player, matches]) => {
      state.matchResultsByPlayer.set(
        player,
        Array.isArray(matches)
          ? matches.map(match => ({
              ...match,
              year: Number(match.year),
              round: Number(match.round),
              match: Number(match.match),
              points: Number(match.points),
            }))
          : [],
      );
    });

    await Promise.all(payload.players.map(player =>
      avatarCanvasForPlayer(player.player).then(canvas => {
        state.avatarCache.set(player.player, canvas);
      })
    ));

    const rollingWindowText = 'When you switch to cumulative, the page only looks at the last five seasons for that point in time and leans more on the newest ones.';
    el.modelExplanation.innerHTML = `
      <p><strong>This page is meant to show form at a point in time.</strong> It is not trying to reward who has the best lifetime resume. It is trying to show who was playing the strongest golf in that season or window of seasons.</p>
      <p><strong>Power Ratings blend two ideas.</strong> Most of the score comes from how a player shot compared with what their handicap said to expect. The rest comes from how often they got match results on the board, with extra credit given to singles results.</p>
      <p><strong>Net of Handicap strips that down to only one idea.</strong> It ignores wins and losses and looks only at whether a player or team score beat handicap expectation.</p>
      <p><strong>Not every format is treated the same.</strong> Formats with an individual score, like Singles, Best Ball, and Shamble, count more. Formats with a shared team score, like Modified Alternate Shot and 2 Man Scramble, still count but count a little less.</p>
      <p><strong>${rollingWindowText}</strong> That keeps the cumulative view centered on recent form instead of letting older seasons control the picture.</p>
    `;

    initControls();
    renderAll();
    el.status.remove();
    window.addEventListener('resize', () => applyDeviceMode({ rerender: true }));
    window.addEventListener('orientationchange', () => applyDeviceMode({ rerender: true }));
  } catch (error) {
    el.status.className = 'error';
    el.status.textContent = error instanceof Error ? error.message : 'Unable to load rankings.';
  }
}

bootstrap();
