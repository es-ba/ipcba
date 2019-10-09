CREATE FUNCTION validar_fechas_visita_trg() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
-- V100430
-- DECLARE
BEGIN
  IF TG_OP='UPDATE' THEN
    IF new.fechasalida IS NOT NULL AND new.fechaingreso IS NOT NULL THEN
      IF new.fechasalida <= new.fechaingreso THEN
        -- OK
      ELSE
         RAISE EXCEPTION 'La fecha de ingreso no puede ser menor a la fecha de salida';
         RETURN NULL;
      END IF;      
    END IF;
  END IF;  
  RETURN NEW;
END;
$$;

CREATE TRIGGER relvis_fechas_visita_trg 
   BEFORE UPDATE 
   ON relvis 
   FOR EACH ROW EXECUTE PROCEDURE validar_fechas_visita_trg();
