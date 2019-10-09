CREATE OR REPLACE FUNCTION permitir_actualizar_valor_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vcambio  cvp.relpre.cambio%type;
  valterable  cvp.prodatr.alterable%type;
  vvalor_1 cvp.relatr.valor%type;
  vvaloresvalidos record;
  vvalido boolean;
  vhayquevalidar boolean;
BEGIN
  IF OLD.valor IS DISTINCT FROM NEW.valor THEN
    SELECT cambio INTO vcambio
      FROM cvp.relpre
      WHERE periodo=NEW.periodo AND informante=NEW.informante AND visita=NEW.visita AND producto=NEW.producto AND
            observacion=NEW.observacion;
    IF vcambio IS DISTINCT FROM 'C' THEN
      RAISE EXCEPTION 'No es posible modificar el valor del atributo cuando el campo cambio es distinto de C';
      RETURN NULL;
    ELSE
      SELECT alterable INTO valterable
        FROM cvp.prodatr
        WHERE producto = NEW.producto AND atributo = NEW.atributo;
      IF valterable = 'N' THEN
        SELECT r_1.valor_1 INTO vvalor_1
          FROM cvp.relatr_1 r_1
          WHERE r_1.periodo=NEW.periodo AND 
                r_1.producto=NEW.producto AND
                r_1.observacion=NEW.observacion AND 
                r_1.informante=NEW.informante AND
                r_1.visita=NEW.visita AND 
                r_1.atributo=NEW.atributo;
         IF vvalor_1 IS NOT NULL THEN
           RAISE EXCEPTION 'Atributo no alterable no se puede modificar';
           RETURN NULL;
         ELSE
           vvalido := false;
           vhayquevalidar := false;
           FOR vvaloresvalidos IN
             SELECT valor 
               FROM cvp.valvalatr 
               WHERE producto = NEW.producto and atributo = NEW.atributo
           LOOP
             vhayquevalidar := true;
             IF vvaloresvalidos.valor = NEW.valor THEN
                vvalido := true;
             END IF;                
           END LOOP;
           IF vhayquevalidar AND NOT vvalido THEN
             RAISE EXCEPTION 'El valor ingresado no es válido para este atributo';
             RETURN NULL;
           END IF;
         END IF;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER relatr_actualizar_valor_trg
  BEFORE UPDATE
  ON relatr
  FOR EACH ROW
  EXECUTE PROCEDURE permitir_actualizar_valor_trg();
