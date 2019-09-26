CREATE DOMAIN cvp.sino_dom
    AS character varying(1);

ALTER DOMAIN cvp.sino_dom OWNER TO cvpowner;

ALTER DOMAIN cvp.sino_dom
    ADD CONSTRAINT "Campo lógico debe poner 'S' o 'N'" CHECK (VALUE in ('S', 'N'));

COMMENT ON DOMAIN cvp.sino_dom
    IS 'Dominio logico {S: Si; N: No}';