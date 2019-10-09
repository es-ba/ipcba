CREATE FUNCTION relpre_validacion_trg() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  vespositivo cvp.tipopre.espositivo%type;
  vactivo cvp.tipopre.activo%type;
BEGIN
  IF new.tipoprecio IS NULL AND new.precio IS NOT NULL THEN
    RAISE EXCEPTION 'TipoPrecio sin dato';
    RETURN NULL;
  ELSIF new.tipoprecio IS NOT NULL THEN
    SELECT espositivo, activo INTO vespositivo, vactivo
      FROM cvp.tipopre
      WHERE tipoprecio=new.tipoprecio;
    IF vactivo = 'N' THEN
      RAISE EXCEPTION 'Tipo de precio inválido';
      RETURN NULL;
    END IF;
    IF vespositivo='S' AND new.precio IS NULL  THEN
      RAISE EXCEPTION 'TipoPrecio indica que debe ingresar precio>0';
      RETURN NULL;
    ELSIF vespositivo='N' AND new.precio IS NOT NULL THEN 
      RAISE EXCEPTION 'TipoPrecio indica que precio debe quedar sin valor';
      RETURN NULL;
    END IF; 
    IF vespositivo='N' AND new.cambio='C' THEN
      RAISE EXCEPTION 'No puede haber C en Cambio cuando Tipoprecio no es positivo';
      RETURN NULL;
    END IF;    
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER relpre_valida_trg 
  BEFORE INSERT OR UPDATE 
  ON relpre 
  FOR EACH ROW EXECUTE PROCEDURE relpre_validacion_trg();
