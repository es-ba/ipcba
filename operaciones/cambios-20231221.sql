set search_path = cvp;
drop table if exists fechas;
drop table if exists licencias;

CREATE TABLE fechas(
fecha DATE,
visible_planificacion cvp.sino_dom,
seleccionada_planificacion cvp.sino_dom,
PRIMARY KEY (fecha));

ALTER TABLE fechas OWNER to cvpowner;
GRANT INSERT, SELECT, UPDATE ON TABLE fechas TO cvp_administrador;
GRANT SELECT ON TABLE fechas TO cvp_usuarios;
GRANT ALL ON TABLE fechas TO cvpowner;
--historico de fechas
CREATE OR REPLACE FUNCTION hisc_fechas_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
   DECLARE
     v_operacion text:=substr(TG_OP,1,1);
   BEGIN
        
      IF v_operacion='I' THEN
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
               VALUES ('cvp','fechas','fecha','I',new.fecha,new.fecha,'I:'||comun.a_texto(new.fecha),new.fecha);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
               VALUES ('cvp','fechas','visible_planificacion','I',new.fecha,new.fecha,'I:'||comun.a_texto(new.visible_planificacion),new.visible_planificacion);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,new_text)
               VALUES ('cvp','fechas','seleccionada_planificacion','I',new.fecha,new.fecha,'I:'||comun.a_texto(new.seleccionada_planificacion),new.seleccionada_planificacion);
      END IF;
      IF v_operacion='U' THEN
          IF new.fecha IS DISTINCT FROM old.fecha THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                   VALUES ('cvp','fechas','fecha','U',new.fecha,new.fecha,comun.A_TEXTO(old.fecha)||'->'||comun.a_texto(new.fecha),old.fecha,new.fecha);
          END IF;    
          IF new.visible_planificacion IS DISTINCT FROM old.visible_planificacion THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                   VALUES ('cvp','fechas','visible_planificacion','U',new.fecha,new.fecha,comun.A_TEXTO(old.visible_planificacion)||'->'||comun.a_texto(new.visible_planificacion),old.visible_planificacion,new.visible_planificacion);
          END IF;    
          IF new.seleccionada_planificacion IS DISTINCT FROM old.seleccionada_planificacion THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text,new_text)
                   VALUES ('cvp','fechas','seleccionada_planificacion','U',new.fecha,new.fecha,comun.A_TEXTO(old.seleccionada_planificacion)||'->'||comun.a_texto(new.seleccionada_planificacion),old.seleccionada_planificacion,new.seleccionada_planificacion);
          END IF;    
      END IF;
      IF v_operacion='D' THEN
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
               VALUES ('cvp','fechas','fecha','D',old.fecha,old.fecha,'D:'||comun.a_texto(old.fecha),old.fecha);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
               VALUES ('cvp','fechas','visible_planificacion','D',old.fecha,old.fecha,'D:'||comun.a_texto(old.visible_planificacion),old.visible_planificacion);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,change_value,old_text)
               VALUES ('cvp','fechas','seleccionada_planificacion','D',old.fecha,old.fecha,'D:'||comun.a_texto(old.seleccionada_planificacion),old.seleccionada_planificacion);
      END IF;
      IF v_operacion<>'D' THEN
        RETURN new;
      ELSE
        RETURN old;  
      END IF;
   END;
$BODY$;

ALTER FUNCTION hisc_fechas_trg() OWNER TO cvpowner;

CREATE TRIGGER hisc_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON fechas
    FOR EACH ROW
    EXECUTE FUNCTION hisc_fechas_trg();

CREATE TABLE licencias(
persona character varying(10),
fechadesde DATE,
fechahasta DATE,
motivo text,
PRIMARY KEY (persona,fechadesde,fechahasta),
FOREIGN KEY (persona) REFERENCES personal (persona));

ALTER TABLE licencias OWNER to cvpowner;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE licencias TO cvp_administrador;
GRANT SELECT ON TABLE licencias TO cvp_usuarios;
GRANT ALL ON TABLE licencias TO cvpowner;
--constraint fechasdesde <= fechahasta
ALTER TABLE licencias
    ADD CONSTRAINT "fechadesde <= fechahasta" CHECK (fechadesde <= fechahasta);

--historico de licencias
CREATE OR REPLACE FUNCTION hisc_licencias_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
   DECLARE
     v_operacion text:=substr(TG_OP,1,1);
   BEGIN
        
      IF v_operacion='I' THEN
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','persona','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.persona),new.persona);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','fechadesde','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.fechadesde),new.fechadesde);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','fechahasta','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.fechahasta),new.fechahasta);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,new_text)
               VALUES ('cvp','licencias','motivo','I',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,'I:'||comun.a_texto(new.motivo),new.motivo);
      END IF;
      IF v_operacion='U' THEN
          IF new.persona IS DISTINCT FROM old.persona THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','persona','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.persona)||'->'||comun.a_texto(new.persona),old.persona,new.persona);
          END IF;
          IF new.fechadesde IS DISTINCT FROM old.fechadesde THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','fechadesde','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.fechadesde)||'->'||comun.a_texto(new.fechadesde),old.fechadesde,new.fechadesde);
          END IF;
          IF new.fechahasta IS DISTINCT FROM old.fechahasta THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','fechahasta','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.fechahasta)||'->'||comun.a_texto(new.fechahasta),old.fechahasta,new.fechahasta);
          END IF;
          IF new.motivo IS DISTINCT FROM old.motivo THEN
              INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text,new_text)
                   VALUES ('cvp','licencias','motivo','U',new.persona||new.fechadesde||new.fechahasta,new.persona,new.fechadesde,new.fechahasta,comun.A_TEXTO(old.motivo)||'->'||comun.a_texto(new.motivo),old.motivo,new.motivo);
          END IF;
      END IF;
      IF v_operacion='D' THEN
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','persona','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.persona),old.persona);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','fechadesde','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.fechadesde),old.fechadesde);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','fechahasta','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.fechahasta),old.fechahasta);
          INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_text_2,pk_text_3,change_value,old_text)
               VALUES ('cvp','licencias','motivo','D',old.persona||old.fechadesde||old.fechahasta,old.persona,old.fechadesde,old.fechahasta,'D:'||comun.a_texto(old.motivo),old.motivo);
      END IF;
      IF v_operacion<>'D' THEN
        RETURN new;
      ELSE
        RETURN old;  
      END IF;
   END;
$BODY$;

ALTER FUNCTION hisc_licencias_trg() OWNER TO cvpowner;

CREATE TRIGGER hisc_trg
    BEFORE INSERT OR DELETE OR UPDATE 
    ON licencias
    FOR EACH ROW
    EXECUTE FUNCTION hisc_licencias_trg();


--al generar_panel, agregar a la tabla "fechas" la fila para la fecha de salida del panel 
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cvp.generar_panel(
    pperiodo text,
    ppanel integer,
    pfechasalida date,
    pfechageneracionpanel timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $BODY$
DECLARE
  f_hoy date= current_date;
  vexiste integer;
BEGIN
  /*
   V240214
       genera las filas para tabla fechas
   V230705
      genera filas para relpantarinf
   V190117
      genera el encuestador a partir de la tabla reltar
   V161201
      genera el encuestador a partir de la tabla relenc (si no hay relenc, entonces en tareas)
   V100730
      con borrado previo al insert por considerar re-generacion   
   V100726
      genera también las altas manuales. 
   V100527
      genera con última visita periodo anterior, única razon en relvis (informante-formulario)
   V100515
      genera el encuestador a partir de la tabla tareas
   V100508
      sin generar informantes con cierre definitivo en visita 1 del periodo anterior
     V080924
      sin generar de baja
  */
  if pFechaSalida is null then
    RAISE EXCEPTION 'no se puede generar un panel sin fecha de salida';
  end if;
  insert into cvp.bitacora (que) values ('nueva generacion panel '||pPeriodo||' p:'||pPanel||' g:'||pFechaGeneracionPanel);

  DELETE FROM cvp.relvis rd USING
    (SELECT r.periodo, r.informante, r.formulario, r.visita
      FROM cvp.relvis r
         LEFT JOIN cvp.informantes i ON r.informante = i.informante
         LEFT JOIN cvp.periodos p ON r.periodo=p.periodo
         LEFT JOIN cvp.relvis r_1 ON r_1.periodo = p.periodoanterior
                                    AND r_1.informante = r.informante 
                                    AND r_1.formulario = r.formulario
                                    AND r_1.visita = r.visita          
 
         --LEFT JOIN cvp.relvis r_1 ON r_1.periodo = r.periodo_1
         --                           AND r_1.informante = r.informante 
         --                           AND r_1.formulario = r.formulario
         --                           AND r_1.visita = r.visita_1          
         LEFT JOIN cvp.razones z ON r_1.razon = z.razon
         LEFT JOIN (SELECT distinct periodo, informante, visita, formulario, 'S' hayprecios 
                      FROM cvp.relpre) pr ON pr.periodo = r.periodo
                        AND pr.informante = r.informante
                        AND pr.visita = r.visita 
                        AND pr.formulario = r.formulario 
       WHERE r.periodo = Pperiodo
         AND r.panel= pPanel
         --AltaManualPeriodo no es el periodo actual
         AND (i.AltaManualPeriodo IS DISTINCT FROM Pperiodo OR NOT EXISTS (SELECT 1 FROM cvp.forinf fi WHERE fi.informante=r.informante AND fi.formulario=r.formulario))
         --periodo anterior sin visita en relvis o con cierre definitivo  
         AND (r_1.periodo IS NULL OR COALESCE(z.escierredefinitivoinf,'N')='S' OR COALESCE(z.escierredefinitivofor,'N')='S')
         -- periodo actual sin razon ingresada y sin precios
         AND r.razon IS NULL AND COALESCE(hayprecios,'N') = 'N') d
  WHERE rd.periodo = d.periodo and rd.informante = d.informante and rd.formulario = d.formulario and rd.visita = d.visita ;
  --08/01/19: todas las tareas a reltar en el momento de la generación del panel (hasta ahora se insertaban en el momento de preparar la supervisión):
  --14/02/19: las tareas que tuvieron por lo menos una respuesta positiva (o nula) el periodo anterior
  INSERT INTO cvp.relTar(periodo, panel, tarea, encuestador, modalidad, visiblepararelevamiento)
      SELECT p.periodo, p.panel, t.tarea, a.encuestador, x_1.modalidad, x_1.visiblepararelevamiento
        FROM cvp.relpan p 
          INNER JOIN cvp.pantar t ON p.panel= t.panel  
          INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
          INNER JOIN cvp.relvis r_1 ON r_1.periodo = cvp.moverperiodos(p.periodo, -1) AND r_1.panel = p.panel and r_1.tarea = t.tarea
          LEFT JOIN cvp.reltar x_1  ON x_1.periodo = cvp.moverperiodos(p.periodo, -1) AND x_1.panel = p.panel and x_1.tarea = t.tarea
          LEFT JOIN cvp.razones z ON r_1.razon = z.razon           
          LEFT JOIN cvp.reltar x ON x.periodo= p.periodo AND x.panel=p.panel AND x.tarea= t.tarea --pk verificada
        WHERE p.periodo=pperiodo AND p.panel= ppanel AND a.activa = 'S' --tareas activas
              AND x.periodo IS NULL
        GROUP BY p.periodo, p.panel, t.tarea, a.encuestador, x_1.modalidad, x_1.visiblepararelevamiento
        HAVING string_agg(COALESCE(z.escierredefinitivoinf,'N'),'') like '%N%' AND string_agg(COALESCE(z.escierredefinitivofor,'N'),'') like'%N%'
        ORDER BY p.periodo, p.panel, t.tarea;
  --11/08/2020: tareas nuevas (agregadas a pantar)
  INSERT INTO cvp.relTar(periodo, panel, tarea, encuestador)
      SELECT pperiodo as periodo, t.panel, t.tarea, a.encuestador
        FROM cvp.pantar t   
          INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
          LEFT JOIN cvp.reltar x ON x.periodo= pperiodo AND x.panel=t.panel AND x.tarea= t.tarea --pk verificada
        WHERE t.panel= ppanel AND a.activa = 'S' --tareas activas
              AND t.activa = 'S' --paneles-tarea activas
              AND x.periodo IS NULL
        ORDER BY t.panel, t.tarea;

  INSERT INTO cvp.relvis(periodo, informante, visita, formulario, panel, tarea, fechasalida, fechageneracion, encuestador, ultima_visita)
    SELECT p.periodo, r_1.informante, 1, r_1.formulario, r_1.panel, r_1.tarea, pFechasalida, pFechaGeneracionPanel, e.encuestador, true
      FROM cvp.relvis r_1 INNER JOIN cvp.periodos p ON r_1.periodo=p.periodoanterior
        INNER JOIN cvp.formularios f ON f.formulario=r_1.formulario
        --INNER JOIN cvp.tareas t ON t.tarea=r_1.tarea
        LEFT JOIN cvp.reltar e ON e.periodo = p.periodo and e.panel=r_1.panel and e.tarea=r_1.tarea
        LEFT JOIN (SELECT periodo, informante, formulario, max(visita) AS maxvisita
                     FROM cvp.relvis
                     WHERE panel = pPanel
                     GROUP BY  periodo, informante, formulario) v ON v.periodo=r_1.periodo and v.informante = r_1.informante and v.formulario = r_1.formulario
        LEFT JOIN cvp.razones z ON r_1.razon = z.razon         
        LEFT JOIN cvp.relvis r ON r.periodo=p.periodo AND r.informante=r_1.informante AND r.visita=1 AND r.formulario=r_1.formulario 
      WHERE p.periodo=pPeriodo
        AND r_1.panel=pPanel
        AND r_1.visita=maxvisita
        AND COALESCE(z.escierredefinitivoinf,'N')='N'
        AND COALESCE(z.escierredefinitivofor,'N')='N'
        AND f.activo='S'
        AND r.periodo IS NULL;
  INSERT INTO cvp.relvis(periodo, informante, visita, formulario, panel, tarea, fechasalida, fechageneracion, encuestador, ultima_visita)
    SELECT i.altaManualPeriodo, i.informante, 1, fi.formulario, i.altaManualPanel, i.altaManualTarea, 
           pFechasalida, pFechaGeneracionPanel, e.encuestador, true
      FROM cvp.informantes i 
        INNER JOIN cvp.forinf fi ON i.informante=fi.informante 
        INNER JOIN cvp.formularios f ON f.formulario=fi.formulario
        INNER JOIN cvp.periodos p ON p.periodo=i.altaManualPeriodo
        --INNER JOIN cvp.tareas t ON t.tarea=i.altaManualTarea
        LEFT JOIN cvp.reltar e ON e.periodo = p.periodo and e.panel=i.altaManualPanel and e.tarea=i.altaManualTarea
        LEFT JOIN cvp.relvis r ON r.periodo=i.altaManualPeriodo AND r.informante=i.informante AND r.visita=1 AND r.formulario=fi.formulario 
      WHERE p.periodo=pPeriodo
        AND r.periodo IS NULL
        AND f.activo='S'
        AND fi.altaManualPeriodo=pPeriodo
        AND i.altaManualPeriodo=pPeriodo
        AND i.altaManualPanel=pPanel;
        
  INSERT INTO cvp.relinf(periodo, informante, visita)
    SELECT DISTINCT v.periodo, v.informante, v.visita
      FROM cvp.relvis v
      LEFT JOIN cvp.relinf i on v.periodo = i.periodo and v.informante = i.informante and v.visita = i.visita 
    WHERE v.periodo = pPeriodo
      AND v.panel = ppanel
      AND i.periodo IS NULL;

  INSERT INTO cvp.relpantarinf(periodo, informante, visita, panel, tarea)
    SELECT DISTINCT v.periodo, v.informante, v.visita, v.panel, v.tarea
      FROM cvp.relvis v
      LEFT JOIN cvp.relpantarinf i on v.periodo = i.periodo and v.informante = i.informante and v.visita = i.visita and v.panel = i.panel and v.tarea = i.tarea 
    WHERE v.periodo = pPeriodo
      AND v.panel = ppanel
      AND i.periodo IS NULL;

    SELECT 1 INTO vexiste 
    FROM cvp.fechas 
    WHERE fecha = pfechasalida;
    IF vexiste IS DISTINCT FROM 1 THEN
      INSERT INTO cvp.fechas(fecha, visible_planificacion, seleccionada_planificacion)
      VALUES (pfechasalida, 'N','N');
    END IF;

  RETURN NULL;
END
$BODY$;
