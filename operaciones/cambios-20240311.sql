set search_path = cvp;

CREATE OR REPLACE FUNCTION informantes_validacion_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
  IF new.tipoinformante = 'S' AND new.cadena is null THEN
    RAISE EXCEPTION 'Tipo informante S, debe completar cadena';
    RETURN NULL;
  END IF;
  RETURN NEW;
END;
$BODY$;

ALTER FUNCTION informantes_validacion_trg()
    OWNER TO cvpowner;

CREATE TRIGGER informantes_valida_trg
    BEFORE INSERT OR UPDATE 
    ON informantes
    FOR EACH ROW
    EXECUTE FUNCTION informantes_validacion_trg();