set search_path = cvp;

CREATE OR REPLACE FUNCTION verificar_borrado_ext_def()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    NOT LEAKPROOF SECURITY DEFINER
AS $BODY$

DECLARE
 vexiste integer;
BEGIN
SELECT 1 INTO vexiste
FROM cvp.productos
WHERE producto = OLD.producto AND tipoexterno = 'D'; 
IF vexiste = 1 THEN
   RAISE EXCEPTION 'No es permitdo borrar externos definitivos.';
   RETURN NULL;
END IF;
RETURN OLD;

END;
$BODY$;

ALTER FUNCTION verificar_borrado_ext_def()
    OWNER TO cvpowner;

CREATE TRIGGER novprod_borrado_trg
    BEFORE DELETE
    ON cvp.novprod
    FOR EACH ROW
    EXECUTE FUNCTION cvp.verificar_borrado_ext_def();
    
