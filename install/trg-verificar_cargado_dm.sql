CREATE OR REPLACE FUNCTION verificar_cargado_dm()
  RETURNS trigger AS
$BODY$
DECLARE
vPeriodo     varchar(20);
vpanel       INTEGER;
vtarea       INTEGER;
vtabla       varchar(100);
vinformante  integer;
vvisita      integer;
vformulario  integer;
vpermitido   boolean;
vcargado     text;
vdescargado  text;
vproducto    character varying(8);
vobservacion integer;
BEGIN
vpermitido=true;
vtabla= TG_TABLE_NAME;
CASE vtabla
    WHEN 'relvis' THEN
        IF TG_OP= 'DELETE' THEN
            vperiodo= old.periodo;   
            vpanel= old.panel;   
            vtarea= old.tarea;   
        ELSE
            vperiodo= new.periodo;   
            vpanel= new.panel;   
            vtarea= new.tarea;   
        END IF;
        SELECT cargado IS NULL AND descargado IS NULL 
               OR cargado IS NOT NULL AND descargado IS NOT NULL AND cargado < descargado 
               OR cargado IS NULL AND descargado IS NOT NULL, 
               CASE WHEN cargado IS NULL THEN 'No cargado aún...' ELSE 'Cargado a DM el '||to_char(cargado,'DD/MM/YY hh24:mm:ss') END,
               CASE WHEN descargado IS NULL THEN 'No descargado aún...' ELSE 'Descargado de DM el '||to_char(descargado,'DD/MM/YY hh24:mm:ss') END
               INTO vpermitido, vcargado, vdescargado 
        FROM cvp.reltar
        WHERE periodo = vperiodo AND panel = vpanel AND tarea = vtarea;
    WHEN 'relpre' THEN
        IF TG_OP= 'DELETE' THEN
            vperiodo= old.periodo;   
            vinformante= old.informante;   
            vvisita= old.visita;   
            vformulario= old.formulario;   
        ELSE
            vperiodo= new.periodo;   
            vinformante= new.informante;   
            vvisita= new.visita;   
            vformulario= new.formulario;   
        END IF;
        SELECT cargado IS NULL AND descargado IS NULL 
               OR cargado IS NOT NULL AND descargado IS NOT NULL AND cargado < descargado 
               OR cargado IS NULL AND descargado IS NOT NULL, 
               CASE WHEN cargado IS NULL THEN 'No cargado aún...' ELSE 'Cargado a DM el '||to_char(cargado,'DD/MM/YY hh24:mm:ss') END,
               CASE WHEN descargado IS NULL THEN 'No descargado aún...' ELSE 'Descargado de DM el '||to_char(descargado,'DD/MM/YY hh24:mm:ss') END,
               r.panel, r.tarea
               INTO vpermitido, vcargado, vdescargado, vpanel, vtarea 
        FROM cvp.relvis r
        LEFT JOIN cvp.reltar t ON r.periodo = t.periodo AND r.panel = t.panel AND r.tarea = t.tarea   
        WHERE r.periodo = vperiodo AND r.informante = vinformante AND r.visita = vvisita AND r.formulario = vformulario;
    WHEN 'relatr' THEN
        IF TG_OP= 'DELETE' THEN
            vperiodo= old.periodo;   
            vinformante= old.informante;   
            vvisita= old.visita;   
            vproducto= old.producto;   
            vobservacion= old.observacion;   
        ELSE
            vperiodo= new.periodo;   
            vinformante= new.informante;   
            vvisita= new.visita;   
            vproducto= new.producto;   
            vobservacion= new.observacion;   
        END IF;
        SELECT cargado IS NULL AND descargado IS NULL 
               OR cargado IS NOT NULL AND descargado IS NOT NULL AND cargado < descargado 
               OR cargado IS NULL AND descargado IS NOT NULL, 
               CASE WHEN cargado IS NULL THEN 'No cargado aún...' ELSE 'Cargado a DM el '||to_char(cargado,'DD/MM/YY hh24:mm:ss') END,
               CASE WHEN descargado IS NULL THEN 'No descargado aún...' ELSE 'Descargado de DM el '||to_char(descargado,'DD/MM/YY hh24:mm:ss') END,
               r.panel, r.tarea
               INTO vpermitido, vcargado, vdescargado, vpanel, vtarea 
        FROM cvp.relpre p
        LEFT JOIN cvp.relvis r ON p.periodo = r.periodo AND p.informante = r.informante AND p.visita = r.visita AND p.formulario = r.formulario 
        LEFT JOIN cvp.reltar t ON r.periodo = t.periodo AND r.panel = t.panel AND r.tarea = t.tarea   
        WHERE p.periodo = vperiodo AND p.informante = vinformante AND p.visita = vvisita AND p.producto = vproducto AND p.observacion = vobservacion;
END CASE;
IF NOT vpermitido THEN
    RAISE EXCEPTION 'No se permite modificar el periodo %, panel %, tarea %. %, %', vperiodo, vpanel, vtarea, vcargado, vdescargado;
    RETURN NULL;
END IF;
IF TG_OP='DELETE' THEN
   RETURN OLD;
ELSE   
   RETURN NEW;
END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER relvis_dm_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relvis
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_cargado_dm();

CREATE TRIGGER relpre_dm_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relpre
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_cargado_dm();

CREATE TRIGGER relatr_dm_trg
  BEFORE INSERT OR UPDATE OR DELETE
  ON relatr
  FOR EACH ROW
  EXECUTE PROCEDURE verificar_cargado_dm();