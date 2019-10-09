CREATE OR REPLACE FUNCTION prodatr_validamod_valornormal_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  
BEGIN
  IF OLD.valornormal IS DISTINCT FROM NEW.valornormal AND OLD.valornormal IS NOT NULL  THEN
    RAISE EXCEPTION 'No es posible modificar el valor normal';
    RETURN NULL;
  END IF;
  RETURN NEW;   
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER prodatr_valornormal_mod_trg
  BEFORE UPDATE
  ON prodatr
  FOR EACH ROW
  EXECUTE PROCEDURE prodatr_validamod_valornormal_trg();
