CREATE OR REPLACE VIEW informantesrazon AS
  SELECT COALESCE(q.periodo, b.periodo) periodo, COALESCE(q.razones, b.razones) razon, 
      COALESCE(q.nombresrazones, b.nombresrazones) nombrerazon, informantes cantinformantes, formularios cantformularios
    FROM (
      SELECT periodo, razones, nombresrazones, COUNT(*) informantes 
        FROM (
          SELECT periodo, informante, STRING_AGG(razon::text, '~' ORDER BY razon) razones, 
              STRING_AGG(nombrerazon::text, '~' ORDER BY razon) nombresrazones 
            FROM (
              SELECT DISTINCT r.periodo, r.informante, r.razon, z.nombrerazon
                FROM relvis r 
                JOIN razones z ON r.razon = z.razon
                WHERE r.visita = 1
            ) x
        GROUP BY periodo, informante
        ) w
      GROUP BY 1,2,3
      ) q
    FULL OUTER JOIN (
      SELECT periodo, razon::text AS razones, nombrerazon AS nombresrazones, COUNT(DISTINCT (informante, formulario)) formularios 
        FROM (
          SELECT r.periodo, r.informante, r.formulario, r.razon, z.nombrerazon
            FROM relvis r 
            JOIN razones z ON r.razon = z.razon
            WHERE r.visita = 1
        ) x
      GROUP BY 1,2,3
      ) b ON q.periodo = b.periodo AND q.razones = b.razones AND q.nombresrazones = b.nombresrazones
  ORDER BY 1,split_part(COALESCE(q.razones,b.razones),'~',1)::integer, 
    CASE WHEN split_part(COALESCE(q.razones,b.razones),'~',2) = '' 
      THEN NULL ELSE split_part(COALESCE(q.razones,b.razones),'~',2) 
    END ::integer NULLS FIRST, COALESCE(q.nombresrazones, b.nombresrazones);

GRANT SELECT ON TABLE informantesrazon TO cvp_usuarios;
GRANT SELECT ON TABLE informantesrazon TO cvp_recepcionista;

