CREATE TABLE cvp.relinf_temp
(
    periodo character varying(11) COLLATE pg_catalog."default" NOT NULL,
    informante integer NOT NULL,
    visita integer NOT NULL,
    observaciones text COLLATE pg_catalog."default",
    modi_usu character varying(30) COLLATE pg_catalog."default",
    modi_fec timestamp without time zone,
    modi_ope character varying(1) COLLATE pg_catalog."default",
    panel integer NOT NULL,
    tarea integer NOT NULL,
    CONSTRAINT relinf_temp_pkey PRIMARY KEY (periodo, informante, visita, panel, tarea),
    CONSTRAINT relinf_temp_inf_fkey FOREIGN KEY (informante)
        REFERENCES cvp.informantes (informante) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT relinf_temp_per_fkey FOREIGN KEY (periodo)
        REFERENCES cvp.periodos (periodo) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
TABLESPACE pg_default;

ALTER TABLE cvp.relinf_temp
    OWNER to cvpowner;
	
INSERT INTO cvp.relinf_temp SELECT * FROM cvp.relinf;

ALTER TABLE cvp.relinf disable trigger relinf_abi_trg;

DELETE FROM cvp.relinf;
ALTER TABLE cvp.relinf DROP COLUMN panel;
ALTER TABLE cvp.relinf DROP COLUMN tarea;

--ALTER TABLE cvp.relinf DROP CONSTRAINT relinf_pkey;
ALTER TABLE cvp.relinf ADD PRIMARY KEY (periodo, informante, visita);

CREATE OR REPLACE FUNCTION cvp.hisc_relinf_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','periodo','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||new.periodo,new.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_number)
             VALUES ('cvp','RelInf','informante','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.informante),new.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_number)
             VALUES ('cvp','RelInf','visita','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.visita),new.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','observaciones','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.observaciones),new.observaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','modi_usu','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_datetime)
             VALUES ('cvp','RelInf','modi_fec','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,new_text)
             VALUES ('cvp','RelInf','modi_ope','I',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
      END IF;
      IF v_operacion='U' THEN          
        IF new.periodo IS DISTINCT FROM old.periodo THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','periodo','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.periodo)||'->'||comun.a_texto(new.periodo),old.periodo,new.periodo);
        END IF;    
        IF new.informante IS DISTINCT FROM old.informante THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_number,new_number)
                 VALUES ('cvp','RelInf','informante','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.informante)||'->'||comun.a_texto(new.informante),old.informante,new.informante);
        END IF;    
        IF new.visita IS DISTINCT FROM old.visita THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_number,new_number)
                 VALUES ('cvp','RelInf','visita','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.visita)||'->'||comun.a_texto(new.visita),old.visita,new.visita);
        END IF;    
        IF new.observaciones IS DISTINCT FROM old.observaciones THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','observaciones','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,old.observaciones||'->'||new.observaciones,old.observaciones,new.observaciones);
        END IF;    
        IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','modi_usu','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
        END IF;    
        IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime,new_datetime)
                 VALUES ('cvp','RelInf','modi_fec','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
        END IF;    
        IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
            INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text,new_text)
                 VALUES ('cvp','RelInf','modi_ope','U',new.periodo||'|'||new.informante||'|'||new.visita,new.periodo,new.informante,new.visita,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
        END IF;
      END IF;
      IF v_operacion='D' THEN        
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','periodo','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.periodo),old.periodo);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','informante','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.informante),old.informante);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','visita','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.visita),old.visita);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','observaciones','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||old.observaciones,old.observaciones);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','modi_usu','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_datetime)
             VALUES ('cvp','RelInf','modi_fec','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
        INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,pk_number_3,change_value,old_text)
             VALUES ('cvp','RelInf','modi_ope','D',old.periodo||'|'||old.informante||'|'||old.visita,old.periodo,old.informante,old.visita,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;

ALTER FUNCTION cvp.hisc_relinf_trg()
    OWNER TO cvpowner;

INSERT INTO cvp.relinf 
SELECT periodo, informante, visita, 
	string_agg(observaciones,' | ' order by panel, tarea) observaciones
from cvp.relinf_temp 
group by periodo, informante, visita;


ALTER TABLE cvp.relinf enable trigger relinf_abi_trg;


CREATE OR REPLACE FUNCTION cvp.generar_panel(
	pperiodo text,
	ppanel integer,
	pfechasalida date,
	pfechageneracionpanel timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER 
AS $BODY$
DECLARE
  f_hoy date= current_date;
BEGIN
  /*
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
  INSERT INTO cvp.relTar(periodo, panel, tarea, encuestador)
      SELECT p.periodo, p.panel, t.tarea, a.encuestador
        FROM cvp.relpan p 
          INNER JOIN cvp.pantar t ON p.panel= t.panel  
          INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
          INNER JOIN cvp.relvis r_1 ON r_1.periodo = cvp.moverperiodos(p.periodo, -1) AND r_1.panel = p.panel and r_1.tarea = t.tarea
          LEFT JOIN cvp.razones z ON r_1.razon = z.razon           
          LEFT JOIN cvp.reltar x ON x.periodo= p.periodo AND x.panel=p.panel AND x.tarea= t.tarea --pk verificada
        WHERE p.periodo=pperiodo AND p.panel= ppanel AND a.activa = 'S' --tareas activas
              AND x.periodo IS NULL
        GROUP BY p.periodo, p.panel, t.tarea, a.encuestador
        HAVING string_agg(COALESCE(z.escierredefinitivoinf,'N'),'') like '%N%' AND string_agg(COALESCE(z.escierredefinitivofor,'N'),'') like'%N%'
        ORDER BY p.periodo, p.panel, t.tarea;

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

  --Si se modifica el encuestador de una tarea, hay que volver a generar el panel que aún no haya salido,
  --se cambiarán los encuestadores de los paneles siguientes para las tareas correspondientes
  UPDATE cvp.reltar r SET encuestador= s.encuestador
        FROM (SELECT p.periodo, p.panel, t.tarea, a.encuestador 
                FROM cvp.relpan p 
                  INNER JOIN cvp.pantar t ON p.panel= t.panel  
                  INNER JOIN cvp.tareas a ON a.tarea= t.tarea -- pk verificada
                  LEFT JOIN cvp.reltar x ON x.periodo= p.periodo AND x.panel=p.panel AND x.tarea= t.tarea --pk verificada
                  WHERE p.periodo=pperiodo AND p.panel= ppanel AND p.fechasalida > f_hoy AND a.activa = 'S' AND   --tareas activas
                        x.periodo IS NOT NULL
              ) as s
        WHERE r.periodo=s.periodo AND r.panel= s.panel and r.tarea=s.tarea AND s.encuestador IS DISTINCT FROM r.encuestador ;

  --Si se modifica la fecha de salida de un panel, hay que volver a generar el panel
  UPDATE cvp.relvis SET fechasalida=pfechasalida
    WHERE periodo=pPeriodo AND panel=pPanel AND razon IS NULL AND fechasalida IS DISTINCT FROM pFechaSalida;
  RETURN NULL;
END
$BODY$;

-------------------------------------------------------------
--ALTER TABLE cvp.informantes ADD COLUMN web text;
--ALTER TABLE cvp.informantes ADD COLUMN email text;


ALTER TABLE cvp.relpan ADD COLUMN fechasalidadesde date;
ALTER TABLE cvp.relpan ADD COLUMN fechasalidahasta date;

ALTER TABLE his.relpan ADD COLUMN fechasalidadesde date;
ALTER TABLE his.relpan ADD COLUMN fechasalidahasta date;
	
CREATE OR REPLACE FUNCTION cvp.hisc_relpan_trg()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    VOLATILE NOT LEAKPROOF SECURITY DEFINER
AS $BODY$
      DECLARE
        v_operacion text:=substr(TG_OP,1,1);
      BEGIN
        
      IF v_operacion='I' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','relpan','periodo','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.periodo),new.periodo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_number)
                     VALUES ('cvp','relpan','panel','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.panel),new.panel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_datetime)
                     VALUES ('cvp','relpan','fechasalida','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.fechasalida),new.fechasalida);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_datetime)
                     VALUES ('cvp','relpan','fechageneracionpanel','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.fechageneracionpanel),new.fechageneracionpanel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','relpan','modi_usu','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.modi_usu),new.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_datetime)
                     VALUES ('cvp','relpan','modi_fec','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.modi_fec),new.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','relpan','modi_ope','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.modi_ope),new.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_text)
                     VALUES ('cvp','relpan','periodoparapanelrotativo','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.periodoparapanelrotativo),new.periodoparapanelrotativo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_datetime)
                     VALUES ('cvp','relpan','generacionsupervisiones','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.generacionsupervisiones),new.generacionsupervisiones);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_datetime)
                     VALUES ('cvp','relpan','fechasalidadesde','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.fechasalidadesde),new.fechasalidadesde);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,new_datetime)
                     VALUES ('cvp','relpan','fechasalidahasta','I',new.periodo||'|'||new.panel,new.periodo,new.panel,'I:'||comun.a_texto(new.fechasalidahasta),new.fechasalidahasta);
      END IF;
      IF v_operacion='U' THEN
            
            IF new.periodo IS DISTINCT FROM old.periodo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','relpan','periodo','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.periodo)||'->'||comun.a_texto(new.periodo),old.periodo,new.periodo);
            END IF;    
            IF new.panel IS DISTINCT FROM old.panel THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number,new_number)
                     VALUES ('cvp','relpan','panel','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.panel)||'->'||comun.a_texto(new.panel),old.panel,new.panel);
            END IF;    
            IF new.fechasalida IS DISTINCT FROM old.fechasalida THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','relpan','fechasalida','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.fechasalida)||'->'||comun.a_texto(new.fechasalida),old.fechasalida,new.fechasalida);
            END IF;    
            IF new.fechageneracionpanel IS DISTINCT FROM old.fechageneracionpanel THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','relpan','fechageneracionpanel','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.fechageneracionpanel)||'->'||comun.a_texto(new.fechageneracionpanel),old.fechageneracionpanel,new.fechageneracionpanel);
            END IF;    
            IF new.modi_usu IS DISTINCT FROM old.modi_usu THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','relpan','modi_usu','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.modi_usu)||'->'||comun.a_texto(new.modi_usu),old.modi_usu,new.modi_usu);
            END IF;    
            IF new.modi_fec IS DISTINCT FROM old.modi_fec THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','relpan','modi_fec','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.modi_fec)||'->'||comun.a_texto(new.modi_fec),old.modi_fec,new.modi_fec);
            END IF;    
            IF new.modi_ope IS DISTINCT FROM old.modi_ope THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','relpan','modi_ope','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.modi_ope)||'->'||comun.a_texto(new.modi_ope),old.modi_ope,new.modi_ope);
            END IF;    
            IF new.periodoparapanelrotativo IS DISTINCT FROM old.periodoparapanelrotativo THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text,new_text)
                     VALUES ('cvp','relpan','periodoparapanelrotativo','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.periodoparapanelrotativo)||'->'||comun.a_texto(new.periodoparapanelrotativo),old.periodoparapanelrotativo,new.periodoparapanelrotativo);
            END IF;
            IF new.generacionsupervisiones IS DISTINCT FROM old.generacionsupervisiones THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','relpan','generacionsupervisiones','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.generacionsupervisiones)||'->'||comun.a_texto(new.generacionsupervisiones),old.generacionsupervisiones,new.generacionsupervisiones);
            END IF;    
            IF new.fechasalidadesde IS DISTINCT FROM old.fechasalidadesde THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','relpan','fechasalidadesde','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.fechasalidadesde)||'->'||comun.a_texto(new.fechasalidadesde),old.fechasalidadesde,new.fechasalidadesde);
            END IF;    
            IF new.fechasalidahasta IS DISTINCT FROM old.fechasalidahasta THEN
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime,new_datetime)
                     VALUES ('cvp','relpan','fechasalidahasta','U',new.periodo||'|'||new.panel,new.periodo,new.panel,comun.A_TEXTO(old.fechasalidahasta)||'->'||comun.a_texto(new.fechasalidahasta),old.fechasalidahasta,new.fechasalidahasta);
            END IF;    
      END IF;
      IF v_operacion='D' THEN
        
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','relpan','periodo','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.periodo),old.periodo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_number)
                     VALUES ('cvp','relpan','panel','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.panel),old.panel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime)
                     VALUES ('cvp','relpan','fechasalida','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.fechasalida),old.fechasalida);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime)
                     VALUES ('cvp','relpan','fechageneracionpanel','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.fechageneracionpanel),old.fechageneracionpanel);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','relpan','modi_usu','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.modi_usu),old.modi_usu);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime)
                     VALUES ('cvp','relpan','modi_fec','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.modi_fec),old.modi_fec);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','relpan','modi_ope','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.modi_ope),old.modi_ope);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_text)
                     VALUES ('cvp','relpan','periodoparapanelrotativo','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.periodoparapanelrotativo),old.periodoparapanelrotativo);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime)
                     VALUES ('cvp','relpan','generacionsupervisiones','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.generacionsupervisiones),old.generacionsupervisiones);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime)
                     VALUES ('cvp','relpan','fechasalidadesde','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.fechasalidadesde),old.fechasalidadesde);
                INSERT INTO his.his_campos_cvp (esquema,tabla,campo,operacion,concated_pk,pk_text_1,pk_number_2,change_value,old_datetime)
                     VALUES ('cvp','relpan','fechasalidahasta','D',old.periodo||'|'||old.panel,old.periodo,old.panel,'D:'||comun.a_texto(old.fechasalidahasta),old.fechasalidahasta);
      END IF;
      
        IF v_operacion<>'D' THEN
          RETURN new;
        ELSE
          RETURN old;  
        END IF;
      END;
     $BODY$;
-------------------------------------------------------------
set search_path = cvp;
set role cvpowner;

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
   (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text AS contacto, 
    c.conjuntomuestral, c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email
   FROM cvp.control_hojas_ruta c 
   LEFT JOIN cvp.tareas t on c.tarea = t.tarea
   LEFT JOIN cvp.personal p on p.persona = t.encuestador 
   LEFT JOIN cvp.informantes i ON c.informante = i.informante
   LEFT JOIN cvp.rubros r ON i.rubro = r.rubro
   LEFT JOIN (SELECT informante, visita, max(periodo) AS maxperiodoinformado, min(periodo) AS minperiodoinformado
                FROM cvp.control_hojas_ruta
                WHERE control_hojas_ruta.razon = 1
                GROUP BY informante, visita) a ON c.informante = a.informante AND c.visita = a.visita
  GROUP BY c.periodo, c.panel, c.tarea, c.informante, i.tipoinformante, t.encuestador||':'||p.nombre||' '||p.apellido, c.visita, c.nombreinformante, c.direccion, 
    (COALESCE(i.contacto, ''::character varying)::text || ' '::text) || COALESCE(i.telcontacto, ''::character varying)::text, c.conjuntomuestral, 
    c.ordenhdr, i.distrito, i.fraccion_ant, i.comuna, i.fraccion, i.radio, i.manzana, i.depto, i.barrio, i.rubro, r.nombrerubro, a.maxperiodoinformado, a.minperiodoinformado, c.fechasalida, i.web, i.email;


