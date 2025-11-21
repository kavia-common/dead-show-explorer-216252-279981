-- Grateful Dead Show Explorer - PostgreSQL Schema
-- Idempotent schema creation with constraints and helpful indexes

-- Enable extensions if needed (safe to run if already exists)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- USERS
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT email_format_chk CHECK (position('@' in email) > 1)
);

-- SHOWS
CREATE TABLE IF NOT EXISTS shows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    show_date DATE NOT NULL,
    venue TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT,
    country TEXT DEFAULT 'USA',
    source TEXT, -- e.g. soundboard/aud
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT shows_unique_date_venue UNIQUE (show_date, venue)
);

-- TRACKS
CREATE TABLE IF NOT EXISTS tracks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    show_id UUID NOT NULL REFERENCES shows(id) ON DELETE CASCADE,
    track_no INTEGER NOT NULL,
    title TEXT NOT NULL,
    set_name TEXT, -- e.g. "Set 1", "Set 2", "Encore"
    duration_seconds INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT track_positive_no CHECK (track_no > 0)
);

-- Ensure unique track numbers per show
CREATE UNIQUE INDEX IF NOT EXISTS tracks_show_trackno_ux
    ON tracks (show_id, track_no);

-- FAVORITES
CREATE TABLE IF NOT EXISTS favorites (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    show_id UUID NOT NULL REFERENCES shows(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, show_id)
);

-- Helpful btree indexes for filtering and sorting
CREATE INDEX IF NOT EXISTS idx_shows_date ON shows (show_date DESC);
CREATE INDEX IF NOT EXISTS idx_shows_city ON shows (city);
CREATE INDEX IF NOT EXISTS idx_shows_state ON shows (state);
CREATE INDEX IF NOT EXISTS idx_tracks_show_id ON tracks (show_id);

-- Lower(text) functional indexes to support ILIKE efficiently
CREATE INDEX IF NOT EXISTS idx_users_email_lower ON users (LOWER(email));
CREATE INDEX IF NOT EXISTS idx_shows_venue_lower ON shows (LOWER(venue));
CREATE INDEX IF NOT EXISTS idx_shows_city_lower ON shows (LOWER(city));
CREATE INDEX IF NOT EXISTS idx_tracks_title_lower ON tracks (LOWER(title));

-- Update triggers for updated_at columns
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_shows'
  ) THEN
    CREATE TRIGGER set_updated_at_shows
      BEFORE UPDATE ON shows
      FOR EACH ROW
      EXECUTE FUNCTION set_updated_at();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_updated_at_users'
  ) THEN
    CREATE TRIGGER set_updated_at_users
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION set_updated_at();
  END IF;
END$$;
