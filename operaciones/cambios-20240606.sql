SET search_path =cvp;

CREATE OR REPLACE VIEW control_relev_telef AS
  select periodo, r.panel, r.tarea, r.informante, nombreinformante, 
    COALESCE(c.nombrecalle||' '||altura||' '||piso||' '||departamento, direccion) AS direccion,
    visita, r.encuestador||':'||p.nombre||' '||p.apellido AS encuestador, i.rubro, nombrerubro, 
    string_agg(r.formulario::text||':'||nombreformulario,'; ') AS formularios
    FROM cvp.relvis r 
      LEFT JOIN cvp.formularios f on r.formulario = f.formulario
      LEFT JOIN cvp.personal p on r.encuestador = p.persona
      LEFT JOIN cvp.informantes i on r.informante = i.informante
      LEFT JOIN cvp.rubros u on i.rubro = u.rubro
      LEFT JOIN cvp.calles c on i.calle = c.calle
    WHERE u.telefonico = 'S'  
    GROUP BY 1,2,3,4,5,6,7,8,9,10
    ORDER BY periodo, panel, tarea, informante;

CREATE FUNCTION generar_direccion_informante_trg() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
vnombrecalle TEXT;
BEGIN
SELECT nombrecalle INTO vnombrecalle
FROM cvp.calles
WHERE calle = NEW.calle;
IF TG_OP = 'INSERT' THEN 
  NEW.direccion := TRIM(COALESCE(vnombrecalle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
  ELSIF TG_OP = 'UPDATE' THEN
   IF COALESCE(NEW.calle,'') <> COALESCE(OLD.calle,'') 
     OR COALESCE(NEW.altura,'') <> COALESCE(OLD.altura,'') 
     OR COALESCE(NEW.piso,'') <> COALESCE(OLD.piso,'') 
     OR COALESCE(NEW.departamento,'') <> COALESCE(OLD.departamento,'') THEN
     NEW.direccion := TRIM(COALESCE(vnombrecalle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
   END IF;
END IF;
RETURN NEW;
END;
$$;

