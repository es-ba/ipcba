CREATE OR REPLACE VIEW control_rangos AS 
SELECT v.periodo, 
       v.producto, 
       f.nombreproducto, 
       v.informante, 
       i.tipoinformante, 
       v.observacion, 
       v.visita, 
       vi.panel,
       vi.tarea,
       vi.encuestador||':'||pe.apellido as encuestador,
       vi.recepcionista,
       pc.apellido as nombrerecep,
       v.formulario,       
       v.precionormalizado,
       v.comentariosrelpre,
       v.observaciones,
       v.tipoprecio,
       v.cambio,
       c2.impobs,     
       COALESCE(v.precionormalizado_1,co.promobs) AS precioant,
       v.tipoprecio_1  AS tipoprecioant,
       co.antiguedadsinprecio AS antiguedadsinprecioant, 
       SUM (v.precionormalizado / COALESCE(v.precionormalizado_1,co.promobs) * 100 - 100) variac, 
       avgvar.promvar AS promvar, 
       avgvar.desvvar AS desvvar,
       avgprot.promrotativo, 
       avgprot.desvprot AS desvprot,
       vi2.razon::text||':'||COALESCE(co.impobs,' ') as razon_impobs_ant,
       CASE WHEN MIN(pr.periodo) IS NOT NULL THEN 'R' ELSE NULL END AS repregunta
  FROM cvp.relpre_1 v
  JOIN cvp.productos f ON v.producto = f.producto
  JOIN cvp.relvis vi ON v.informante = vi.informante AND v.periodo = vi.periodo AND v.visita = vi.visita AND v.formulario=vi.formulario
  LEFT JOIN cvp.personal pe on vi.encuestador = pe.persona
  LEFT JOIN cvp.personal pc on vi.recepcionista = pc.persona
  LEFT JOIN cvp.CalObs co ON co.periodo = v.periodo_1 AND co.calculo=0 AND co.producto = v.producto AND co.informante = v.informante 
                          AND co.observacion = v.observacion
  LEFT JOIN cvp.CalObs c2 ON c2.periodo = v.periodo AND c2.calculo=0 AND c2.producto = v.producto AND c2.informante = v.informante 
                          AND c2.observacion = v.observacion
  JOIN
      (SELECT avg(va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs) * 100 - 100) promvar , 
              stddev(va2.precionormalizado / COALESCE(va2.precionormalizado_1, co2.promobs) * 100 - 100) desvvar,va2.periodo,va2.producto
         FROM cvp.relpre_1 va2
           LEFT JOIN cvp.calobs co2 ON co2.periodo = va2.periodo_1 AND co2.calculo=0 AND co2.producto = va2.producto 
              AND co2.informante = va2.informante AND co2.observacion = va2.observacion           
         GROUP BY va2.periodo,va2.producto) AS avgvar ON v.periodo=avgvar.periodo AND v.producto=avgvar.producto 
  JOIN cvp.panel_promrotativo avgprot ON v.periodo=avgprot.periodo AND  v.producto=avgprot.producto --AND vi.panel=avgprot.panel
  INNER JOIN cvp.parametros ON unicoregistro=true
  JOIN cvp.informantes i ON v.informante=i.informante 
  LEFT JOIN cvp.prerep pr ON v.periodo=pr.periodo AND v.informante=pr.informante AND v.producto=pr.producto 
  LEFT JOIN cvp.relvis vi2 ON v.informante = vi2.informante AND v.periodo_1 = vi2.periodo AND v.visita = vi2.visita AND v.formulario=vi2.formulario
  WHERE 
        (  
         --FILTRO VARIACION  
           (((v.precionormalizado / COALESCE(v.precionormalizado_1,co.promobs) * 100 - 100)> avgvar.promvar + tamannodesvvar * desvvar ) OR                        
           ( (v.precionormalizado / COALESCE(v.precionormalizado_1,co.promobs) * 100 - 100) IS DISTINCT FROM 0 AND (v.precionormalizado / COALESCE(v.precionormalizado_1,co.promobs) * 100 - 100)< avgvar.promvar - tamannodesvvar *desvvar  ) )  OR

         --FILTRO PRECIO    
           
           ( v.precionormalizado > avgprot.promrotativo+tamannodesvpre*desvprot) OR
           ( v.precionormalizado < avgprot.promrotativo-tamannodesvpre*desvprot )
        ) 
     
  GROUP BY v.periodo, v.producto, f.nombreproducto, v.informante, i.tipoinformante, v.observacion, v.visita, vi.panel, vi.encuestador||':'||pe.apellido, vi.recepcionista, pc.apellido,
           vi.tarea, v.formulario, v.precionormalizado, v.comentariosrelpre, v.observaciones, v.tipoprecio, v.cambio, c2.impobs,  v.precionormalizado_1, co.promobs , v.tipoprecio_1, 
           co.antiguedadsinprecio, avgvar.promvar, avgvar.desvvar, avgprot.promrotativo, 
           avgprot.desvprot, co.impobs, vi2.razon
  ORDER BY v.periodo, v.producto,vi.panel, vi.tarea, v.informante;

GRANT SELECT ON TABLE control_rangos TO cvp_usuarios;
