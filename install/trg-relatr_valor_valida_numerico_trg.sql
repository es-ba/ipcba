CREATE OR REPLACE FUNCTION relatr_valor_valida_numerico_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vescantidad cvp.atributos.escantidad%type;
  vnormalizable cvp.prodatr.normalizable%type;
  vTipoDato cvp.atributos.TipoDato%type;
  vHacerElControl BOOLEAN = FALSE;
BEGIN
  
  IF TG_OP='INSERT'  THEN
    vHacerElControl = NEW.valor IS NOT NULL;
  ELSE
    vHacerElControl = NEW.valor IS NOT NULL AND OLD.valor IS DISTINCT FROM NEW.valor;
  END IF;    
  IF vhacerElControl THEN       
    SELECT a.esCantidad, p.Normalizable, a.TipoDato INTO vescantidad, vnormalizable, vTipoDato
      FROM cvp.prodatr p JOIN cvp.atributos a ON a.atributo= p.atributo 
      WHERE p.producto= NEW.producto AND p.atributo= NEW.atributo;
    IF (vesCantidad='S' OR vNormalizable='S' AND vTipoDato='N') AND NOT comun.es_numero(NEW.valor) THEN
      raise exception 'El valor ingresado "%" para el atributo no es un número (o tiene una coma en vez de punto) [prod:%, atributo:%, inf:%, periodo:%]', 
                       new.valor, new.producto, new.atributo, new.informante, new.periodo;
      RETURN NULL;
    END IF; 
  END IF;  
  RETURN NEW;  
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER relatr_esnumerico_valor_trg
  BEFORE INSERT OR UPDATE
  ON relatr
  FOR EACH ROW
  EXECUTE PROCEDURE relatr_valor_valida_numerico_trg();
