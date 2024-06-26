SET search_path =cvp;
--------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION actualizar_nombrecalle_informante_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  IF NEW.nombrecalle IS DISTINCT FROM OLD.nombrecalle THEN
    UPDATE cvp.informantes i 
      SET nombrecalle = NEW.nombrecalle
    WHERE i.calle = new.calle;
  END IF;
RETURN NEW;
END;
$$;
ALTER FUNCTION cvp.actualizar_nombrecalle_informante_trg()
    OWNER TO cvpowner;

CREATE OR REPLACE TRIGGER calles_actualizar_nombrecalle_informante_trg
    AFTER UPDATE 
    ON cvp.calles
    FOR EACH ROW
    EXECUTE FUNCTION cvp.actualizar_nombrecalle_informante_trg();

---------------------------------------------------------------
CREATE OR REPLACE FUNCTION generar_direccion_informante_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
vnombrecalle   character varying(100);
vparadireccion character varying(100);
BEGIN
SELECT nombrecalle INTO vnombrecalle
  FROM calles 
  WHERE calle = NEW.calle;
vparadireccion := COALESCE(vnombrecalle, NEW.nombrecalle);
IF TG_OP = 'INSERT' THEN 
  --NEW.direccion := TRIM(COALESCE(NEW.nombrecalle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
  NEW.direccion := TRIM(vparadireccion||' '||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
  ELSIF TG_OP = 'UPDATE' THEN
   IF NEW.CALLE IS DISTINCT FROM OLD.calle
     OR COALESCE(vparadireccion,'') <> COALESCE(OLD.nombrecalle,'') 
     OR COALESCE(NEW.altura,'') <> COALESCE(OLD.altura,'') 
     OR COALESCE(NEW.piso,'') <> COALESCE(OLD.piso,'') 
     OR COALESCE(NEW.departamento,'') <> COALESCE(OLD.departamento,'') THEN
     --NEW.direccion := TRIM(COALESCE(NEW.nombrecalle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
     NEW.direccion := TRIM(vparadireccion||' '||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
   END IF;
END IF;
RETURN NEW;
END;
$$;
---------------------------------------------------------------




