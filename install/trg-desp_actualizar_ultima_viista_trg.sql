CREATE OR REPLACE FUNCTION desp_actualizar_ultima_visita_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vHay INTEGER; 
  vmaxvisita INTEGER;
  
BEGIN

IF NEW.ultima_visita IS NULL THEN 
  SELECT 1 INTO vmaxvisita
    FROM cvp.relpre 
    WHERE periodo = new.periodo and informante = new.informante and producto =new.producto and observacion = new.observacion
          AND visita = new.visita +1;
      
  IF vmaxvisita is null THEN
    INSERT INTO cvp.relpre(periodo, producto, observacion, informante, formulario, visita, especificacion, ultima_visita)
        VALUES(new.periodo, new.producto, new.observacion, new.informante, new.formulario, new.visita +1, new.especificacion, true); 
  END IF;
END IF;  
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE TRIGGER relpre_desp_actualiza_ultima_visita_trg
  AFTER UPDATE
  ON relpre
  FOR EACH ROW
  EXECUTE PROCEDURE desp_actualizar_ultima_visita_trg();