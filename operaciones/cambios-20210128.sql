set search_path = cvp;

DROP SEQUENCE IF EXISTS secuencia_requerimientos CASCADE;

CREATE SEQUENCE secuencia_requerimientos;

ALTER SEQUENCE secuencia_requerimientos
    OWNER TO cvpowner;

GRANT SELECT, USAGE ON SEQUENCE secuencia_requerimientos TO cvp_administrador;

DROP TABLE IF EXISTS requerimientos;
CREATE TABLE requerimientos
(
    id_requerimiento integer NOT NULL DEFAULT nextval('cvp.secuencia_requerimientos'),
	fecha_requerimiento date NOT NULL DEFAULT CURRENT_DATE, 
    PRIMARY KEY (id_requerimiento)
);

ALTER TABLE requerimientos
    OWNER to cvpowner;

GRANT INSERT, SELECT ON TABLE requerimientos TO cvp_administrador;
