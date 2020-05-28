CREATE OR REPLACE FUNCTION restaurar_atributos_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vatributos RECORD;
  vpuedecambiaratributosnew  cvp.tipopre.puedecambiaratributos%type;
  vpuedecambiaratributosold  cvp.tipopre.puedecambiaratributos%type;
  vblanqueonew               cvp.tipopre.registrablanqueo%type;
BEGIN
  SELECT puedecambiaratributos, registrablanqueo INTO vpuedecambiaratributosnew, vblanqueonew
    FROM  cvp.tipopre
    WHERE tipoprecio=NEW.tipoprecio;
  SELECT puedecambiaratributos INTO vpuedecambiaratributosold
    FROM  cvp.tipopre
    WHERE tipoprecio=OLD.tipoprecio;

  IF ((NEW.cambio IS NULL AND OLD.cambio ='C') OR (not vpuedecambiaratributosnew)) AND vblanqueonew IS NOT TRUE THEN
    /*IF NEW.cambio='C' THEN --este caso solo para la segunda condicion si hubiera C
       NEW.cambio:=NULL;     --lo saco porque se solapa con la validacion de tipoprecio valido
    END IF; */
    
    INSERT INTO cvp.relpresemaforo (periodo,informante,visita,producto,observacion)
      VALUES(NEW.periodo,NEW.informante,NEW.visita,NEW.producto, NEW.observacion);
    FOR vatributos IN 
      SELECT r_1.atributo,r_1.valor_1, r_1.valor
      FROM cvp.relatr_1 r_1
            WHERE r_1.periodo=NEW.periodo AND 
                  r_1.producto=NEW.producto AND
                  r_1.observacion=NEW.observacion AND 
                  r_1.informante=NEW.informante AND
                  r_1.visita=NEW.visita 
   	
    LOOP
      IF vatributos.valor_1 IS DISTINCT FROM vatributos.valor THEN
        UPDATE cvp.relatr 
          SET valor=vatributos.valor_1
          WHERE periodo=NEW.periodo AND 
                producto=NEW.producto AND
                observacion=NEW.observacion AND 
                informante=NEW.informante AND
                visita=NEW.visita AND
                atributo=vatributos.atributo ; --TOMAR VALOR DE ATRIBUTO
      END IF;   
    END LOOP;  
  END IF;
 RETURN NEW; 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER relpre_restaura_atributos_trg 
   BEFORE UPDATE 
   ON relpre 
   FOR EACH ROW EXECUTE PROCEDURE restaurar_atributos_trg();
