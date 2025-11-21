-- Grateful Dead Show Explorer - Seed Data
-- Idempotent inserts using ON CONFLICT and natural keys

-- Users
WITH u AS (
  INSERT INTO users (email, display_name, password_hash)
  VALUES
    ('jerry@example.com', 'Jerry Fan', 'demo-hash'),
    ('phil@example.com', 'Phil Fan', 'demo-hash')
  ON CONFLICT (email) DO UPDATE SET display_name = EXCLUDED.display_name
  RETURNING id, email
)
SELECT * FROM u;

-- Seed shows with deterministic IDs via natural uniqueness (date, venue)
-- First insert shows
WITH s AS (
  INSERT INTO shows (show_date, venue, city, state, country, source, notes)
  VALUES
    ('1977-05-08', 'Barton Hall, Cornell University', 'Ithaca', 'NY', 'USA', 'SBD', 'Famous 5/8/77 show'),
    ('1972-05-26', 'Lyceum Theatre', 'London', NULL, 'UK', 'SBD', 'Europe 72 closer'),
    ('1989-07-07', 'John F. Kennedy Stadium', 'Philadelphia', 'PA', 'USA', 'SBD', 'Built to Last era')
  ON CONFLICT (show_date, venue) DO UPDATE
    SET notes = EXCLUDED.notes
  RETURNING id, show_date, venue
)
SELECT * FROM s;

-- Retrieve show IDs for track insertion
WITH cornell AS (
  SELECT id FROM shows WHERE show_date = '1977-05-08' AND venue = 'Barton Hall, Cornell University'
), lyceum AS (
  SELECT id FROM shows WHERE show_date = '1972-05-26' AND venue = 'Lyceum Theatre'
), jfk AS (
  SELECT id FROM shows WHERE show_date = '1989-07-07' AND venue = 'John F. Kennedy Stadium'
)
-- Insert tracks with upsert on (show_id, track_no)
INSERT INTO tracks (show_id, track_no, title, set_name, duration_seconds)
SELECT id, 1, 'New Minglewood Blues', 'Set 1', 325 FROM cornell
UNION ALL
SELECT id, 2, 'Loser', 'Set 1', 365 FROM cornell
UNION ALL
SELECT id, 3, 'El Paso', 'Set 1', 292 FROM cornell
UNION ALL
SELECT id, 1, 'The Promised Land', 'Set 1', 200 FROM lyceum
UNION ALL
SELECT id, 2, 'Sugaree', 'Set 1', 420 FROM lyceum
UNION ALL
SELECT id, 3, 'Mr. Charlie', 'Set 1', 190 FROM lyceum
UNION ALL
SELECT id, 1, 'Hell in a Bucket', 'Set 1', 365 FROM jfk
UNION ALL
SELECT id, 2, 'Iko Iko', 'Set 1', 430 FROM jfk
UNION ALL
SELECT id, 3, 'Little Red Rooster', 'Set 1', 480 FROM jfk
ON CONFLICT (show_id, track_no) DO UPDATE
  SET title = EXCLUDED.title,
      set_name = EXCLUDED.set_name,
      duration_seconds = EXCLUDED.duration_seconds;

-- Favorites: map users by email to the Cornell and Lyceum shows
WITH u AS (
  SELECT id AS user_id, email FROM users WHERE email IN ('jerry@example.com', 'phil@example.com')
), s AS (
  SELECT id AS show_id, show_date FROM shows WHERE (show_date, venue) IN (
    ('1977-05-08'::date, 'Barton Hall, Cornell University'),
    ('1972-05-26'::date, 'Lyceum Theatre')
  )
)
INSERT INTO favorites (user_id, show_id)
SELECT u.user_id, s.show_id
FROM u CROSS JOIN s
ON CONFLICT (user_id, show_id) DO NOTHING;
