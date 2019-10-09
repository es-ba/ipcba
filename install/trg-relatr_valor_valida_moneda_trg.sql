CREATE OR REPLACE FUNCTION relatr_valor_valida_moneda_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vEsMoneda INTEGER = 0;
  vEsValido INTEGER = 0;
  vHacerElControl BOOLEAN = FALSE;
BEGIN
  SELECT 1 INTO vEsMoneda
    FROM cvp.prodatr
    WHERE producto = NEW.producto AND atributo = NEW.atributo AND tiponormalizacion = 'Moneda';
  IF TG_OP='INSERT'  THEN
    vHacerElControl = NEW.valor IS NOT NULL AND vEsMoneda = 1;
  ELSE
    vHacerElControl = NEW.valor IS NOT NULL AND OLD.valor IS DISTINCT FROM NEW.valor AND vEsMoneda = 1;
  END IF;    
  IF vhacerElControl THEN       
    SELECT 1 INTO vEsValido
      FROM cvp.monedas 
      WHERE moneda= NEW.valor;
    IF vEsValido is distinct from 1 THEN
      raise exception 'El valor ingresado "%" para el atributo no es una moneda [prod:%, atributo:%, inf:%, periodo:%]', 
                       new.valor, new.producto, new.atributo, new.informante, new.periodo;
      RETURN NULL;
    END IF; 
  END IF;  
  RETURN NEW;  
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER relatr_esmoneda_valor_trg
  BEFORE INSERT OR UPDATE
  ON relatr
  FOR EACH ROW
  EXECUTE PROCEDURE relatr_valor_valida_moneda_trg();