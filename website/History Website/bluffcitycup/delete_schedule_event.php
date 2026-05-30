<?php
declare(strict_types=1);

header('Content-Type: text/plain; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

function decode_param(string $value): string
{
    return str_replace(['!spa', '!amp'], [' ', '&'], trim($value));
}

$dbconn = pg_connect('host=localhost dbname=bluffcitycup user=bcc_admin password=memphis');
if (!$dbconn || pg_last_error($dbconn)) {
    echo 'ERROR';
    exit;
}

$id = trim((string)($_GET['id'] ?? ''));
$tournament = decode_param((string)($_GET['tournament'] ?? ''));

if ($id === '' || $tournament === '') {
    pg_close($dbconn);
    echo 'ERROR';
    exit;
}

$result = pg_query_params(
    $dbconn,
    'DELETE FROM tournament_schedule_events WHERE id = $1 AND BTRIM(tournament) = BTRIM($2)',
    [(int)$id, $tournament]
);

if (!$result) {
    pg_close($dbconn);
    echo 'ERROR';
    exit;
}

pg_close($dbconn);
echo 'OK';
