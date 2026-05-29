<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

const DB_HOST = 'localhost';
const DB_PORT = '5432';
const DB_NAME = 'bluffcitycup';
const DB_USER = 'bcc_admin';
const DB_PASS = 'memphis';
const DB_SSLMODE = 'disable';

function fail(string $message, int $status = 500): void
{
    http_response_code($status);
    echo json_encode([
        'success' => false,
        'error' => $message,
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

function runPsqlJson(string $sql): array
{
    $conn = sprintf(
        'host=%s port=%s dbname=%s user=%s sslmode=%s',
        DB_HOST,
        DB_PORT,
        DB_NAME,
        DB_USER,
        DB_SSLMODE
    );

    $command = sprintf(
        'psql %s -At -v ON_ERROR_STOP=1 -c %s',
        escapeshellarg($conn),
        escapeshellarg($sql)
    );

    $descriptors = [
        0 => ['pipe', 'r'],
        1 => ['pipe', 'w'],
        2 => ['pipe', 'w'],
    ];

    $env = ['PGPASSWORD' => DB_PASS];
    $process = proc_open($command, $descriptors, $pipes, null, $env);

    if (!is_resource($process)) {
        throw new RuntimeException('Unable to start database process.');
    }

    fclose($pipes[0]);
    $stdout = stream_get_contents($pipes[1]);
    $stderr = stream_get_contents($pipes[2]);
    fclose($pipes[1]);
    fclose($pipes[2]);

    $exitCode = proc_close($process);
    if ($exitCode !== 0) {
        throw new RuntimeException(trim($stderr) !== '' ? trim($stderr) : 'Database query failed.');
    }

    $json = trim($stdout);
    if ($json === '') {
        return [];
    }

    $decoded = json_decode($json, true);
    if (!is_array($decoded)) {
        throw new RuntimeException('Database returned unreadable JSON.');
    }

    return $decoded;
}

function normalizeAvatarUrl(string $url): string
{
    $trimmed = trim($url);
    if (str_starts_with($trimmed, './assets/')) {
        return '../assets/' . substr($trimmed, strlen('./assets/'));
    }
    return $trimmed;
}

function normalizeFormatLabel(string $format): string
{
    $trimmed = trim($format);
    return match ($trimmed) {
        'Match' => 'Singles',
        '2-Man Scramble' => 'Two Man Scramble',
        'Mod. Alt. Shot' => 'Alternate Shot',
        default => $trimmed,
    };
}

function playerListFromRow(array $row): array
{
    $players = [];
    foreach (['player1', 'player2', 'player3', 'player4'] as $column) {
        $value = trim((string) ($row[$column] ?? ''));
        if ($value !== '') {
            $players[] = $value;
        }
    }
    return $players;
}

$rankingsSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        ranking_year AS year,
        player_name AS player,
        team_2025,
        season_team,
        yearly_rank,
        yearly_power_score,
        yearly_net_handicap_rank,
        yearly_net_handicap_score,
        yearly_score_performance_raw,
        yearly_score_performance_adj,
        yearly_score_index,
        yearly_win_pct_weighted,
        yearly_win_pct_overall,
        yearly_win_pct_singles,
        yearly_rounds_played,
        yearly_matches_played,
        yearly_singles_matches,
        yearly_weighted_match_units,
        cumulative_rank,
        cumulative_power_score,
        cumulative_net_handicap_rank,
        cumulative_net_handicap_score,
        cumulative_score_performance_raw,
        cumulative_score_performance_adj,
        cumulative_score_index,
        cumulative_win_pct_weighted,
        cumulative_win_pct_overall,
        cumulative_win_pct_singles,
        cumulative_rounds_played,
        cumulative_matches_played,
        cumulative_singles_matches,
        cumulative_weighted_match_units,
        cumulative_years_scored,
        handicap_index,
        handicap_imputed,
        yearly_trend,
        yearly_net_handicap_trend,
        cumulative_trend,
        cumulative_net_handicap_trend,
        line_color,
        avatar_url
    FROM bcc_power_rankings
    ORDER BY ranking_year, yearly_rank, player_name
) AS row_data;
SQL;

$playersSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        player_name AS player,
        MIN(ranking_year) AS first_year,
        MAX(ranking_year) AS latest_year,
        MIN(team_2025) AS team_2025,
        MIN(avatar_url) AS avatar_url,
        ARRAY_AGG(ranking_year ORDER BY ranking_year) AS years_active
    FROM bcc_power_rankings
    GROUP BY player_name
    ORDER BY MIN(CASE WHEN ranking_year = 2025 THEN yearly_rank ELSE 999 END), player_name
) AS row_data;
SQL;

$yearsSql = <<<'SQL'
SELECT COALESCE(json_agg(year_value), '[]'::json)::text
FROM (
    SELECT DISTINCT ranking_year AS year_value
    FROM bcc_power_rankings
    ORDER BY year_value
) AS years;
SQL;

$generatedSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT MAX(updated_at) AS generated_at
    FROM bcc_power_rankings
) AS row_data;
SQL;

$matchResultsSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        year,
        round,
        match,
        team,
        format,
        player1,
        player2,
        player3,
        player4,
        win_or_loss,
        points,
        score
    FROM bcc_match_results
    WHERE year BETWEEN 2017 AND 2025
    ORDER BY year, round, match, team
) AS row_data;
SQL;

try {
    $rankings = runPsqlJson($rankingsSql);
    $players = runPsqlJson($playersSql);
    $years = runPsqlJson($yearsSql);
    $generated = runPsqlJson($generatedSql);
    $matchResults = runPsqlJson($matchResultsSql);

    foreach ($rankings as &$rankingRow) {
        $rankingRow['avatar_url'] = normalizeAvatarUrl((string) ($rankingRow['avatar_url'] ?? ''));
    }
    unset($rankingRow);

    $series = [];
    $rankingsByPlayer = [];
    $cohortLookup = [];
    foreach ($rankings as $row) {
        $player = (string) ($row['player'] ?? '');
        if ($player === '') {
            continue;
        }
        $cohortLookup[$player] = true;
        if (!isset($rankingsByPlayer[$player])) {
            $rankingsByPlayer[$player] = [];
        }
        $rankingsByPlayer[$player][] = $row;
    }

    $matchRowsByKey = [];
    foreach ($matchResults as $row) {
        $year = (int) ($row['year'] ?? 0);
        $round = (int) ($row['round'] ?? 0);
        $match = (int) ($row['match'] ?? 0);
        $team = trim((string) ($row['team'] ?? ''));
        if ($year <= 0 || $round <= 0 || $match <= 0 || $team === '') {
            continue;
        }
        $playersOnRow = playerListFromRow($row);
        $row['players'] = $playersOnRow;
        $matchRowsByKey["{$year}-{$round}-{$match}-{$team}"] = $row;
    }

    $playerResultsMap = [];
    foreach ($matchRowsByKey as $key => $row) {
        $team = trim((string) ($row['team'] ?? ''));
        $opponentTeam = strcasecmp($team, 'Red') === 0 ? 'Blue' : 'Red';
        $year = (int) ($row['year'] ?? 0);
        $round = (int) ($row['round'] ?? 0);
        $match = (int) ($row['match'] ?? 0);
        $playersOnRow = array_values(array_filter(
            playerListFromRow($row),
            static fn(string $value): bool => isset($cohortLookup[$value])
        ));

        if (!$playersOnRow) {
            continue;
        }

        $opponentRow = $matchRowsByKey["{$year}-{$round}-{$match}-{$opponentTeam}"] ?? null;
        $opponents = $opponentRow ? playerListFromRow($opponentRow) : [];
        $format = normalizeFormatLabel((string) ($row['format'] ?? ''));
        $result = trim((string) ($row['win_or_loss'] ?? ''));
        $score = trim((string) ($row['score'] ?? ''));
        $points = isset($row['points']) ? (float) $row['points'] : 0.0;

        foreach ($playersOnRow as $player) {
            $teammates = array_values(array_filter(
                $playersOnRow,
                static fn(string $candidate): bool => $candidate !== $player
            ));
            $playerResultsMap[$player][] = [
                'year' => $year,
                'round' => $round,
                'match' => $match,
                'team' => $team,
                'format' => $format,
                'teammates' => $teammates,
                'opponents' => $opponents,
                'result' => $result,
                'points' => $points,
                'score' => $score,
            ];
        }
    }

    foreach ($players as $playerRow) {
        $player = (string) ($playerRow['player'] ?? '');
        $playerRow['avatar_url'] = normalizeAvatarUrl((string) ($playerRow['avatar_url'] ?? ''));
        $playerRows = $rankingsByPlayer[$player] ?? [];
        $latest = null;
        foreach ($playerRows as $candidate) {
            if ((int) ($candidate['year'] ?? 0) === 2025) {
                $latest = $candidate;
                break;
            }
        }
        $series[] = [
            'player' => $player,
            'team' => (string) ($playerRow['team_2025'] ?? ''),
            'avatarUrl' => (string) ($playerRow['avatar_url'] ?? ''),
            'firstYear' => (int) ($playerRow['first_year'] ?? 0),
            'latestYear' => (int) ($playerRow['latest_year'] ?? 0),
            'lineColor' => (string) (($latest['line_color'] ?? $playerRows[0]['line_color'] ?? '#5f6e8d')),
            'latestYearlyRank' => $latest ? (int) $latest['yearly_rank'] : null,
            'latestYearlyScore' => $latest ? (float) $latest['yearly_power_score'] : null,
            'latestYearlyNetHandicapRank' => $latest ? (int) $latest['yearly_net_handicap_rank'] : null,
            'latestYearlyNetHandicapScore' => $latest ? (float) $latest['yearly_net_handicap_score'] : null,
            'latestCumulativeRank' => $latest ? (int) $latest['cumulative_rank'] : null,
            'latestCumulativeScore' => $latest ? (float) $latest['cumulative_power_score'] : null,
            'latestCumulativeNetHandicapRank' => $latest ? (int) $latest['cumulative_net_handicap_rank'] : null,
            'latestCumulativeNetHandicapScore' => $latest ? (float) $latest['cumulative_net_handicap_score'] : null,
            'yearlyTrend' => $latest && $latest['yearly_trend'] !== null ? (int) $latest['yearly_trend'] : null,
            'yearlyNetHandicapTrend' => $latest && $latest['yearly_net_handicap_trend'] !== null ? (int) $latest['yearly_net_handicap_trend'] : null,
            'cumulativeTrend' => $latest && $latest['cumulative_trend'] !== null ? (int) $latest['cumulative_trend'] : null,
            'cumulativeNetHandicapTrend' => $latest && $latest['cumulative_net_handicap_trend'] !== null ? (int) $latest['cumulative_net_handicap_trend'] : null,
            'points' => array_map(static function (array $row): array {
                return [
                    'x' => (int) $row['year'],
                    'yearlyRank' => isset($row['yearly_rank']) ? (int) $row['yearly_rank'] : null,
                    'cumulativeRank' => isset($row['cumulative_rank']) ? (int) $row['cumulative_rank'] : null,
                    'yearlyScore' => isset($row['yearly_power_score']) ? (float) $row['yearly_power_score'] : null,
                    'cumulativeScore' => isset($row['cumulative_power_score']) ? (float) $row['cumulative_power_score'] : null,
                    'yearlyNetHandicapRank' => isset($row['yearly_net_handicap_rank']) ? (int) $row['yearly_net_handicap_rank'] : null,
                    'cumulativeNetHandicapRank' => isset($row['cumulative_net_handicap_rank']) ? (int) $row['cumulative_net_handicap_rank'] : null,
                    'yearlyNetHandicapScore' => isset($row['yearly_net_handicap_score']) ? (float) $row['yearly_net_handicap_score'] : null,
                    'cumulativeNetHandicapScore' => isset($row['cumulative_net_handicap_score']) ? (float) $row['cumulative_net_handicap_score'] : null,
                    'yearlyScorePerformance' => isset($row['yearly_score_performance_adj']) ? (float) $row['yearly_score_performance_adj'] : 0.0,
                    'cumulativeScorePerformance' => isset($row['cumulative_score_performance_adj']) ? (float) $row['cumulative_score_performance_adj'] : 0.0,
                    'yearlyWeightedWinPct' => isset($row['yearly_win_pct_weighted']) ? (float) $row['yearly_win_pct_weighted'] : 0.5,
                    'cumulativeWeightedWinPct' => isset($row['cumulative_win_pct_weighted']) ? (float) $row['cumulative_win_pct_weighted'] : 0.5,
                    'yearlyOverallWinPct' => isset($row['yearly_win_pct_overall']) ? (float) $row['yearly_win_pct_overall'] : 0.5,
                    'cumulativeOverallWinPct' => isset($row['cumulative_win_pct_overall']) ? (float) $row['cumulative_win_pct_overall'] : 0.5,
                    'yearlySinglesWinPct' => isset($row['yearly_win_pct_singles']) ? (float) $row['yearly_win_pct_singles'] : 0.5,
                    'cumulativeSinglesWinPct' => isset($row['cumulative_win_pct_singles']) ? (float) $row['cumulative_win_pct_singles'] : 0.5,
                ];
            }, $playerRows),
        ];
    }

    echo json_encode([
        'success' => true,
        'generatedAt' => $generated[0]['generated_at'] ?? null,
        'cohortYear' => 2025,
        'cohortSize' => count($players),
        'years' => array_map(static fn($year): int => (int) $year, $years),
        'players' => $players,
        'rankings' => $rankings,
        'series' => $series,
        'playerResults' => $playerResultsMap,
        'model' => [
            'name' => 'BCC Power Ratings and Net of Handicap',
            'summary' => 'Year-by-Year view uses only that season. Cumulative view uses a rolling five-season window through that season, with the newest seasons weighted most heavily. Power Ratings are 75% score-versus-handicap and 25% win rate. Net of Handicap uses only score versus handicap.',
            'components' => [
                '75% score performance versus handicap expectation',
                '25% weighted win percentage',
                'Net of Handicap is the score-versus-expectation side on its own',
                'Cumulative score performance averages each season’s score-over-expected mark instead of pooling every round together',
                'Cumulative mode only uses the last five seasons and progressively weights the newest seasons more heavily',
                'cumulative_win_pct_overall matches the main BCC site’s win formula: wins plus half ties divided by matches',
                'Singles matches count double inside the weighted win bucket',
                'Singles, Best Ball, and Shamble carry more score-performance weight because they use individual scores',
                'Alternate Shot and Two Man Scramble carry less score-performance weight because they use shared team scores',
                'Small samples shrink toward neutral',
            ],
        ],
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    fail($e->getMessage(), 500);
}
