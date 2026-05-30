<?php
declare(strict_types=1);

header('Content-Type: text/plain; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

function decode_param(string $value): string
{
    return str_replace(['!spa', '!amp'], [' ', '&'], trim($value));
}

function nullable_time(string $value)
{
    $trimmed = trim($value);
    return $trimmed === '' ? null : $trimmed;
}

function nullable_numeric(string $value)
{
    $trimmed = trim($value);
    return $trimmed === '' ? null : $trimmed;
}

$dbconn = pg_connect('host=localhost dbname=bluffcitycup user=bcc_admin password=memphis');
if (!$dbconn || pg_last_error($dbconn)) {
    echo 'ERROR';
    exit;
}

$tournament = decode_param((string)($_GET['tournament'] ?? ''));
$eventType = strtolower(decode_param((string)($_GET['event_type'] ?? '')));
$eventDate = decode_param((string)($_GET['event_date'] ?? ''));

if ($tournament === '' || $eventDate === '' || !in_array($eventType, ['golf', 'meal', 'misc'], true)) {
    pg_close($dbconn);
    echo 'ERROR';
    exit;
}

$id = trim((string)($_GET['id'] ?? ''));
$params = [
    $tournament,
    $eventType,
    $eventDate,
    nullable_time((string)($_GET['start_time'] ?? '')),
    nullable_time((string)($_GET['end_time'] ?? '')),
    decode_param((string)($_GET['title'] ?? '')),
    decode_param((string)($_GET['location_name'] ?? '')),
    decode_param((string)($_GET['location_address'] ?? '')),
    trim((string)($_GET['location_url'] ?? '')),
    decode_param((string)($_GET['course_name'] ?? '')),
    decode_param((string)($_GET['scoring_format'] ?? '')),
    nullable_numeric((string)($_GET['points_per_match'] ?? '')),
    decode_param((string)($_GET['note'] ?? '')),
    (int)($_GET['sort_order'] ?? 0),
];

if ($id !== '') {
    $sql = <<<'SQL'
UPDATE tournament_schedule_events
SET
    tournament = $1,
    event_type = $2,
    event_date = $3,
    start_time = $4,
    end_time = $5,
    title = $6,
    location_name = $7,
    location_address = $8,
    location_url = $9,
    course_name = $10,
    scoring_format = $11,
    points_per_match = $12,
    note = $13,
    sort_order = $14,
    updated_at = now()
WHERE id = $15
RETURNING id
SQL;
    $params[] = (int)$id;
} else {
    $sql = <<<'SQL'
INSERT INTO tournament_schedule_events (
    tournament,
    event_type,
    event_date,
    start_time,
    end_time,
    title,
    location_name,
    location_address,
    location_url,
    course_name,
    scoring_format,
    points_per_match,
    note,
    sort_order
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14
)
RETURNING id
SQL;
}

$result = pg_query_params($dbconn, $sql, $params);
if (!$result || pg_num_rows($result) === 0) {
    pg_close($dbconn);
    echo 'ERROR';
    exit;
}

pg_close($dbconn);
echo 'OK';
