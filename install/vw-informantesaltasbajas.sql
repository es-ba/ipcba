create or replace view informantesaltasbajas as
SELECT x.periodoanterior, x.informante, x.visita, x.rubro, x.nombrerubro, x.formulario, x.nombreformulario, x.panelanterior, x.tareaanterior, x.razonanterior,
x.nombrerazonanterior,x.periodo,x.panel,x.tarea,x.razon, x.nombrerazon, x.tipo, x.distrito, x.fraccion_ant, ca.cantformactivos 
FROM (
SELECT r_1.periodo periodoanterior, r_1.informante informanteanterior, i.rubro, ru.nombrerubro, r_1.formulario formularioanterior, f.nombreformulario, r_1.visita visitaanterior, 
       r_1.panel panelanterior, r_1.tarea tareaanterior, r_1.razon razonanterior, zr_1.nombrerazon nombrerazonanterior,
       r.periodo, r.informante, r.formulario, r.visita, r.panel, r.tarea, r.razon, zr.nombrerazon,
       CASE WHEN r_1.periodo is null AND r.periodo is not null AND (zr.escierredefinitivoinf = 'S' or zr.escierredefinitivofor = 'S') THEN 'Alta-Baja en '||r.periodo
            WHEN zr.escierredefinitivoinf = 'S' or zr.escierredefinitivofor = 'S' THEN 'Baja en '||r.periodo 
            WHEN r_1.periodo is null AND r.periodo is not null THEN 'Alta'
            WHEN zr_1.escierredefinitivoinf = 'S' or zr_1.escierredefinitivofor = 'S' THEN 'Baja en '||r_1.periodo
            WHEN r_1.razon is null THEN 'No ingresado '||r_1.periodo
            WHEN r.razon is null THEN 'No ingresado '||r.periodo
            ELSE 'Continuo' END as tipo, i.distrito, i.fraccion_ant
  FROM cvp.relvis r 
  LEFT JOIN cvp.periodos p ON p.periodo = r.periodo 
  LEFT JOIN cvp.relvis r_1 ON r_1.periodo = p.periodoanterior AND r.informante = r_1.informante AND r.formulario = r_1.formulario AND r.visita = r_1.visita
  LEFT JOIN cvp.razones zr ON r.razon = zr.razon 
  LEFT JOIN cvp.razones zr_1 ON r_1.razon = zr_1.razon
  LEFT JOIN cvp.informantes i ON r.informante = i.informante   
  LEFT JOIN cvp.rubros ru ON i.rubro = ru.rubro
  LEFT JOIN cvp.formularios f ON r_1.formulario = f.formulario  
UNION
SELECT r_1.periodo periodoanterior, r_1.informante informanteanterior, i.rubro, ru.nombrerubro, r_1.formulario formularioanterior, f.nombreformulario, r_1.visita visitaanterior, 
       r_1.panel panelanterior, r_1.tarea tareaanterior, r_1.razon razONanterior, zr_1.nombrerazon nombrerazONanterior,
       r.periodo, r.informante, r.formulario, r.visita, r.panel, r.tarea, r.razon, zr.nombrerazon,
       CASE WHEN zr.escierredefinitivoinf = 'S' or zr.escierredefinitivofor = 'S' THEN 'Baja en '||r.periodo
            WHEN r_1.periodo is null AND r.periodo is not null THEN 'Alta'
            WHEN zr_1.escierredefinitivoinf = 'S' or zr_1.escierredefinitivofor = 'S' THEN 'Baja en '||r_1.periodo 
            WHEN r_1.razon is null THEN 'No ingresado '||r_1.periodo
            WHEN r.razon is null THEN 'No ingresado '||r.periodo
            ELSE 'Continuo' END as tipo, i.distrito, i.fraccion_ant
  FROM cvp.relvis r_1 
  LEFT JOIN cvp.periodos p ON p.periodoanterior = r_1.periodo 
  LEFT JOIN cvp.relvis r ON r.periodo = p.periodo AND r.informante = r_1.informante AND r.formulario = r_1.formulario AND r.visita = r_1.visita
  LEFT JOIN cvp.razones zr ON r.razon = zr.razon 
  LEFT JOIN cvp.razones zr_1 ON r_1.razon = zr_1.razon 
  LEFT JOIN cvp.informantes i ON r.informante = i.informante   
  LEFT JOIN cvp.rubros ru ON i.rubro = ru.rubro
  LEFT JOIN cvp.formularios f ON r_1.formulario = f.formulario  
) as X 
LEFT JOIN (SELECT periodo, informante, visita, count(*)::integer cantformactivos 
             FROM cvp.relvis v 
             LEFT JOIN cvp.razones s ON v.razon = s.razon 
             WHERE not (s.escierredefinitivoinf = 'S' or s.escierredefinitivofor = 'S')
             GROUP BY periodo, informante, visita) ca ON X.periodo = ca.periodo AND X.informante = ca.informante AND X.visita = ca.visita
WHERE tipo <> 'Continuo' and tipo <> ('No ingresado '||x.periodo)::text
ORDER BY periodoanterior, informanteanterior, visitaanterior, formularioanterior;

GRANT SELECT ON TABLE informantesaltasbajas TO cvp_usuarios;
GRANT SELECT ON TABLE informantesaltasbajas TO cvp_recepcionista;
