CREATE OR REPLACE FUNCTION calcular_precionormaliz_relatr_trg()
  RETURNS trigger AS
$BODY$
DECLARE 
existesemaforo INTEGER;
BEGIN

 SELECT 1 INTO existesemaforo
   FROM cvp.relpresemaforo a
      WHERE  a.periodo=NEW.periodo AND a.informante=NEW.informante AND a.visita=NEW.visita 
        AND  a.producto=NEW.producto AND a.observacion=NEW.observacion; 
 IF existesemaforo IS NULL THEN
   INSERT INTO cvp.relpresemaforo(periodo,informante,visita,producto,observacion)
     VALUES(NEW.periodo,NEW.informante,NEW.visita,NEW.producto, NEW.observacion);
     
    UPDATE cvp.relpre  
      SET precionormalizado=NULL
      WHERE periodo=NEW.periodo AND informante=NEW.informante 
        AND visita=NEW.visita AND producto=NEW.producto AND observacion=NEW.observacion;     
 END IF;
 RETURN NULL;
 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER relatr_normaliza_precio_trg
  AFTER UPDATE
  ON relatr
  FOR EACH ROW
  EXECUTE PROCEDURE calcular_precionormaliz_relatr_trg();