ALTER TABLE cvp.relinf_temp SET SCHEMA mant;

SET search_path = cvp;
ALTER TABLE parametros ADD COLUMN permitir_cualquier_cambio_panel_tarea BOOLEAN default false;

CREATE OR REPLACE FUNCTION cambio_panel_tarea_trg()
  RETURNS trigger AS
$BODY$

DECLARE
 vgenerado integer:=null;
 vmaxperiododesde character varying(11);
 vmaxrazon integer;
 vpermitido boolean;
BEGIN
IF old.panel <> new.panel OR old.tarea <> new.tarea THEN --para que funcione al "importar" registros ya existentes
	--el panel al que me quiero mover debe estar generado
	SELECT distinct 1 INTO vgenerado
	FROM cvp.relvis 
	WHERE periodo = new.periodo and panel = new.panel;
	IF vgenerado is distinct from 1 THEN  
		RAISE EXCEPTION 'Falta generar el panel: % (periodo %)',new.panel, new.periodo;
		RETURN NULL;
	ELSE
		--el panel del que me quiero mover debe ser el último generado y puede tener (o no) formularios ingresados dependiendo de parametos.permitir_cualquier_cambio_panel_tarea
		SELECT maxperiodo, maxrazon, permitir_cualquier_cambio_panel_tarea INTO vmaxperiododesde, vmaxrazon, vpermitido
		FROM (SELECT MAX(periodo) maxperiodo FROM cvp.relvis WHERE panel = old.panel) v
		INNER JOIN cvp.parametros ON unicoregistro,
		LATERAL (SELECT MAX(razon) maxrazon FROM cvp.relvis WHERE periodo = maxperiodo AND panel = old.panel) r;
    	IF new.periodo is distinct from vmaxperiododesde THEN
			RAISE EXCEPTION '% No es el último periodo generado para el panel: %',new.periodo, old.panel;
			RETURN NULL;
		ELSE
			IF vmaxrazon is not null AND NOT vpermitido THEN
				RAISE EXCEPTION 'Hay formularios ingresados en el periodo: % panel: %',new.periodo, old.panel;
				RETURN NULL;
			END IF;
		END IF;
	END IF;
END IF;
RETURN NEW;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION verificar_cargado_dm()
    RETURNS trigger
    LANGUAGE 'plpgsql' VOLATILE
AS $BODY$
DECLARE
vtabla       varchar(100);
BEGIN
vtabla= TG_TABLE_NAME;
CASE
    WHEN vtabla='relvis' THEN
        IF TG_OP <> 'INSERT' THEN
            perform cvp.controlar_estado_carga(old.periodo, old.panel, old.tarea, old.informante);
        END IF;
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' AND (new.periodo, new.panel, new.tarea, new.informante)<>(old.periodo, old.panel, old.tarea, old.informante) THEN
            perform cvp.controlar_estado_carga(new.periodo, new.panel, new.tarea, new.informante);
        END IF;
    WHEN vtabla='relpre' THEN
        IF TG_OP <> 'INSERT' THEN
            perform cvp.controlar_estado_carga(old.periodo, null, null, old.informante, old.visita, old.formulario);
        END IF;
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' AND (new.periodo, new.formulario)<>(old.periodo, old.formulario) THEN
            perform cvp.controlar_estado_carga(new.periodo, null, null, new.informante, new.visita, new.formulario);
        END IF;
    WHEN vtabla='relatr' THEN
        IF TG_OP <> 'INSERT' THEN
            perform cvp.controlar_estado_carga(old.periodo, null, null, old.informante, old.visita, null, old.producto, old.observacion);
        END IF;
        IF TG_OP = 'INSERT' THEN
            perform cvp.controlar_estado_carga(new.periodo, null, null, new.informante, new.visita, null, new.producto, new.observacion);
        END IF;
END CASE;
IF TG_OP='DELETE' THEN
   RETURN OLD;
ELSE  
   RETURN NEW;
END IF;
END;
$BODY$;
-------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generar_panel(
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

  RETURN NULL;
END
$BODY$;
  
  