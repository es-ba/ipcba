CREATE OR REPLACE VIEW cvp.control_relev_telef
 AS
 SELECT r.periodo,
    r.panel,
    r.tarea,
    r.informante,
    i.nombreinformante,
    COALESCE((((((c.nombrecalle::text || ' '::text) || i.altura::text) || ' '::text) || i.piso::text) || ' '::text) || i.departamento::text, i.direccion::text) AS direccion,
    r.visita,
    (((r.encuestador::text || ':'::text) || p.nombre::text) || ' '::text) || p.apellido::text AS encuestador,
    i.rubro,
    u.nombrerubro,
    string_agg((r.formulario::text || ':'::text) || f.nombreformulario::text, '; '::text) AS formularios
   FROM cvp.relvis r
     LEFT JOIN cvp.formularios f ON r.formulario = f.formulario
     LEFT JOIN cvp.personal p ON r.encuestador::text = p.persona::text
     LEFT JOIN cvp.informantes i ON r.informante = i.informante
     LEFT JOIN cvp.rubros u ON i.rubro = u.rubro
     LEFT JOIN CVP.calles c ON i.calle = c.calle
  WHERE u.telefonico::text = 'S'::text
  GROUP BY r.periodo, r.panel, r.tarea, r.informante, i.nombreinformante, (COALESCE((((((c.nombrecalle::text || ' '::text) || i.altura::text) || ' '::text) || i.piso::text) || ' '::text) || i.departamento::text, i.direccion::text)), r.visita, ((((r.encuestador::text || ':'::text) || p.nombre::text) || ' '::text) || p.apellido::text), i.rubro, u.nombrerubro
  ORDER BY r.periodo, r.panel, r.tarea, r.informante;

CREATE OR REPLACE FUNCTION cvp.generar_direccion_informante_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

BEGIN
IF TG_OP = 'INSERT' THEN 
  NEW.direccion := TRIM(COALESCE(NEW.calle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
  ELSIF TG_OP = 'UPDATE' THEN
   IF COALESCE(NEW.calle,'') <> COALESCE(OLD.calle,'') 
     OR COALESCE(NEW.altura,'') <> COALESCE(OLD.altura,'') 
     OR COALESCE(NEW.piso,'') <> COALESCE(OLD.piso,'') 
     OR COALESCE(NEW.departamento,'') <> COALESCE(OLD.departamento,'') THEN
     NEW.direccion := TRIM(COALESCE(NEW.calle||' ','')||COALESCE(NEW.altura||' ','')||COALESCE('PISO '||NEW.piso||' ','')||COALESCE('DPTO '||NEW.departamento,''));
   END IF;
END IF;
RETURN NEW;
END;
$BODY$;

