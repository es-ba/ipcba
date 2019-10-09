--UTF8: Sí
CREATE OR REPLACE FUNCTION setear_renglon_de_cal_mensajes_trg()
  RETURNS trigger AS
$BODY$
DECLARE
 vnuevorenglon INTEGER;
BEGIN
  SELECT COALESCE(MAX(renglon),0)+1 INTO vnuevorenglon
    FROM  cvp.cal_mensajes
    WHERE periodo=NEW.periodo
      AND calculo=NEW.calculo
      AND corrida= NEW.corrida;
   NEW.renglon= vnuevorenglon;  
 RETURN NEW; 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;

CREATE TRIGGER cal_mensajes_setear_renglon_trg
  BEFORE INSERT
  ON cal_mensajes
  FOR EACH ROW
  EXECUTE PROCEDURE setear_renglon_de_cal_mensajes_trg();
