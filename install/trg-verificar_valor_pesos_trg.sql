CREATE OR REPLACE FUNCTION verificar_valor_pesos_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  ves_nacional boolean;
BEGIN 
 SELECT es_nacional  INTO ves_nacional
   FROM cvp.monedas
   WHERE moneda=NEW.moneda;
 IF ves_nacional AND NEW.valor_pesos IS DISTINCT FROM 1 THEN 
   RAISE EXCEPTION 'No se permite actualizar valor_pesos si moneda es nacional % ',new.moneda;
   RETURN NULL;
 END IF;
 RETURN NEW;     
END;  
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER relmon_moneda_trg
  BEFORE UPDATE
  ON relmon
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_valor_pesos_trg();
