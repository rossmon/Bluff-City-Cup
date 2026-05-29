<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

const DB_HOST = 'montyratings.com';
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
        'rows' => [],
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

function loadPlayerPictures(): array
{
    $dir = __DIR__ . '/assets/Pics';
    if (!is_dir($dir)) {
        return [];
    }

    $files = scandir($dir);
    if ($files === false) {
        return [];
    }

    $pictures = [];
    foreach ($files as $file) {
        if ($file === '.' || $file === '..' || str_starts_with($file, '.')) {
            continue;
        }

        if (!preg_match('/^(red|blue)_([a-z]+)_([a-z]+)\.(png|jpe?g|webp)$/i', $file, $m)) {
            continue;
        }

        $team = ucfirst(strtolower($m[1]));
        $first = strtolower($m[2]);
        $last = strtolower($m[3]);
        $pictures[] = [
            'file' => $file,
            'team' => $team,
            'first' => $first,
            'last' => $last,
            'key' => $first . '_' . $last,
            'url' => './assets/Pics/' . rawurlencode($file),
        ];
    }

    usort($pictures, static fn(array $a, array $b): int =>
        ($a['team'] <=> $b['team']) ?: (($a['last'] <=> $b['last']) ?: ($a['first'] <=> $b['first']))
    );

    return $pictures;
}

$sql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        id,
        COALESCE(player1, '') AS player1,
        COALESCE(player2, '') AS player2,
        COALESCE(player3, '') AS player3,
        COALESCE(player4, '') AS player4,
        COALESCE(team, '') AS team,
        COALESCE(round::text, '') AS round,
        COALESCE(match::text, '') AS match,
        COALESCE(year::text, '') AS year,
        COALESCE(
            CASE
                WHEN format = 'Match' THEN 'Singles'
                ELSE format
            END,
            ''
        ) AS format,
        COALESCE(win_or_loss, '') AS win_or_loss,
        COALESCE(points::text, '0') AS points,
        COALESCE(score, '') AS score
    FROM bcc_match_results
    ORDER BY year, round, match, team, id
) AS row_data;
SQL;

$yearOutcomesSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        COALESCE(year::text, '') AS year,
        COALESCE(location, '') AS location,
        COALESCE(blue_team_score::text, '') AS blue_team_score,
        COALESCE(red_team_score::text, '') AS red_team_score
    FROM year_outcomes
    ORDER BY year
) AS row_data;
SQL;

$matchCoursesSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        COALESCE(substring(BTRIM(tournament) from '([0-9]{4})$'), '') AS year,
        COALESCE(round::text, '') AS round,
        COALESCE(matchgroup::text, '') AS matchgroup,
        COALESCE(match::text, '') AS match,
        COALESCE(BTRIM(course), '') AS course,
        COALESCE(BTRIM(tees::text), '') AS tees,
        COALESCE(matchlength::text, '') AS matchlength,
        COALESCE(startinghole::text, '') AS startinghole
    FROM (
        SELECT DISTINCT ON (
            substring(BTRIM(tournament) from '([0-9]{4})$'),
            round,
            matchgroup,
            match
        )
            tournament,
            round,
            matchgroup,
            match,
            course,
            tees,
            matchlength,
            startinghole
        FROM matches
        WHERE BTRIM(tournament) LIKE 'Bluff City Cup%'
        ORDER BY
            substring(BTRIM(tournament) from '([0-9]{4})$'),
            round,
            matchgroup,
            match,
            BTRIM(course) DESC
    ) m
    ORDER BY
        substring(BTRIM(tournament) from '([0-9]{4})$'),
        round,
        matchgroup,
        match
) AS row_data;
SQL;

$holesSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        COALESCE(BTRIM(course), '') AS course,
        COALESCE(BTRIM(tees::text), '') AS tees,
        COALESCE(holenumber::text, '') AS holenumber,
        COALESCE(handicap::text, '') AS handicap,
        COALESCE(par::text, '') AS par,
        COALESCE(length::text, '') AS length
    FROM holes
    ORDER BY course, tees, holenumber
) AS row_data;
SQL;

$scoresSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        COALESCE(substring(BTRIM(tournament) from '([0-9]{4})$'), '') AS year,
        COALESCE(BTRIM(tournament), '') AS tournament,
        COALESCE(round::text, '') AS round,
        COALESCE(BTRIM(course), '') AS course,
        COALESCE(hole::text, '') AS hole,
        COALESCE(BTRIM(player), '') AS player,
        COALESCE(actualscore::text, '') AS actualscore
    FROM scores
    WHERE BTRIM(tournament) LIKE 'Bluff City Cup%'
      AND actualscore IS NOT NULL
    ORDER BY
        substring(BTRIM(tournament) from '([0-9]{4})$'),
        round,
        player,
        hole
) AS row_data;
SQL;

$playerHandicapsSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        COALESCE(substring(BTRIM(tournament) from '([0-9]{4})$'), '') AS year,
        COALESCE(BTRIM(tournament), '') AS tournament,
        COALESCE(BTRIM(name), '') AS name,
        COALESCE(BTRIM(team), '') AS team,
        COALESCE(handicap::text, '') AS handicap
    FROM players
    WHERE BTRIM(tournament) LIKE 'Bluff City Cup%'
    ORDER BY
        substring(BTRIM(tournament) from '([0-9]{4})$'),
        BTRIM(team),
        BTRIM(name)
) AS row_data;
SQL;

$coursesMetaSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        COALESCE(BTRIM(name), '') AS course,
        COALESCE(BTRIM(tees), '') AS tees,
        COALESCE(slope::text, '') AS slope,
        COALESCE(rating::text, '') AS rating,
        COALESCE(par::text, '') AS par
    FROM courses
    ORDER BY BTRIM(name), BTRIM(tees)
) AS row_data;
SQL;

$tournamentSettingsSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT DISTINCT ON (substring(BTRIM(tournament) from '([0-9]{4})$'))
        COALESCE(substring(BTRIM(tournament) from '([0-9]{4})$'), '') AS year,
        COALESCE(BTRIM(tournament), '') AS tournament,
        COALESCE(maxhandicap::text, '') AS maxhandicap
    FROM tournaments
    WHERE BTRIM(tournament) LIKE 'Bluff City Cup%'
    ORDER BY
        substring(BTRIM(tournament) from '([0-9]{4})$'),
        BTRIM(tournament)
) AS row_data;
SQL;

$matchSummariesSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        COALESCE(year::text, '') AS year,
        COALESCE(round::text, '') AS round,
        COALESCE(match::text, '') AS match,
        COALESCE(match_uid, '') AS match_uid,
        COALESCE(matchgroup, '') AS matchgroup,
        COALESCE(format, '') AS format,
        COALESCE(summary, '') AS summary,
        COALESCE(word_count::text, '') AS word_count,
        COALESCE(model, '') AS model
    FROM bcc_match_summaries
    ORDER BY year, round, match
) AS row_data;
SQL;

$playerBiosSql = <<<'SQL'
SELECT COALESCE(json_agg(row_data), '[]'::json)::text
FROM (
    SELECT
        COALESCE(player_name, '') AS player_name,
        COALESCE(team, '') AS team,
        COALESCE(first_name, '') AS first_name,
        COALESCE(last_name, '') AS last_name,
        COALESCE(career_matches::text, '') AS career_matches,
        COALESCE(wins::text, '') AS wins,
        COALESCE(losses::text, '') AS losses,
        COALESCE(ties::text, '') AS ties,
        COALESCE(points::text, '') AS points,
        COALESCE(bio, '') AS bio,
        COALESCE(word_count::text, '') AS word_count,
        COALESCE(model, '') AS model
    FROM bcc_player_bios
    ORDER BY team, player_name
) AS row_data;
SQL;

try {
    $rows = runPsqlJson($sql);
    $yearOutcomes = runPsqlJson($yearOutcomesSql);
    $matchCourses = runPsqlJson($matchCoursesSql);
    $holes = runPsqlJson($holesSql);
    $scores = runPsqlJson($scoresSql);
    $playerHandicaps = runPsqlJson($playerHandicapsSql);
    $coursesMeta = runPsqlJson($coursesMetaSql);
    $tournamentSettings = runPsqlJson($tournamentSettingsSql);
    $matchSummaries = runPsqlJson($matchSummariesSql);
    $playerBios = runPsqlJson($playerBiosSql);
    $playerPictures = loadPlayerPictures();

    echo json_encode([
        'success' => true,
        'source' => 'bcc_match_results',
        'rowCount' => count($rows),
        'rows' => $rows,
        'yearOutcomes' => $yearOutcomes,
        'matchCourses' => $matchCourses,
        'holes' => $holes,
        'scores' => $scores,
        'playerHandicaps' => $playerHandicaps,
        'coursesMeta' => $coursesMeta,
        'tournamentSettings' => $tournamentSettings,
        'matchSummaries' => $matchSummaries,
        'playerBios' => $playerBios,
        'playerPictures' => $playerPictures,
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    fail($e->getMessage(), 500);
}
