CREATE FUNCTION generar_direccion_informante_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF TG_OP = 'INSERT' THEN 
  NEW.direccion := TRIM(COALESCE(NEW.nombrecalle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
  ELSIF TG_OP = 'UPDATE' THEN
   IF COALESCE(NEW.nombrecalle,'') <> COALESCE(OLD.nombrecalle,'') 
     OR COALESCE(NEW.altura,'') <> COALESCE(OLD.altura,'') 
     OR COALESCE(NEW.piso,'') <> COALESCE(OLD.piso,'') 
     OR COALESCE(NEW.departamento,'') <> COALESCE(OLD.departamento,'') THEN
     NEW.direccion := TRIM(COALESCE(NEW.nombrecalle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
   END IF;
END IF;
RETURN NEW;
END;
$$;

CREATE TRIGGER informantes_direccion_trg 
   BEFORE INSERT OR UPDATE ON informantes 
   FOR EACH ROW EXECUTE PROCEDURE generar_direccion_informante_trg();