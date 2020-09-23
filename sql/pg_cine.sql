SET CLIENT_ENCODING = 'UTF-8';

DROP schema vmovies1970 cascade;
DROP schema vmovies1980 cascade;
DROP schema vmovies1990 cascade;
DROP schema vmovies2000 cascade;
DROP schema vmovies2010 cascade;
DROP schema vmovies2020 cascade;
DROP SCHEMA movie cascade;
DROP USER if exists movie;

create user movie LOGIN password 'password';

create schema movie authorization movie;
create schema vmovies1970 authorization movie;
create schema vmovies1980 authorization movie;
create schema vmovies1990 authorization movie;
create schema vmovies2000 authorization movie;
create schema vmovies2010 authorization movie;
create schema vmovies2020 authorization movie;

set role movie;

-- DDL : tables, views
\i pg_cine_ddl.sql
-- DATA: psql is in no transaction mode by default
\i cine_data_stars.sql;
\i cine_data_movies.sql;
\i cine_data_play.sql;
-- views
\i pg_cine_views.sql
-- indexes
\i pg_cine_indexes.sql
