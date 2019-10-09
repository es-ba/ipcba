CREATE OR REPLACE FUNCTION verificar_insercion_ultima_visita_trg()
  RETURNS trigger AS
$BODY$
DECLARE
 vHay INTEGER; 
 vPanel INTEGER;
 vTarea INTEGER;
BEGIN
IF OLD.ultima_visita IS DISTINCT FROM NEW.ultima_visita and OLD.ultima_visita is TRUE THEN
  SELECT DISTINCT 1 INTO vHay
    FROM cvp.prodatr p, cvp.parametros par, cvp.atributos a 
    WHERE p.atributo = a.atributo AND (a.Es_Vigencia = TRUE OR par.puedeagregarvisita = 'S') AND p.producto = new.producto;
	
  IF vHay is null THEN
     RAISE EXCEPTION 'No se permite agregar visitas para este producto % ',new.producto;
     RETURN NULL;
  ELSE
     SELECT 1 INTO vHay  
       FROM cvp.relvis v
       WHERE v.periodo = new.periodo and v.informante = new.informante and v.visita = new.visita+1 and v.formulario = new.formulario;
       
     IF vHay is null THEN
       SELECT panel, tarea INTO vPanel, vTarea 
         FROM cvp.relvis v
         WHERE v.periodo = new.periodo and v.informante = new.informante and v.ultima_visita = TRUE and v.formulario = new.formulario;
       
       UPDATE cvp.relvis SET ultima_visita = NULL 
         WHERE periodo = new.periodo and informante = new.informante and ultima_visita = TRUE and formulario = new.formulario; 
       
	   --RAISE NOTICE 'verificar_insercion_ultima_visita_trg PERIODO: % informante: % formulario: % visita: % ', new.periodo, new.informante, new.formulario, new.visita+1;
       
	   INSERT INTO cvp.relvis
         (periodo ,
         informante,
         formulario,
         panel,
         tarea,
         visita,
         ultima_visita)
         VALUES (new.periodo, new.informante, new.formulario, vPanel, vTarea, new.visita+1, TRUE);              
     END IF;
 
     new.ultima_visita = null;
  END IF;       
END IF; 
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
CREATE TRIGGER relpre_actualiza_ultima_visita_trg
  BEFORE UPDATE
  ON relpre
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_insercion_ultima_visita_trg();
  