CREATE FUNCTION relvis_tarea_trg() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
 DECLARE
   vhay INTEGER;
BEGIN
  IF NEW.tarea IS NOT NULL  THEN
      SELECT 1 INTO vhay
        FROM cvp.tareas
        WHERE tarea= NEW.tarea;
        
      IF vHay IS NULL THEN
        RAISE EXCEPTION 'Tarea % Inexistente ',new.tarea;
        RETURN NULL;
      END IF;  
    END IF;    
 
  RETURN NEW;
END;
$$;

CREATE TRIGGER relvis_valida_tarea_trg 
   BEFORE INSERT OR UPDATE 
   ON relvis FOR EACH ROW EXECUTE PROCEDURE relvis_tarea_trg();
