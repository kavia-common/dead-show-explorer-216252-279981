--
-- PostgreSQL database dump
--

\restrict oaCt91OpG8yZI7oZXwvi9D1LfhLGPHxWwO6mhkqeoJkSfRZxJg7q1YMvNqgtwyr

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS myapp;
--
-- Name: myapp; Type: DATABASE; Schema: -; Owner: appuser
--

CREATE DATABASE myapp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE myapp OWNER TO appuser;

\unrestrict oaCt91OpG8yZI7oZXwvi9D1LfhLGPHxWwO6mhkqeoJkSfRZxJg7q1YMvNqgtwyr
\connect myapp
\restrict oaCt91OpG8yZI7oZXwvi9D1LfhLGPHxWwO6mhkqeoJkSfRZxJg7q1YMvNqgtwyr

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: favorites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favorites (
    user_id uuid NOT NULL,
    show_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.favorites OWNER TO postgres;

--
-- Name: shows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shows (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    show_date date NOT NULL,
    venue text NOT NULL,
    city text NOT NULL,
    state text,
    country text DEFAULT 'USA'::text,
    source text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shows OWNER TO postgres;

--
-- Name: tracks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tracks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    show_id uuid NOT NULL,
    track_no integer NOT NULL,
    title text NOT NULL,
    set_name text,
    duration_seconds integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT track_positive_no CHECK ((track_no > 0))
);


ALTER TABLE public.tracks OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email text NOT NULL,
    display_name text NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT email_format_chk CHECK ((POSITION(('@'::text) IN (email)) > 1))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.favorites (user_id, show_id, created_at) FROM stdin;
96a152e0-aa29-41e1-9963-107343bf0b5c	f11b9787-abd7-4800-9bee-26930da6945e	2025-11-22 16:21:19.808975+00
377e6a12-2ad3-4f90-be83-54e772092cf5	f11b9787-abd7-4800-9bee-26930da6945e	2025-11-22 16:21:19.808975+00
96a152e0-aa29-41e1-9963-107343bf0b5c	f618a9a6-cd4b-472c-b011-450c30c92d11	2025-11-22 16:21:19.808975+00
377e6a12-2ad3-4f90-be83-54e772092cf5	f618a9a6-cd4b-472c-b011-450c30c92d11	2025-11-22 16:21:19.808975+00
\.


--
-- Data for Name: shows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shows (id, show_date, venue, city, state, country, source, notes, created_at, updated_at) FROM stdin;
f11b9787-abd7-4800-9bee-26930da6945e	1977-05-08	Barton Hall, Cornell University	Ithaca	NY	USA	SBD	Famous 5/8/77 show	2025-11-22 16:21:19.804379+00	2025-11-22 16:21:19.804379+00
f618a9a6-cd4b-472c-b011-450c30c92d11	1972-05-26	Lyceum Theatre	London	\N	UK	SBD	Europe 72 closer	2025-11-22 16:21:19.804379+00	2025-11-22 16:21:19.804379+00
2b5e1255-8555-4b3d-9aab-b26f2a9377c8	1989-07-07	John F. Kennedy Stadium	Philadelphia	PA	USA	SBD	Built to Last era	2025-11-22 16:21:19.804379+00	2025-11-22 16:21:19.804379+00
\.


--
-- Data for Name: tracks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tracks (id, show_id, track_no, title, set_name, duration_seconds, created_at) FROM stdin;
3b4ffb92-4126-4a24-9123-329cc15dda10	f11b9787-abd7-4800-9bee-26930da6945e	1	New Minglewood Blues	Set 1	325	2025-11-22 16:21:19.806155+00
0cf7584f-42fe-4452-91f9-cb56cd2cec7c	f11b9787-abd7-4800-9bee-26930da6945e	2	Loser	Set 1	365	2025-11-22 16:21:19.806155+00
0c0dba26-143a-4758-a5d4-3797b84c75c6	f11b9787-abd7-4800-9bee-26930da6945e	3	El Paso	Set 1	292	2025-11-22 16:21:19.806155+00
a252ac6f-bba0-4cfd-a28f-5c40a9a5ccfb	f618a9a6-cd4b-472c-b011-450c30c92d11	1	The Promised Land	Set 1	200	2025-11-22 16:21:19.806155+00
6d22cc18-d2c9-4b40-8adf-35cd6b417842	f618a9a6-cd4b-472c-b011-450c30c92d11	2	Sugaree	Set 1	420	2025-11-22 16:21:19.806155+00
8bb4e226-8872-42b0-a272-04edb013828d	f618a9a6-cd4b-472c-b011-450c30c92d11	3	Mr. Charlie	Set 1	190	2025-11-22 16:21:19.806155+00
bb3b3691-01e2-4d4b-940c-b348427203d4	2b5e1255-8555-4b3d-9aab-b26f2a9377c8	1	Hell in a Bucket	Set 1	365	2025-11-22 16:21:19.806155+00
603ed673-599f-463d-ad5d-d2eb256c7236	2b5e1255-8555-4b3d-9aab-b26f2a9377c8	2	Iko Iko	Set 1	430	2025-11-22 16:21:19.806155+00
1d903826-3b87-4ded-96ee-03a08f8f7125	2b5e1255-8555-4b3d-9aab-b26f2a9377c8	3	Little Red Rooster	Set 1	480	2025-11-22 16:21:19.806155+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, display_name, password_hash, created_at, updated_at) FROM stdin;
96a152e0-aa29-41e1-9963-107343bf0b5c	jerry@example.com	Jerry Fan	demo-hash	2025-11-22 16:21:19.801914+00	2025-11-22 16:21:19.801914+00
377e6a12-2ad3-4f90-be83-54e772092cf5	phil@example.com	Phil Fan	demo-hash	2025-11-22 16:21:19.801914+00	2025-11-22 16:21:19.801914+00
\.


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (user_id, show_id);


--
-- Name: shows shows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shows
    ADD CONSTRAINT shows_pkey PRIMARY KEY (id);


--
-- Name: shows shows_unique_date_venue; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shows
    ADD CONSTRAINT shows_unique_date_venue UNIQUE (show_date, venue);


--
-- Name: tracks tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_shows_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shows_city ON public.shows USING btree (city);


--
-- Name: idx_shows_city_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shows_city_lower ON public.shows USING btree (lower(city));


--
-- Name: idx_shows_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shows_date ON public.shows USING btree (show_date DESC);


--
-- Name: idx_shows_state; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shows_state ON public.shows USING btree (state);


--
-- Name: idx_shows_venue_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shows_venue_lower ON public.shows USING btree (lower(venue));


--
-- Name: idx_tracks_show_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tracks_show_id ON public.tracks USING btree (show_id);


--
-- Name: idx_tracks_title_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tracks_title_lower ON public.tracks USING btree (lower(title));


--
-- Name: idx_users_email_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email_lower ON public.users USING btree (lower(email));


--
-- Name: tracks_show_trackno_ux; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX tracks_show_trackno_ux ON public.tracks USING btree (show_id, track_no);


--
-- Name: shows set_updated_at_shows; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at_shows BEFORE UPDATE ON public.shows FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: users set_updated_at_users; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at_users BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: favorites favorites_show_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_show_id_fkey FOREIGN KEY (show_id) REFERENCES public.shows(id) ON DELETE CASCADE;


--
-- Name: favorites favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tracks tracks_show_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracks
    ADD CONSTRAINT tracks_show_id_fkey FOREIGN KEY (show_id) REFERENCES public.shows(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO appuser;


--
-- Name: FUNCTION set_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.set_updated_at() TO appuser;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v1() TO appuser;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v1mc() TO appuser;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v3(namespace uuid, name text) TO appuser;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v4() TO appuser;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_generate_v5(namespace uuid, name text) TO appuser;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_nil() TO appuser;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_dns() TO appuser;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_oid() TO appuser;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_url() TO appuser;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.uuid_ns_x500() TO appuser;


--
-- Name: TABLE favorites; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.favorites TO appuser;


--
-- Name: TABLE shows; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.shows TO appuser;


--
-- Name: TABLE tracks; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tracks TO appuser;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.users TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TYPES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO appuser;


--
-- PostgreSQL database dump complete
--

\unrestrict oaCt91OpG8yZI7oZXwvi9D1LfhLGPHxWwO6mhkqeoJkSfRZxJg7q1YMvNqgtwyr

