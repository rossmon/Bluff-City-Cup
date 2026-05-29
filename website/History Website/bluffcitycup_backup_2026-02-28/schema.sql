--
-- PostgreSQL database dump
--

\restrict bttMFQz7SBYgbFWgP6nkKbAzhHoCGddnsfaIpwCrG5JQD7nTSNgwOWSJW7HN66D

-- Dumped from database version 13.7 (Ubuntu 13.7-0ubuntu0.21.10.1)
-- Dumped by pg_dump version 15.16 (Debian 15.16-0+deb12u1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bcc_match_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bcc_match_results (
    id bigint NOT NULL,
    player1 text NOT NULL,
    player2 text,
    player3 text,
    player4 text,
    team text NOT NULL,
    round integer NOT NULL,
    match integer NOT NULL,
    year integer NOT NULL,
    format text NOT NULL,
    win_or_loss text NOT NULL,
    points numeric(4,1),
    score text NOT NULL,
    CONSTRAINT bcc_match_results_team_check CHECK ((team = ANY (ARRAY['Red'::text, 'Blue'::text]))),
    CONSTRAINT bcc_match_results_win_or_loss_check CHECK ((win_or_loss = ANY (ARRAY['Win'::text, 'Loss'::text, 'Tie'::text])))
);


--
-- Name: bcc_match_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bcc_match_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bcc_match_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bcc_match_results_id_seq OWNED BY public.bcc_match_results.id;


--
-- Name: bcc_match_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bcc_match_summaries (
    year text NOT NULL,
    round text NOT NULL,
    match text NOT NULL,
    match_uid text,
    matchgroup text,
    format text,
    summary text NOT NULL,
    word_count integer,
    model text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bcc_player_bios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bcc_player_bios (
    player_name text NOT NULL,
    team text NOT NULL,
    first_name text,
    last_name text,
    career_matches integer,
    wins integer,
    losses integer,
    ties integer,
    points numeric(10,2),
    bio text NOT NULL,
    word_count integer,
    model text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bluffcitycup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bluffcitycup (
    token character varying(50) NOT NULL,
    username character varying(50) NOT NULL
);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    name character varying(25) NOT NULL,
    tees character varying(15) NOT NULL,
    slope integer,
    rating numeric,
    par numeric
);


--
-- Name: holes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.holes (
    course character(50) NOT NULL,
    holenumber integer NOT NULL,
    handicap integer NOT NULL,
    par integer NOT NULL,
    length integer NOT NULL,
    green_cen_lat double precision NOT NULL,
    green_cen_long double precision NOT NULL,
    tees character varying(15) NOT NULL
);


--
-- Name: matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matches (
    tournament character(50) NOT NULL,
    round integer NOT NULL,
    matchgroup integer NOT NULL,
    match integer NOT NULL,
    course character(50),
    format character(50),
    scorekeeper character(50),
    points numeric(10,2),
    numofplayers integer NOT NULL,
    startinghole integer NOT NULL,
    currenthole integer,
    currentscore integer NOT NULL,
    scorestring character(20),
    winningteam character(50),
    completed integer,
    player1 character(50),
    player1team character(50),
    player2 character(50),
    player2team character(50),
    player3 character(50),
    player3team character(50),
    player4 character(50),
    player4team character(50),
    tees character varying(15),
    matchlength integer
);


--
-- Name: matchprobabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matchprobabilities (
    id integer NOT NULL,
    tournament character varying(255),
    round integer,
    matchgroup integer,
    match integer,
    hole_number integer,
    blue_win_probability double precision,
    red_win_probability double precision,
    tie_probability double precision,
    tees character varying(50),
    score_difference integer
);


--
-- Name: matchprobabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.matchprobabilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matchprobabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.matchprobabilities_id_seq OWNED BY public.matchprobabilities.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    tournament character varying(255) NOT NULL,
    user_identifier character varying(255) NOT NULL,
    content text NOT NULL,
    type character varying(50) NOT NULL,
    parent_id integer,
    media_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: passwords; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passwords (
    password character varying(20) NOT NULL,
    active character varying(1) NOT NULL
);


--
-- Name: players; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.players (
    name character(50) NOT NULL,
    tournament character(50) NOT NULL,
    team character(25) NOT NULL,
    handicap numeric NOT NULL
);


--
-- Name: reactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reactions (
    id integer NOT NULL,
    message_id integer,
    user_identifier character varying(255) NOT NULL,
    reaction character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: reactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reactions_id_seq OWNED BY public.reactions.id;


--
-- Name: rounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rounds (
    tournament character(50) NOT NULL,
    round integer NOT NULL,
    course character(50)
);


--
-- Name: scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scores (
    player character(50) NOT NULL,
    tournament character(50) NOT NULL,
    round integer NOT NULL,
    course character(50) NOT NULL,
    hole integer NOT NULL,
    actualscore integer
);


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tokens (
    token character varying(200) NOT NULL,
    username character varying(50) NOT NULL
);


--
-- Name: tournaments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tournaments (
    tournament character(50) NOT NULL,
    owner character(50) NOT NULL,
    commissioner character(50) NOT NULL,
    matchlength integer NOT NULL,
    numberofmatches integer NOT NULL,
    drinkcartavailable integer NOT NULL,
    drinkcartnumber character(20),
    currentround integer,
    maxhandicap integer,
    commishpassword character varying(20)
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    identifier character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    email character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: year_outcomes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.year_outcomes (
    year integer NOT NULL,
    location character varying(100) NOT NULL,
    blue_team_score numeric(5,2) NOT NULL,
    red_team_score numeric(5,2) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: bcc_match_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcc_match_results ALTER COLUMN id SET DEFAULT nextval('public.bcc_match_results_id_seq'::regclass);


--
-- Name: matchprobabilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchprobabilities ALTER COLUMN id SET DEFAULT nextval('public.matchprobabilities_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: reactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions ALTER COLUMN id SET DEFAULT nextval('public.reactions_id_seq'::regclass);


--
-- Name: bcc_match_results bcc_match_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcc_match_results
    ADD CONSTRAINT bcc_match_results_pkey PRIMARY KEY (id);


--
-- Name: bcc_match_summaries bcc_match_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcc_match_summaries
    ADD CONSTRAINT bcc_match_summaries_pkey PRIMARY KEY (year, round, match);


--
-- Name: bcc_player_bios bcc_player_bios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bcc_player_bios
    ADD CONSTRAINT bcc_player_bios_pkey PRIMARY KEY (player_name);


--
-- Name: bluffcitycup bluffcitycup_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bluffcitycup
    ADD CONSTRAINT bluffcitycup_pkey PRIMARY KEY (token, username);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (name, tees);


--
-- Name: holes holes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holes
    ADD CONSTRAINT holes_pkey PRIMARY KEY (course, tees, holenumber);


--
-- Name: matchprobabilities match_probabilities_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchprobabilities
    ADD CONSTRAINT match_probabilities_unique UNIQUE (tournament, round, matchgroup, match, hole_number, score_difference, tees);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (tournament, round, matchgroup, match);


--
-- Name: matchprobabilities matchprobabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matchprobabilities
    ADD CONSTRAINT matchprobabilities_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: passwords passwords_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passwords
    ADD CONSTRAINT passwords_pkey PRIMARY KEY (password);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (name, tournament, team);


--
-- Name: reactions reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_pkey PRIMARY KEY (id);


--
-- Name: rounds rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rounds
    ADD CONSTRAINT rounds_pkey PRIMARY KEY (tournament, round);


--
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (player, tournament, round, hole);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (token, username);


--
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (tournament, owner, commissioner);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (identifier);


--
-- Name: year_outcomes year_outcomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.year_outcomes
    ADD CONSTRAINT year_outcomes_pkey PRIMARY KEY (year);


--
-- Name: bcc_match_results_uniq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX bcc_match_results_uniq ON public.bcc_match_results USING btree (year, round, match, team, player1, COALESCE(player2, ''::text), COALESCE(player3, ''::text), COALESCE(player4, ''::text), format);


--
-- Name: bcc_match_summaries_match_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX bcc_match_summaries_match_uid_idx ON public.bcc_match_summaries USING btree (match_uid);


--
-- Name: bcc_player_bios_team_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bcc_player_bios_team_idx ON public.bcc_player_bios USING btree (team);


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: messages messages_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.messages(id);


--
-- Name: reactions reactions_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reactions
    ADD CONSTRAINT reactions_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id);


--
-- PostgreSQL database dump complete
--

\unrestrict bttMFQz7SBYgbFWgP6nkKbAzhHoCGddnsfaIpwCrG5JQD7nTSNgwOWSJW7HN66D

