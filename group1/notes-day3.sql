-- Formation PostgreSQL : day 3

-- Diaporama : https://docs.google.com/presentation/d/16o_-SsgPdhFduvGw1KY7nhpFyCgGXgThtTRirsycPd8/edit?usp=sharing
-- Code : https://github.com/matthcol/postgresql202009

-- Outil de restauration : pg_restore
-- lister le contenu de l'archive
pg_restore -l dbmovie.custom 
-- restaurer une table
pg_restore -U postgres -d dbmovie -n movie -t play dbmovie.custom
-- restaurer le contenu d'une table
pg_restore -U postgres -d dbmovie -n movie -t play -a dbmovie.custom
-- restaurer toute la base en nettoyant l'existant
pg_restore -U postgres -d dbmovie -c dbmovie.custom

-- PITR
-- 1. backup (Ex: daily):
pg_basebackup -U postgres -F plain -D c:\d\backup\2020-09-24
pg_basebackup -U postgres -F tar -z -D c:\d\backup\2020-09-24
-- 2. archive logs (continuous): settings cf postgresql.conf
-- 3. restore/recover : 9 points proceding : cf par recover from the documentation
--			https://www.postgresql.org/docs/11/continuous-archiving.html
--          cf file recover.conf(.done) : a sample is present in directory share from PG install directory

-- Index + tablespace

-- supervision disk usage : pg_xxxx_size functions
select pg_database_size('dbmovie')/1024/1024 as size_mo;
-- vacuum
select relfilenode, relname from pg_class where relname in ('movies', 'stars', 'play');
vacuum movie.movies;
vacuum analyze movie.movies; --actualize stats while vacuum / done by autovacuum 
vacuum full movie.movies;
-- vacuum full : copy physique vers de nouveau fichiers
vacuum full analyze movie.movies;
-- all database (postgres or dba user)
vacuum full;

-- indexes :
-- coût d'un traitement (requete ici)
-- O(1):  idéal mais impossible en database (variable, array)
-- O(log(n)) : btree + unique
--	1K => 10
--	1M => 20
--	1G => 30
--	1T => 40
-- 0(n) : balayage d'une table
-- jointure : multiplier les coûts
-- inconvénient index : stockage, updates
--
-- store index on different tablespace (as postgres)
create tablespace tb_indexes location 'C:/D/Postgresql/11/tb_indexes';
grant all privileges on tablespace tb_indexes to movie;
-- request with indexes (use explain plan)
select * from movies where id = 74512;
select * from movies where year < 1920;
select * from movies where year between 1970 and 1979;
select * from stars where name like 'John%';
select * from stars where name ~ '^John';
select * from stars where name = 'John Wayne';
-- index is not used
select * from movies where duration is not null;
-- add indexes (and replay requests)
create index idx_movies_title on movies(title); -- BTree
create index idx_movies_title on movies(lower(title));
create index idx_movies_title on movies(lower(title)) tablespace tb_indexes;
drop index idx_movies_title;
select * from movies where title like 'Star%';
select * from movies where title ~ '^Star';
select * from movies where lower(title) = 'pulp fiction';
-- usage disk on indexes
select pg_indexes_size('movie.movies');
-- supervision of index files 
select relname, indisunique, indisvalid, c.relfilenode from pg_class c join pg_index i on c.oid = i.indexrelid;
select * from pg_indexes where schemaname = 'movie';
select * from pg_class where relname = 'idx_movies_title';
-- reindex :
reindex index idx_movies_title;
--
-- conctruction with several jobs in // (attention aux index uniques)
-- drop + create concurrently
create index concurrently idx_movies_title on movies(lower(title)) tablespace tb_indexes;


-- supervision sessions
-- locks on table movies :
select pid, locktype, mode, granted from pg_locks where relation in (select oid from pg_class where relname = 'movies');
-- sessions with user movie :
select * from pg_stat_activity where usename = 'movie';
-- end user sessions with their pids (with locks on table movies)
select pg_terminate_backend(pid) 
from pg_locks where relation in (select oid from pg_class where relname = 'movies');
-- suspend user while in maintenance mode : modify pg_hba.conf or revoke/grant privileges
revoke connect on database dbmovie from movie; -- did not work ?
grant connect on database dbmovie to movie;  -- go back to normal
-- or --
alter user movie nologin; 
alter user movie login; -- go back to normal
-- suspend already connected users
select pg_terminate_backend(pid) 
from pg_stat_activity where usename = 'movie';

-- some priviliges specific to PG
-- access to schema
grant usage on schema movie to guest;
-- all objects (tables, ....) in schema
-- for tables, views are included
grant select on all tables in schema movie to guest;


