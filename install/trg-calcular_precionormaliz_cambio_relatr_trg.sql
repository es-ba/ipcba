CREATE OR REPLACE FUNCTION calcular_precionormaliz_cambio_relatr_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
DECLARE 
existesemaforo INTEGER;
vcambio cvp.relpre.cambio%type;

BEGIN
 --raise notice 'calcular_precionormaliz_cambio_relatr_trg new.valor: % , old.valor: % ', new.valor, old.valor;
 SELECT 1 INTO existesemaforo
   FROM cvp.relpresemaforo a
      WHERE  a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita=NEW.visita 
        AND  a.producto=NEW.producto AND a.observacion=NEW.observacion; 
 IF existesemaforo IS NULL THEN
   INSERT INTO cvp.relpresemaforo(periodo,informante,visita,producto,observacion)
     VALUES(NEW.periodo,NEW.informante,NEW.visita,NEW.producto, NEW.observacion);
 
   SELECT case when count(*)=0 THEN NULL ELSE 'C' END INTO vcambio
    FROM cvp.relatr_1 a
      WHERE  a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita=NEW.visita 
        AND  a.producto=NEW.producto AND a.observacion=NEW.observacion and a.valor is distinct from a.valor_1; 

    UPDATE cvp.relpre  
      SET precionormalizado=NULL, cambio = vcambio
      WHERE periodo=NEW.periodo AND informante=NEW.informante 
        AND visita=NEW.visita AND producto=NEW.producto AND observacion=NEW.observacion;     
 END IF;
 RETURN NULL;
 
END;
$BODY$;

CREATE TRIGGER relatr_normaliza_precio_cambio_trg
    AFTER UPDATE 
    ON relatr
    FOR EACH ROW
    EXECUTE PROCEDURE calcular_precionormaliz_cambio_relatr_trg();
