set search_path= ccc,cvp;
set role cvpowner;
drop table if exists empalme_ccc_b1112 cascade;
CREATE TABLE IF NOT EXISTS empalme_ccc_b1112 AS 
select * from empalme_b1112 where false;

ALTER TABLE empalme_ccc_b1112 ADD COLUMN agrupamiento INTEGER;
ALTER TABLE empalme_ccc_b1112 RENAME COLUMN agrupacion TO agrupacion_b21; 
ALTER TABLE empalme_ccc_b1112 RENAME COLUMN grupo TO grupo_b21; 

ALTER TABLE IF EXISTS empalme_ccc_b1112
    ADD CONSTRAINT empalme_ccc_b1112_agrupacion_b1112_grupo_b1112_fkey FOREIGN KEY (agrupacion_b1112, grupo_b1112)
    REFERENCES cvp.grupos_b1112 (agrupacion, grupo);

ALTER TABLE IF EXISTS empalme_ccc_b1112
    ADD CONSTRAINT empalme_ccc_b1112_agrupacion_b21_grupo_b21_fkey FOREIGN KEY (agrupacion_b21, grupo_b21)
    REFERENCES grupos (agrupacion, grupo);

ALTER TABLE IF EXISTS empalme_ccc_b1112
    ADD CONSTRAINT empalme_ccc_b1112_pkey PRIMARY KEY (agrupacion_b1112, grupo_b1112, agrupacion_b21, grupo_b21);

drop table if exists gruemp cascade;
CREATE TABLE IF NOT EXISTS gruemp AS 
select agrupacion_b1112, grupo_b1112, agrupacion_b21, grupo_b21 from empalme_ccc_b1112 where false;

ALTER TABLE gruemp ADD COLUMN agrupacion text;
ALTER TABLE gruemp ADD COLUMN grupo text;

ALTER TABLE IF EXISTS gruemp
    ADD CONSTRAINT gruemp_empalme_ccc_b1112 FOREIGN KEY (agrupacion_b1112, grupo_b1112, agrupacion_b21, grupo_b21)
    REFERENCES empalme_ccc_b1112 (agrupacion_b1112, grupo_b1112, agrupacion_b21, grupo_b21);

ALTER TABLE IF EXISTS gruemp
    ADD CONSTRAINT gruemp_grupos_ccc FOREIGN KEY (agrupacion, grupo)
    REFERENCES grupos_ccc (agrupacion, grupo);

do $SQL_ENANCE$
 begin
 PERFORM enance_table('empalme_ccc_b1112','agrupacion_b1112, grupo_b1112, agrupacion_b21, grupo_b21');
 PERFORM enance_table('gruemp','agrupacion_b1112, grupo_b1112, agrupacion_b21, grupo_b21, agrupacion, grupo');
 end
$SQL_ENANCE$;
