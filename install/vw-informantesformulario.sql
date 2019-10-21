create or replace view informantesformulario as
SELECT periodo, formulario, nombreformulario,
  SUM(CASE WHEN activos LIKE '%S%' THEN 1 ELSE 0 END)::integer as cantactivos, --cON por lo menos un formulario cON razon no cierre definitivo o sin razon (no ingresada aún) 
  SUM(CASE WHEN altas LIKE '%S%' THEN 1 ELSE 0 END)::integer as cantaltas, --hay alta de por lo menos un formulario, cON respecto al periodo anterior, independientemente de las razones en el periodo actual
  SUM(CASE WHEN bajas LIKE '%S%' THEN 1 ELSE 0 END)::integer as cantbajas --por lo menos un formulario tiene razon de cierre definitivo informante
  FROM (SELECT periodo, informante, formulario, nombreformulario, 
          string_agg(distinct activos, ',') activos, string_agg(distinct altas, ',') altas, string_agg(distinct bajas, ',') bajas
          FROM (SELECT r.periodo, r.informante, r.visita, r.formulario, f.nombreformulario, r.razon,
                       r_1.periodo periodoant, 
                       CASE WHEN coalesce(z.escierredefinitivoinf,'N') = 'N' AND coalesce(z.escierredefinitivofor,'N') = 'N' THEN 'S' ELSE 'N' END as activos, 
                       CASE WHEN r_1.periodo is null AND r.periodo is not null THEN 'S' ELSE 'N' END as altas, 
                       CASE WHEN coalesce(z.escierredefinitivoinf,'N') = 'S' OR coalesce(z.escierredefinitivofor,'N') = 'S' THEN 'S' ELSE 'N' END as bajas 
                  FROM cvp.relvis r
                  LEFT JOIN cvp.informantes i ON r.informante = i.informante
                  LEFT JOIN cvp.periodos p ON r.periodo = p.periodo
                  LEFT JOIN cvp.relvis r_1 ON p.periodoanterior = r_1.periodo AND r.formulario = r_1.formulario AND r.visita = r_1.visita AND r.informante = r_1.informante 
                  LEFT JOIN cvp.formularios f ON r.formulario = f.formulario
                  LEFT JOIN cvp.razones z ON r.razon = z.razon
                  WHERE r.visita = 1
        ) x 
        GROUP BY periodo, informante, formulario, nombreformulario
        ORDER BY periodo, informante, formulario, nombreformulario
        ) g
  GROUP BY periodo, formulario, nombreformulario
  ORDER BY periodo, formulario, nombreformulario;

GRANT SELECT ON TABLE informantesformulario TO cvp_usuarios;
GRANT SELECT ON TABLE informantesformulario TO cvp_recepcionista;
