--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)

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
-- Name: order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status AS ENUM (
    'pending',
    'yet-to-be completed',
    'completed'
);


ALTER TYPE public.order_status OWNER TO postgres;

--
-- Name: set_driver_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_driver_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
BEGIN
NEW.driver_id := 'drv-' || nextval('driver_seq');
RETURN NEW; END;
$$;


ALTER FUNCTION public.set_driver_id() OWNER TO postgres;

--
-- Name: set_order_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_order_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
BEGIN
NEW.order_id := 'ord-' || nextval('order_seq');
RETURN NEW; END;
$$;


ALTER FUNCTION public.set_order_id() OWNER TO postgres;

--
-- Name: set_user_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_user_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
NEW.user_id := 'usr-' || nextval('user_seq');
RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_user_id() OWNER TO postgres;

--
-- Name: driver_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.driver_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.driver_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: drivers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drivers (
    driver_id text NOT NULL,
    driver_name character varying(30) NOT NULL,
    driver_mobile bigint NOT NULL,
    driver_rating numeric(2,1) DEFAULT 0.0,
    earned_tip numeric(10,2) DEFAULT 0.00,
    CONSTRAINT drivers_driver_rating_check CHECK (((driver_rating >= 0.0) AND (driver_rating <= 5.0)))
);


ALTER TABLE public.drivers OWNER TO postgres;

--
-- Name: order_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_seq OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id text NOT NULL,
    order_name character varying(30) NOT NULL,
    order_price numeric(6,2) NOT NULL,
    order_description text
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status (
    user_id text,
    order_id text,
    driver_id text,
    order_status public.order_status
);


ALTER TABLE public.status OWNER TO postgres;

--
-- Name: user_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_seq OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id text NOT NULL,
    user_name character varying(30) NOT NULL,
    user_address jsonb NOT NULL,
    user_mobile bigint NOT NULL,
    user_alt_mobile bigint
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: drivers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drivers (driver_id, driver_name, driver_mobile, driver_rating, earned_tip) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, order_name, order_price, order_description) FROM stdin;
ord-1	Zero to One Book	220.00	book about notes on how to build startup
ord-2	Dumbell	467.00	Pair of Dumbels for home Workout
ord-3	yoga mat	370.00	An un-doubted friend for your yoga sessions
\.


--
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status (user_id, order_id, driver_id, order_status) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, user_name, user_address, user_mobile, user_alt_mobile) FROM stdin;
\.


--
-- Name: driver_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.driver_seq', 1, false);


--
-- Name: order_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_seq', 3, false);


--
-- Name: user_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_seq', 1, false);


--
-- Name: drivers drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (driver_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: drivers before_insert_drivers; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert_drivers BEFORE INSERT ON public.drivers FOR EACH ROW WHEN ((new.driver_id IS NULL)) EXECUTE FUNCTION public.set_driver_id();


--
-- Name: orders before_insert_orders; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert_orders BEFORE INSERT ON public.orders FOR EACH ROW WHEN ((new.order_id IS NULL)) EXECUTE FUNCTION public.set_order_id();


--
-- Name: users before_insert_users; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert_users BEFORE INSERT ON public.users FOR EACH ROW WHEN ((new.user_id IS NULL)) EXECUTE FUNCTION public.set_user_id();


--
-- Name: status status_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(driver_id) ON DELETE CASCADE;


--
-- Name: status status_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: status status_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

