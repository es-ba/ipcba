set search_path = cvp;
drop table if exists fechas;
drop table if exists licencias;

CREATE TABLE fechas(
fecha DATE,
hay_campo cvp.sino_dom,
visible_planificacion cvp.sino_dom,
seleccionada_planificacion cvp.sino_dom,
PRIMARY KEY (fecha));

ALTER TABLE fechas OWNER to cvpowner;
GRANT INSERT, SELECT, UPDATE ON TABLE fechas TO cvp_administrador;
GRANT SELECT ON TABLE fechas TO cvp_usuarios;
GRANT ALL ON TABLE fechas TO cvpowner;
--historico de fechas

CREATE TABLE licencias(
persona character varying(10),
fechadesde DATE,
fechahasta DATE,
motivo text,
PRIMARY KEY (persona,fechadesde,fechahasta),
FOREIGN KEY (persona) REFERENCES personal (persona));

ALTER TABLE licencias OWNER to cvpowner;
GRANT INSERT, SELECT, UPDATE ON TABLE licencias TO cvp_administrador;
GRANT SELECT ON TABLE licencias TO cvp_usuarios;
GRANT ALL ON TABLE licencias TO cvpowner;
--historico de licencias
--constraint fechasdesde <= fechahasta
