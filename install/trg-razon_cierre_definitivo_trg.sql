CREATE OR REPLACE FUNCTION razon_cierre_definitivo_trg()
  RETURNS trigger AS
$BODY$

DECLARE
 vexiste integer;
BEGIN
IF OLD.razon IS DISTINCT FROM NEW.razon THEN
    SELECT 1 INTO vexiste
    FROM cvp.razones r, cvp.personal p
    WHERE razon = new.razon and (r.escierredefinitivofor = 'S' and p.username = session_user and p.labor = 'A'
        or r.escierredefinitivofor = 'N'); 
    IF vexiste IS DISTINCT FROM 1 THEN
        RAISE EXCEPTION 'No es permitdo ingresar razón negativa para el formulario.';
        RETURN NULL;
    END IF;
END IF;
RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER relvis_razon_cierre_definitivo_trg
  BEFORE UPDATE
  ON relvis
  FOR EACH ROW
  EXECUTE PROCEDURE razon_cierre_definitivo_trg();