<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>BCC Power Rankings</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;700;800&family=Outfit:wght@500;700;900&display=swap" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
  <link rel="stylesheet" href="./styles.css?v=20260402-mobile-defaults">
</head>
<body>
  <div class="shell">
    <header class="hero">
      <img class="hero-logo" src="../assets/bcc_large_font.PNG" alt="Bluff City Cup logo">
      <div class="hero-copy">
        <h1>BCC Power Rankings</h1>
      </div>
    </header>

    <section class="card chart-card">
      <div class="card-head card-head-chart">
        <div>
          <h2>Ranking Trajectories</h2>
          <p id="selectionSummary">Loading chart context...</p>
        </div>
        <div class="filters">
          <label>
            Rating
            <select id="ratingMode"></select>
          </label>
          <label>
            View
            <select id="viewMode"></select>
          </label>
          <label>
            Team
            <select id="teamFilter"></select>
          </label>
          <label>
            Player Highlight
            <select id="playerFilter"></select>
          </label>
        </div>
      </div>
      <div id="status" class="loading">Loading power rankings...</div>
      <div class="chart-wrap">
        <canvas id="rankingsChart"></canvas>
      </div>
      <p class="chart-footnote">
        Higher is better. In Net of Handicap view, the Y-axis shows strokes per 18 versus handicap expectation. Click any line or marker to lock in the selected player and season.
      </p>
    </section>

    <div class="detail-grid">
      <section class="card">
        <div class="card-head">
          <div>
            <h3>Leaderboard</h3>
            <p id="leaderboardMeta">Loading selected board...</p>
          </div>
        </div>
        <div id="leaderboard" class="leaderboard"></div>
      </section>

      <section class="card">
        <div class="card-head">
          <div>
            <h3>Selected Player</h3>
            <p id="profileMeta">Loading player detail...</p>
          </div>
        </div>
        <div id="profile"></div>
      </section>
    </div>

    <section class="card">
      <div class="card-head">
        <div>
          <h3>Model Explanation</h3>
          <p>A simpler read on what this page is measuring and why a player lands where they do.</p>
        </div>
      </div>
      <div id="modelExplanation" class="model-explanation"></div>
    </section>
  </div>

  <script src="./app.js?v=20260402-mobile-defaults"></script>
</body>
</html>
