set search_path= ccc,cvp;
set role cvpowner;
drop table if exists empalme_ccc_b1112 cascade;
CREATE TABLE IF NOT EXISTS empalme_ccc_b1112 AS 
select * from empalme_b1112 where false;

ALTER TABLE empalme_ccc_b1112 ADD COLUMN agrupamiento INTEGER;

ALTER TABLE IF EXISTS empalme_ccc_b1112
    ADD CONSTRAINT empalme_ccc_b1112_agrupacion_b1112_grupo_b1112_fkey FOREIGN KEY (agrupacion_b1112, grupo_b1112)
    REFERENCES cvp.grupos_b1112 (agrupacion, grupo);

ALTER TABLE IF EXISTS empalme_ccc_b1112
    ADD CONSTRAINT empalme_ccc_b1112_agrupacion_grupo_fkey FOREIGN KEY (agrupacion, grupo)
    REFERENCES grupos (agrupacion, grupo);

ALTER TABLE IF EXISTS empalme_ccc_b1112
    ADD CONSTRAINT empalme_ccc_b1112_pkey PRIMARY KEY (agrupacion_b1112, grupo_b1112, agrupacion, grupo);

do $SQL_ENANCE$
 begin
 PERFORM enance_table('empalme_ccc_b1112','agrupacion_b1112, grupo_b1112, agrupacion, grupo');
 end
$SQL_ENANCE$;
