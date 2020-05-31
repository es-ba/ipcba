SET SEARCH_PATH = cvp;

ALTER TABLE tipopre ADD COLUMN puedecambiaratributos BOOLEAN DEFAULT FALSE;
ALTER TABLE tipopre ADD COLUMN inconsistente BOOLEAN DEFAULT FALSE;

UPDATE tipopre SET puedecambiaratributos = true WHERE espositivo ='S';

-----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION permitir_actualizar_valor_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE
  --vcambio  cvp.relpre.cambio%type;
  valterable  cvp.prodatr.alterable%type;
  vvalor_1 cvp.relatr.valor%type;
  vvaloresvalidos record;
  vvalido boolean;
  vhayquevalidar boolean;
  --vespositivo cvp.tipopre.espositivo%type;
  vpuedecambiaratributos cvp.tipopre.puedecambiaratributos%type;
  vcantidadatributosgenerados integer; --en el periodo siguiente
  
BEGIN
  IF OLD.valor IS DISTINCT FROM NEW.valor THEN
    --SELECT cambio INTO vcambio
    --  FROM cvp.relpre
    --  WHERE periodo=NEW.periodo AND informante=NEW.informante AND visita=NEW.visita AND producto=NEW.producto AND
    --        observacion=NEW.observacion;
    --IF vcambio IS DISTINCT FROM 'C' THEN
    --  RAISE EXCEPTION 'No es posible modificar el valor del atributo cuando el campo cambio es distinto de C';
    --  RETURN NULL;
    --ELSE
    select count(*) into vcantidadatributosgenerados
      from cvp.relatr a
      where a.periodo    =cvp.moverperiodos(NEW.periodo,1) AND 
            a.producto   =NEW.producto AND
            a.observacion=NEW.observacion AND 
            a.informante =NEW.informante AND
            a.visita     =NEW.visita AND 
            a.atributo   =NEW.atributo;
    IF vcantidadatributosgenerados>0 THEN
      raise Exception 'Ya has sido generados los atributos del periodo siguiente; periodo %, producto % observacion % informante%, visita%, atributo % ', NEW.periodo, NEW.producto, NEW.observacion, NEW.informante, NEW.visita, NEW.atributo;
      RETURN NULL;
    ELSE
      SELECT coalesce(t.puedecambiaratributos,false) INTO vpuedecambiaratributos
      FROM cvp.relpre r 
      LEFT JOIN cvp.tipopre t on r.tipoprecio = t.tipoprecio
      WHERE r.periodo=NEW.periodo AND r.informante=NEW.informante AND r.visita=NEW.visita AND r.producto=NEW.producto AND
            r.observacion=NEW.observacion;
      IF not vpuedecambiaratributos THEN
        RAISE EXCEPTION 'No es posible modificar el valor del atributo si el tipo de precio no lo permite';
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
  END IF;
  
  RETURN NEW;
END;
$BODY$;