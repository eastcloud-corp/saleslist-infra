--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Debian 15.13-1.pgdg120+1)
-- Dumped by pg_dump version 15.13 (Debian 15.13-1.pgdg120+1)

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
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: social_navigator_user
--

INSERT INTO public.clients VALUES (1, 'テストクライアント', '', 'IT・ソフトウェア', '田中 花子', 'hanako@example.com', '03-1234-5678', '', '', '', true, '2025-10-19 13:14:03.268144+00', '2025-10-19 13:14:03.268172+00');


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: social_navigator_user
--

INSERT INTO public.companies VALUES (1, 'テスト株式会社', 'IT・ソフトウェア', 120, 500000000, '東京都', '渋谷区', NULL, 'https://example.com', '', '', '', false, '2025-10-19 13:14:03.273693+00', '2025-10-19 13:14:03.273708+00', '', NULL, '吉田 健一', '代表取締役', '', '', '', NULL, NULL, NULL, '', NULL);


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: social_navigator_user
--

INSERT INTO public.projects VALUES (1, 'サンプル案件', 'サンプル案件の説明', '山田太郎', '', '', '', '', '進行中', '2025-10-19', NULL, '2025-10-19 13:14:03.282576+00', '2025-10-19 13:14:03.282591+00', 1, '', 0, 0, true, '', '', '', '', '', '', false, NULL, NULL, 0, '', '', NULL, 0, NULL, '', NULL, '', NULL, '', false, '', NULL, '', NULL, NULL, '', '', 0, '', '', '', NULL, '');


--
-- Data for Name: project_companies; Type: TABLE DATA; Schema: public; Owner: social_navigator_user
--

INSERT INTO public.project_companies VALUES (1, '未接触', NULL, '', '初期登録', '2025-10-19 13:14:03.289718+00', '2025-10-19 13:14:03.289747+00', 1, 1, 0, '', NULL, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: social_navigator_user
--

INSERT INTO public.users VALUES (1, 'pbkdf2_sha256$1000000$bh11Ey9NWchU6a8XE5NQIx$xNv7UMMy3ysmONSxKAL8aJSfdyAR4P5nK8LniKn21rE=', NULL, false, 'testuser', '', '', false, '2025-10-19 12:57:52.066615+00', 'user@example.com', '山田太郎', 'user', true, '2025-10-19 13:06:54.19357+00', '2025-10-19 12:57:52.066985+00', '2025-10-19 13:14:03.238506+00');


--
-- Name: clients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: social_navigator_user
--

SELECT pg_catalog.setval('public.clients_id_seq', 1, true);


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: social_navigator_user
--

SELECT pg_catalog.setval('public.companies_id_seq', 1, true);


--
-- Name: project_companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: social_navigator_user
--

SELECT pg_catalog.setval('public.project_companies_id_seq', 1, true);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: social_navigator_user
--

SELECT pg_catalog.setval('public.projects_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: social_navigator_user
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- PostgreSQL database dump complete
--

