-- Formation PostgreSQL: notes jour 1

-- Diaporama : https://docs.google.com/presentation/d/16o_-SsgPdhFduvGw1KY7nhpFyCgGXgThtTRirsycPd8/edit?usp=sharing
-- Code : https://github.com/matthcol/postgresql202009

-- Encoding de la base de données :
CREATE DATABASE planes
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;
    
--    champs de type textuel va être stocké en UTF-8 (1 à 4 octets) pour de l'UNICODE: ex 東京
--    vs jeux de caractères régionalisés (1 octet = 1 caractère) : ISO-8859-1/latin-1, cp1252
    
-- Client psql: -U user -d database -h machine -p port
  psql -U postgres -d dbmovie
  psql -U postgres -d dbmovie -h localhost -p 5432
  psql -U postgres -d dbmovie -h 192.168.1.105 -p 5432
--  \dt : liste des tables
--  \l : liste des bases
--  \dt tablename : décrire table tablename
  
-- User/Role :
CREATE USER matthias WITH
	LOGIN
	PASSWORD 'password';
  
-- Schemas:
CREATE SCHEMA matthias AUTHORIZATION matthias;
CREATE SCHEMA montagne AUTHORIZATION matthias;

-- modifier search_path pour la session
set search_path = "$user",public,montagne;
show search_path;
-- modifier de manière permanente
alter user matthias set search_path = "$user", public, montagne;
-- accès :
select * from montagne.sommets; -- explicite
select * from sommets; -- transparent en utilisant le search_path
-- 2nd exemple sur dbmovie
select count(*) from movies;
select count(*) from vmovies1970.movies;
select * from vmovies1970.movies;
-- accès aux films des années 70s de manières transparente
set search_path = vmovies1970, movie;
select * from movies;

-- restreindre les droits sur le schéma public dans le role PUBLIC que tout le monde a
REVOKE ALL PRIVILEGES ON SCHEMA public FROM PUBLIC; -- ou autre restriction + fine :
REVOKE create table on schema public FROM PUBLIC; -- retrait creation table uniqt

-- Tables:
-- génération id automatique : smallserial(smallint), serial(int), bigserial(bigint)
-- choisit le type entier correspondant + creation sequence + clause default avec nextval sur la sequence
create table montagne.sommets(id serial PRIMARY KEY, nom varchar(100));
 -- gestion de la séquence avec les fonctions nextval/currval
select nextval('montagne.sommets_id_seq'::regclass);
select currval('montagne.sommets_id_seq'::regclass);
select setval('montagne.sommets_id_seq'::regclass, 10); -- admin

-- Indexes : implicit & explicit
select * from pg_indexes where schemaname like '%movie%' order by indexname;
 
-- code stocké : exemple de fonction
CREATE FUNCTION nb_movies()
    RETURNS integer
    LANGUAGE 'plpgsql'
AS 
$$
declare
	v_nb integer;
begin
	select count(*) into v_nb from movies;
	return v_nb;
end;
$$;

select nb_movies();
 
-- Privileges spécifiques sur les schémas :
grant select on movie.movies to matthias; -- droit objet classique
grant usage on schema movie to matthias; -- droit de traversée
 
