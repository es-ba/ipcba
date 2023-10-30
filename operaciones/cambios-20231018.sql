set search_path = cvp;
CREATE OR REPLACE FUNCTION altamanualdeinformantes_trg()
  RETURNS trigger AS 
$BODY$
DECLARE
vseguir boolean:= true;
vcantfilasgeneradas integer:= 0;
vesactiva integer:= 0; --es tarea activa? (en tabla tareas)
vesptactiva integer:= 0;  --es panel-tarea activo? (tabla tabla pantar)
begin
  IF NEW.AltaManualConfirmar is distinct from OLD.AltaManualConfirmar then
    vseguir := true;
    IF NEW.altamanualperiodo IS NULL THEN
       RAISE EXCEPTION 'Falta especificar periodo donde se generará';
       vseguir := false;
       RETURN NULL;
    END IF;
    IF NEW.altamanualpanel IS NULL THEN
       RAISE EXCEPTION 'Falta especificar panel donde se generará';
       vseguir := false;
       RETURN NULL;
    END IF;
    IF NEW.altamanualtarea IS NULL THEN
       RAISE EXCEPTION 'Falta especificar tarea donde se generará';
       vseguir := false;
       RETURN NULL;
    END IF;
    SELECT count(*) INTO vesactiva 
    FROM cvp.tareas 
    WHERE tarea = NEW.altamanualtarea AND activa = 'S';
    IF vesactiva = 0 THEN
       RAISE EXCEPTION 'La tarea en la cual se generará no está activa';
       vseguir := false;
       RETURN NULL;
    END IF;
    SELECT count(*) INTO vesptactiva 
    FROM cvp.pantar 
    WHERE panel = NEW.altamanualpanel AND tarea = NEW.altamanualtarea AND activa = 'S';
    IF vesptactiva = 0 THEN
       RAISE EXCEPTION 'El panel-tarea en la cual se generará no está activo (pantar)';
       vseguir := false;
       RETURN NULL;
    END IF;
    select count(*) INTO vcantfilasgeneradas--new.altamanualperiodo, 1, new.informante, fi.formulario, new.altamanualPanel, new.AltaManualTarea, 
      from cvp.ForInf fi
      where fi.informante=new.informante and fi.altamanualperiodo = new.altamanualperiodo
      AND NOT EXISTS (SELECT * FROM cvp.relvis v
                       WHERE v.periodo = new.altamanualperiodo AND v.visita = 1 AND v.informante= new.informante 
                       AND v.formulario=fi.formulario);
    IF vcantfilasgeneradas = 0 THEN
       RAISE EXCEPTION 'Falta especificar periodo de alta para el formulario a generar (no se generarán filas)';
       vseguir := false;
       RETURN NULL;
    END IF;
    IF vseguir THEN
       DELETE FROM cvp.relvis rd USING
       (SELECT r.periodo, r.informante, r.formulario, r.visita
         FROM cvp.relvis r
            LEFT JOIN cvp.informantes i ON r.informante = i.informante
            LEFT JOIN cvp.periodos p ON r.periodo=p.periodo 
            LEFT JOIN (SELECT periodo, informante, formulario, max(visita) AS maxvisita
                       FROM cvp.relvis
                       WHERE panel = NEW.AltaManualPanel --Parámetro
                       GROUP BY  periodo, informante, formulario) v ON v.periodo=p.periodoanterior 
                                                                      AND v.informante = r.informante 
                                                                      AND v.formulario = r.formulario
            LEFT JOIN cvp.relvis r_1 ON r_1.periodo = p.periodoanterior
                                       AND r_1.informante = r.informante 
                                       AND r_1.formulario = r.formulario
                                       AND r_1.visita = maxvisita          
            LEFT JOIN cvp.razones z ON r_1.razon = z.razon
            LEFT JOIN (SELECT distinct periodo, informante, visita, formulario, 'S' hayprecios 
                         FROM cvp.relpre) pr ON pr.periodo = r.periodo
                           AND pr.informante = r.informante
                           AND pr.visita = r.visita 
                           AND pr.formulario = r.formulario 
          WHERE r.periodo = NEW.AltaManualPeriodo --Parámetro
            AND r.informante = NEW.informante --Parámetro 
            AND r.panel= NEW.AltaManualPanel --Parámetro
            AND r.tarea= NEW.AltaManualTarea --Parámetro
            --AltaManualPeriodo es el periodo actual
            AND coalesce(i.AltaManualPeriodo,'a0000m00') = NEW.AltaManualPeriodo --Parámetro
            --periodo anterior sin visita en relvis o visita anterior con cierre definitivo  
            AND (maxvisita IS NULL OR COALESCE(z.escierredefinitivoinf,'N')='S' OR COALESCE(z.escierredefinitivofor,'N')='S')
            -- periodo actual sin razon ingresada y sin precios
            AND r.razon IS NULL AND COALESCE(hayprecios,'N') = 'N') d
        WHERE rd.periodo = d.periodo and rd.informante = d.informante and rd.formulario = d.formulario and rd.visita = d.visita;
       
       insert into cvp.relvis (periodo, visita, informante, formulario, 
                               panel, tarea, FechaSalida, Encuestador, ultima_visita)
         select new.altamanualperiodo, 1, new.informante, fi.formulario, new.altamanualPanel, new.AltaManualTarea, 
                (select p.FechaSalida 
                   from cvp.RelPan p
                   where p.periodo=new.AltaManualPeriodo and p.panel=new.AltaManualPanel) as fecha,
                (select t.Encuestador
                   from cvp.Tareas t
                   where t.tarea=new.AltaManualTarea) as encuestador, true
                   from cvp.ForInf fi
                   where fi.informante=new.informante and fi.altamanualperiodo = new.altamanualperiodo
                   AND NOT EXISTS (SELECT * FROM cvp.relvis v
                                    WHERE v.periodo = new.altamanualperiodo AND v.visita = 1 AND v.informante= new.informante 
                                    AND v.formulario=fi.formulario);
     end if;
  end if;
  return new;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE OR REPLACE VIEW hdrexportarteorica AS  ----informantes/hoja de ruta/teorica
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
   pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta, pta.modalidad, q.otropaneltarea, i.cadena
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
    LEFT JOIN cvp.reltar pta on c.periodo = pta.periodo and c.panel = pta.panel and c.tarea = pta.tarea
    LEFT JOIN (SELECT periodo, informante, string_agg('Panel '||panel||' , '||'Tarea '||tarea, chr(10) order by 'Panel '||panel||' , '||'Tarea '||tarea) as otropaneltarea
                 FROM (SELECT DISTINCT periodo, informante, panel, tarea from relvis) r
                 GROUP BY periodo, informante
                 HAVING COUNT(DISTINCT (panel, tarea)) > 1) q ON c.periodo = q.periodo and c.informante = q.informante
GROUP BY c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante, t.encuestador||':'||p.nombre||' '||p.apellido, c.visita, c.nombreinformante, c.direccion, 
    i.contacto, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email,
    pt.panelreferencia, pt.tareareferencia, i.telcontacto, a.periodoalta, pta.modalidad, q.otropaneltarea, i.cadena;

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
    a.maxperiodoinformado, a.minperiodoinformado, a.periodoalta, pta.modalidad, i.cadena
   FROM cvp.control_hojas_ruta c
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT cr.informante, cr.visita, max(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as maxperiodoinformado,
                min(CASE WHEN espositivoformulario = 'S' THEN periodo ELSE NULL END) as minperiodoinformado, min(periodo) as periodoalta
                FROM cvp.control_hojas_ruta cr 
                LEFT JOIN cvp.razones z using(razon)
                GROUP BY cr.informante, cr.visita) a ON c.informante = a.informante AND c.visita = a.visita
      LEFT JOIN cvp.reltar pta on c.periodo = pta.periodo and c.panel = pta.panel and c.tarea = pta.tarea
  GROUP BY c.periodo, c.panel, c.tarea, c.fechasalida, c.informante, i.tipoinformante, c.encuestador, c.nombreencuestador, c.recepcionista, c.nombrerecepcionista, 
    c.ingresador, c.nombreingresador, c.supervisor, c.nombresupervisor, c.visita, c.nombreinformante, c.direccion, 
    (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, 
    a.minperiodoinformado, a.periodoalta, pta.modalidad, i.cadena;

