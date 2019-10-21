set role to postgres;
DROP ROLE IF EXISTS cvp_coordinacion;
DROP ROLE IF EXISTS cvp_administrador;
DROP ROLE IF EXISTS cvp_analistas;
DROP ROLE IF EXISTS cvp_personal;;
DROP ROLE IF EXISTS cvp_recepcionista;
DROP ROLE IF EXISTS cvp_usuarios;

CREATE ROLE cvp_usuarios;
CREATE ROLE cvp_recepcionista;
CREATE ROLE cvp_personal;
CREATE ROLE cvp_analistas;
CREATE ROLE cvp_administrador;
CREATE ROLE cvp_coordinacion;

GRANT cvp_usuarios TO cvp_analistas;
GRANT cvp_analistas TO cvp_administrador;
GRANT cvp_administrador TO cvp_coordinacion;
set role to cvpowner;