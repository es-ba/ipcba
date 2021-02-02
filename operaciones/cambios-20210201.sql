set search_path = cvp;
CREATE TABLE req_cambiospantar
(
    id_requerimiento integer NOT NULL,
    periodo character varying(11) NOT NULL,
	informante integer NOT NULL,
	panel integer NOT NULL,
    tarea integer NOT NULL,
    panel_nuevo integer NOT NULL,
	tarea_nueva integer NOT NULL,
	PRIMARY KEY (id_requerimiento, periodo, informante, panel, tarea),
    FOREIGN KEY (id_requerimiento) REFERENCES requerimientos (id_requerimiento)
);

ALTER TABLE req_cambiospantar
    OWNER to cvpowner;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE req_cambiospantar TO cvp_administrador;
