-- Formation PostgreSQL : day 2

-- Diaporama : https://docs.google.com/presentation/d/16o_-SsgPdhFduvGw1KY7nhpFyCgGXgThtTRirsycPd8/edit?usp=sharing
-- Code : https://github.com/matthcol/postgresql202009

-- Cycle de vie du serveur : service ou pg_ctl (attention utilisateur)
pg_ctl reload -D /var/lib/pgsql/11/data/
pg_ctl reload -D "C:\Program Files\PostgreSQL\11\data"

-- Databases:
-- Répertoire base qui contient 1 répertoire par base :
select oid, * from pg_database order by oid; -- oid is directory name
select oid,* from pg_class where relnamespace = (select oid from pg_namespace where nspname = 'movie')
order by reltype;
-- for table/index/sequence : relfilenode is filename (equals oid at first but can change later with vacuum full)

-- Tablespaces
create tablespace tb_planes location 'C:\D\Postgresql\11\data_planes';
create table aero.planes(name varchar(100)) tablespace tb_planes;
insert into aero.planes values ('Airbus A380');
select oid, * from pg_database;
select oid, * from pg_tablespace;
select * from pg_tables where tablespace = 'tb_planes';
-- recreate link on windows (junction)
mklink /J 44671 C:\D\Postgresql\11\data_planes

-- Backup avec pg_dump (-h hostname -p port)
-- format plain par défaut (SQL)
pg_dump -U postgres dbmovie > dbmovie.sql
pg_dump -U postgres -f dbmovie.sql dbmovie
pg_dump -U postgres -d dmovie -f dbmovie.sql
-- autres formats
pg_dump -U postgres -d dbmovie -f dbmovie.dir -F directory
pg_dump -U postgres -d dbmovie -f dbmovie.tar -F tar
pg_dump -U postgres -d dbmovie -f dbmovie.custom -F custom
-- ddl only : -s --schema-only + -c --clean
pg_dump -U postgres -d dbmovie -c -s -f dbmovie_ddl_clean.sql
-- data only : -a --data-only + --disable-triggers
pg_dump -U postgres -d dbmovie --disable-triggers -a -f dbmovie_data.sql
-- grain : schema (ok: -n --schema; nok: -N --exclude-schema) 
--			ou table (ok: -t --table ; nok: -T --exclude-table)
pg_dump -U postgres -d dbmovie -a -n movie -f dbmovie_data_movie.sql
pg_dump -U postgres -d dbmovie -a -t movie.stars -f dbmovie_data_stars.sql
pg_dump -U postgres -d dbmovie -a -n movie -T movie.play -f dbmovie_data_movies_stars.sql
-- pg_dumpall (tranversal) : option -d qui devient -l
-- tt le serveur (utilité moyenne) ?
pg_dumpall -U postgres -l postgres -f serveur.back
pg_dumpall -U postgres -l postgres -g -f serveur-global.sql
pg_dumpall -U postgres -l postgres -r -f users.sql -- (clean after to remove postgres eventually)

-- restore archive in plain format
psql -U postgres -d dbmovie -f dbmovie_users.sql 
psql -U postgres -d dbmovie -f dbmovie.sql
psql -U postgres -d dbmovie -f dbmovie-ddl.sql
psql -U postgres -d dbmovie -f dbmovie-data.sql










