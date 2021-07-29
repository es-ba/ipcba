set search_path = cvp;

--sólo va a borrar de blapre y blaatr si es que se recuperan (o sea cuando se revierte el blanqueo) en trigger relpre_restaurar_atributos_blanqueados_trg
CREATE OR REPLACE FUNCTION adm_blanqueo_precios_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vblanqueonew  cvp.tipopre.registrablanqueo%type;
  vblanqueoold  cvp.tipopre.registrablanqueo%type;
BEGIN
  SELECT registrablanqueo INTO vblanqueonew
    FROM  cvp.tipopre
    WHERE tipoprecio=NEW.tipoprecio;
  SELECT registrablanqueo INTO vblanqueoold
    FROM  cvp.tipopre
    WHERE tipoprecio=OLD.tipoprecio;
  
  IF OLD.tipoprecio is distinct from NEW.tipoprecio THEN
    IF vblanqueonew and not vblanqueoold THEN
        INSERT INTO cvp.blapre(
            periodo, producto, observacion, informante, formulario, precio, 
            tipoprecio, visita, modi_usu, modi_fec, modi_ope, comentariosrelpre, 
            cambio, precionormalizado, especificacion, ultima_visita)
        VALUES (OLD.periodo, OLD.producto, OLD.observacion, OLD.informante, OLD.formulario, OLD.precio, 
            OLD.tipoprecio, OLD.visita, OLD.modi_usu, OLD.modi_fec, OLD.modi_ope, OLD.comentariosrelpre, 
            OLD.cambio, OLD.precionormalizado, OLD.especificacion, OLD.ultima_visita);
        --
        INSERT INTO cvp.blaatr 
            SELECT * FROM cvp.relatr 
            WHERE periodo=NEW.periodo AND 
               producto=NEW.producto AND
               observacion=NEW.observacion AND 
               informante=NEW.informante AND
               visita=NEW.visita;  
    END IF;
	/*
    IF not vblanqueonew and vblanqueoold THEN
        DELETE FROM cvp.blaatr 
        WHERE periodo=NEW.periodo AND 
              producto=NEW.producto AND
              observacion=NEW.observacion AND 
              informante=NEW.informante AND
              visita=NEW.visita;
        DELETE FROM cvp.blapre
        WHERE periodo=NEW.periodo AND 
              producto=NEW.producto AND
              observacion=NEW.observacion AND 
              informante=NEW.informante AND
              visita=NEW.visita;
    END IF;
	*/
  END IF;
 RETURN NEW; 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
  
CREATE OR REPLACE FUNCTION restaurar_atributos_blanqueados_trg()
  RETURNS trigger AS
$BODY$
DECLARE
  vatributosblanqueados RECORD;
  vblanqueonew               cvp.tipopre.registrablanqueo%type;
  vblanqueoold               cvp.tipopre.registrablanqueo%type;
BEGIN
  SELECT registrablanqueo INTO vblanqueonew
    FROM  cvp.tipopre
    WHERE tipoprecio=NEW.tipoprecio;
  SELECT registrablanqueo INTO vblanqueoold
    FROM  cvp.tipopre
    WHERE tipoprecio=OLD.tipoprecio;
  --
  IF vblanqueoold AND NOT vblanqueonew THEN
    --INSERT INTO cvp.relpresemaforo (periodo,informante,visita,producto,observacion)
    --  VALUES(NEW.periodo,NEW.informante,NEW.visita,NEW.producto, NEW.observacion);
    FOR vatributosblanqueados IN 
      SELECT b.atributo, b.valor as valorblanqueado
      FROM cvp.blaatr b
            WHERE b.periodo=NEW.periodo AND 
                  b.producto=NEW.producto AND
                  b.observacion=NEW.observacion AND 
                  b.informante=NEW.informante AND
                  b.visita=NEW.visita 
   	
    LOOP
        UPDATE cvp.relatr 
          SET valor=vatributosblanqueados.valorblanqueado
          WHERE periodo=NEW.periodo AND 
                producto=NEW.producto AND
                observacion=NEW.observacion AND 
                informante=NEW.informante AND
                visita=NEW.visita AND
                atributo=vatributosblanqueados.atributo AND 
				valor IS DISTINCT FROM vatributosblanqueados.valorblanqueado;
    END LOOP;
	--Borrado en blapre y blaatr
	DELETE FROM cvp.blaatr 
    WHERE periodo=NEW.periodo AND 
          producto=NEW.producto AND
          observacion=NEW.observacion AND 
          informante=NEW.informante AND
          visita=NEW.visita;
    DELETE FROM cvp.blapre
    WHERE periodo=NEW.periodo AND 
          producto=NEW.producto AND
          observacion=NEW.observacion AND 
          informante=NEW.informante AND
          visita=NEW.visita;
  END IF;
  --
 RETURN NEW; 
END;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
  
CREATE TRIGGER relpre_restaurar_atributos_blanqueados_trg
    AFTER UPDATE OF tipoprecio
    ON cvp.relpre
    FOR EACH ROW
    EXECUTE PROCEDURE cvp.restaurar_atributos_blanqueados_trg();

update informantes set direccion = null where direccion='';

alter table informantes add CONSTRAINT  "direccion<>''" check (direccion<>'');

--agregar modalidad a las HDRs:
CREATE OR REPLACE VIEW hdrexportar AS 
 SELECT c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante as ti, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista,
   c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor,
   CASE
     WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
     ELSE COALESCE(min(c.razon) || ''::text, null)
   END AS razon, 
   c.visita, c.nombreinformante, c.direccion, string_agg(c.formulario::text || ':'::text || c.nombreformulario::text, '|'::text) AS formularios, 
   (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto, 
    c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, 
    a.maxperiodoinformado, a.minperiodoinformado, a.periodoalta, pta.modalidad
   FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT cr.informante, cr.visita, max(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as maxperiodoinformado,
                min(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as minperiodoinformado, min(periodo) as periodoalta
                FROM cvp.control_hojas_ruta cr 
                LEFT JOIN cvp.razones z using(razon)
                GROUP BY cr.informante, cr.visita) a ON c.informante = a.informante AND c.visita = a.visita
      LEFT JOIN cvp.pantar pta on c.panel = pta.panel and c.tarea = pta.tarea
  GROUP BY c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista, 
    c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor, c.visita, c.nombreinformante, c.direccion, 
    (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, 
    a.minperiodoinformado, a.periodoalta, pta.modalidad;

CREATE OR REPLACE VIEW hdrexportarteorica AS 
 SELECT c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante as ti, t.encuestador||':'||p.nombre||' '||p.apellido as encuestador,
   COALESCE(string_agg(distinct c.encuestador||':'||c.nombreencuestador, '|'::text),null) as encuestadores, 
   COALESCE(string_agg(distinct c.recepcionista||':'||c.nombrerecepcionista, '|'::text),null) as recepcionistas, 
   COALESCE(string_agg(distinct c.ingresador||':'||c.nombreingresador, '|'::text),null) as ingresadores, 
   COALESCE(string_agg(distinct c.supervisor||':'||c.nombresupervisor, '|'::text),null) as supervisores, 
   CASE
     WHEN min(c.razon) <> max(c.razon) THEN (min(c.razon) || '~'::text) || max(c.razon)
     ELSE COALESCE(min(c.razon) || ''::text, null)
   END AS razon,
   string_agg(c.formulario::text || ' '::text || c.nombreformulario::text, chr(10) order by c.formulario) AS formularioshdr,
   lpad(' '::text, count(*)::integer, chr(10)) AS espacio,   
   c.visita, c.nombreinformante, c.direccion, string_agg(c.formulario::text || ':'::text || c.nombreformulario::text, '|') AS formularios, 
   i.contacto::text contacto, 
   c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email,
   pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta, pta.modalidad
   FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.tareas t on c.tarea = t.tarea
   LEFT JOIN cvp.personal p on p.persona = t.encuestador 
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT cr.informante, cr.visita, max(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as maxperiodoinformado,
                min(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as minperiodoinformado, min(periodo) as periodoalta
                FROM cvp.control_hojas_ruta cr 
                LEFT JOIN cvp.razones z using(razon)
                GROUP BY cr.informante, cr.visita) a ON c.informante = a.informante AND c.visita = a.visita
   LEFT JOIN (SELECT informante, visita, string_agg(distinct panel::text,',' order by panel::text) as panelreferencia, string_agg(distinct tarea::text,',' order by tarea::text) as tareareferencia
                FROM cvp.relvis v 
                JOIN cvp.parametros par ON unicoregistro AND v.periodo = par.periodoReferenciaParaPanelTarea
                GROUP BY informante, visita) pt ON c.informante = pt.informante AND c.visita = pt.visita
    LEFT JOIN cvp.pantar pta on c.panel = pta.panel and c.tarea = pta.tarea  
  GROUP BY c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante, t.encuestador||':'||p.nombre||' '||p.apellido, c.visita, c.nombreinformante, c.direccion, 
    i.contacto, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email,
    pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta, pta.modalidad;
