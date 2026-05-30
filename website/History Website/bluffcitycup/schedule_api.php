<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

function fail(string $message, int $status = 500): void
{
    http_response_code($status);
    echo json_encode([
        'success' => false,
        'error' => $message,
        'rowCount' => 0,
        'events' => [],
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

function decodeTournamentName(string $name): string
{
    return str_replace(['!spa', '!amp'], [' ', '&'], trim($name));
}

$tournament = decodeTournamentName((string)($_GET['tournament'] ?? ''));
if ($tournament === '') {
    fail('Missing tournament parameter.', 400);
}

$dbconn = pg_connect('host=localhost dbname=bluffcitycup user=bcc_admin password=memphis');
if (!$dbconn || pg_last_error($dbconn)) {
    fail('Failed to connect to PSQL: ' . pg_last_error($dbconn), 500);
}

$sql = <<<'SQL'
SELECT
    id,
    COALESCE(BTRIM(tournament), '') AS tournament,
    COALESCE(event_type, '') AS event_type,
    COALESCE(event_date::text, '') AS event_date,
    COALESCE(to_char(start_time, 'HH24:MI'), '') AS start_time,
    COALESCE(to_char(end_time, 'HH24:MI'), '') AS end_time,
    COALESCE(title, '') AS title,
    COALESCE(location_name, '') AS location_name,
    COALESCE(location_address, '') AS location_address,
    COALESCE(location_url, '') AS location_url,
    COALESCE(course_name, '') AS course_name,
    COALESCE(scoring_format, '') AS scoring_format,
    COALESCE(points_per_match::text, '') AS points_per_match,
    COALESCE(note, '') AS note,
    COALESCE(sort_order::text, '0') AS sort_order
FROM tournament_schedule_events
WHERE BTRIM(tournament) = BTRIM($1)
ORDER BY event_date, start_time NULLS LAST, id
SQL;

$result = pg_query_params($dbconn, $sql, [$tournament]);
if (!$result) {
    $error = pg_last_error($dbconn);
    pg_close($dbconn);
    fail($error !== '' ? $error : 'Schedule query failed.', 500);
}

$events = [];
while ($row = pg_fetch_array($result, null, PGSQL_ASSOC)) {
    $events[] = $row;
}

pg_close($dbconn);

echo json_encode([
    'success' => true,
    'tournament' => $tournament,
    'rowCount' => count($events),
    'events' => $events,
], JSON_UNESCAPED_UNICODE);
