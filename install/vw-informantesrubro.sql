create or replace view informantesrubro as
SELECT periodo, rubro, nombrerubro,
  SUM(CASE WHEN activos LIKE '%S%' THEN 1 ELSE 0 END)::integer as cantactivos, --con por lo menos un formulario con razon no cierre definitivo o sin razon (no ingresada aún) 
  SUM(CASE WHEN altas LIKE '%S%' AND altas NOT LIKE '%N%' THEN 1 ELSE 0 END)::integer as cantaltas, --hay alta de TODOS los formularios, con respecto al periodo anterior, independientemente de las razones en el periodo actual
  SUM(CASE WHEN bajas LIKE '%S%' AND bajas NOT LIKE '%N%' THEN 1 ELSE 0 END)::integer as cantbajas --todos los formularios tienen razon de cierre definitivo informante
  FROM (SELECT periodo, informante, rubro, nombrerubro, string_agg(distinct activos, ',') activos, string_agg(distinct altas, ',') altas, string_agg(distinct bajas, ',') bajas
          FROM (SELECT r.periodo, r.informante, r.visita, r.formulario, i.rubro, u.nombrerubro, r.razon, r_1.periodo periodoant, 
                       CASE WHEN coalesce(z.escierredefinitivoinf,'N') = 'N' AND coalesce(z.escierredefinitivofor,'N') = 'N' THEN 'S' ELSE 'N' END as activos, 
                       CASE WHEN r_1.periodo is null AND r.periodo is not null THEN 'S' ELSE 'N' END as altas, 
                       CASE WHEN coalesce(z.escierredefinitivoinf,'N') = 'S' OR coalesce(z.escierredefinitivofor,'N') = 'S' THEN 'S' ELSE 'N' END as bajas 
                  FROM cvp.relvis r
                  LEFT JOIN cvp.periodos p ON r.periodo = p.periodo
                  LEFT JOIN cvp.relvis r_1 ON p.periodoanterior = r_1.periodo AND r.formulario = r_1.formulario AND r.visita = r_1.visita AND r.informante = r_1.informante 
                  LEFT JOIN cvp.informantes i ON r.informante = i.informante
                  LEFT JOIN cvp.rubros u ON i.rubro = u.rubro
                  LEFT JOIN cvp.razones z ON r.razon = z.razon
                  WHERE r.visita = 1
                ) x 
          GROUP BY periodo, informante, rubro, nombrerubro
          ORDER BY periodo, informante, rubro, nombrerubro
        ) g
  GROUP BY periodo, rubro, nombrerubro
  ORDER BY periodo, rubro, nombrerubro;

GRANT SELECT ON TABLE informantesrubro TO cvp_usuarios;
GRANT SELECT ON TABLE informantesrubro TO cvp_recepcionista;
