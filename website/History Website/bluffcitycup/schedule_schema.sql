CREATE TABLE IF NOT EXISTS public.tournament_schedule_events (
    id bigserial PRIMARY KEY,
    tournament text NOT NULL,
    event_type text NOT NULL CHECK (event_type IN ('golf', 'meal', 'misc')),
    event_date date NOT NULL,
    start_time time without time zone,
    end_time time without time zone,
    title text,
    location_name text,
    location_address text,
    location_url text,
    course_name text,
    scoring_format text,
    points_per_match numeric(10,2),
    note text,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS tournament_schedule_events_tournament_date_idx
    ON public.tournament_schedule_events (btrim(tournament), event_date, start_time, sort_order, id);

CREATE UNIQUE INDEX IF NOT EXISTS tournament_schedule_events_seed_key_idx
    ON public.tournament_schedule_events (tournament, event_type, event_date, COALESCE(start_time, '00:00'::time), COALESCE(title, ''));

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.tournament_schedule_events TO bcc_admin;
GRANT USAGE, SELECT ON SEQUENCE public.tournament_schedule_events_id_seq TO bcc_admin;

INSERT INTO public.tournament_schedule_events (
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
) VALUES
    (
        'Misc',
        'misc',
        '2026-09-24',
        '18:00',
        NULL,
        'Welcome check-in',
        'Tournament house',
        'Memphis, TN',
        'https://maps.apple.com/?q=Memphis%2C%20TN',
        NULL,
        NULL,
        NULL,
        'Pick up pairings, gifts, and weekend details.',
        10
    ),
    (
        'Misc',
        'meal',
        '2026-09-24',
        '19:30',
        NULL,
        'Opening dinner',
        'Central BBQ',
        '147 E Butler Ave, Memphis, TN 38103',
        'https://maps.apple.com/?address=147%20E%20Butler%20Ave,%20Memphis,%20TN%2038103',
        NULL,
        NULL,
        NULL,
        'Casual team dinner after check-in.',
        20
    ),
    (
        'Misc',
        'golf',
        '2026-09-25',
        '08:05',
        '08:45',
        'Morning matches',
        'Galloway Golf Course',
        '3815 Walnut Grove Rd, Memphis, TN 38111',
        'https://maps.apple.com/?address=3815%20Walnut%20Grove%20Rd,%20Memphis,%20TN%2038111',
        'Galloway Golf Course',
        'Best Ball',
        1.00,
        'Opening round tee window.',
        10
    ),
    (
        'Misc',
        'meal',
        '2026-09-25',
        '12:45',
        NULL,
        'Lunch',
        'Clubhouse grill',
        '3815 Walnut Grove Rd, Memphis, TN 38111',
        'https://maps.apple.com/?address=3815%20Walnut%20Grove%20Rd,%20Memphis,%20TN%2038111',
        NULL,
        NULL,
        NULL,
        'Grab lunch between sessions.',
        20
    ),
    (
        'Misc',
        'golf',
        '2026-09-25',
        '14:05',
        '14:45',
        'Afternoon matches',
        'Galloway Golf Course',
        '3815 Walnut Grove Rd, Memphis, TN 38111',
        'https://maps.apple.com/?address=3815%20Walnut%20Grove%20Rd,%20Memphis,%20TN%2038111',
        'Galloway Golf Course',
        '2-Man Scramble',
        1.00,
        'Second session tee window.',
        30
    ),
    (
        'Misc',
        'misc',
        '2026-09-25',
        '20:00',
        NULL,
        'Pairings reveal',
        'Tournament house',
        'Memphis, TN',
        'https://maps.apple.com/?q=Memphis%2C%20TN',
        NULL,
        NULL,
        NULL,
        'Saturday pairings and captain notes.',
        40
    )
ON CONFLICT (tournament, event_type, event_date, (COALESCE(start_time, '00:00'::time)), (COALESCE(title, '')))
DO UPDATE SET
    end_time = EXCLUDED.end_time,
    location_name = EXCLUDED.location_name,
    location_address = EXCLUDED.location_address,
    location_url = EXCLUDED.location_url,
    course_name = EXCLUDED.course_name,
    scoring_format = EXCLUDED.scoring_format,
    points_per_match = EXCLUDED.points_per_match,
    note = EXCLUDED.note,
    sort_order = EXCLUDED.sort_order,
    updated_at = now();
