set search_path = cvp;
CREATE OR REPLACE VIEW informantes_inactivos AS
SELECT a.informante, a.visita, a.formulario, periodoNegativo FROM 
      (SELECT r.informante, r.visita, r.formulario, max(periodo) periodoNegativo
         FROM relvis r 
         JOIN razones z on r.razon = z.razon
         JOIN formularios f on r.formulario = f.formulario
         WHERE z.escierredefinitivoinf = 'S' and f.activo ='S' and r.ultima_visita
         GROUP BY r.informante, r.visita, r.formulario
         ORDER BY r.informante, r.visita, r.formulario
      ) a
LEFT JOIN
      (SELECT r.informante, r.formulario, max(periodo) periodoPositivo
         FROM relvis r 
         JOIN razones z on r.razon = z.razon
         JOIN formularios f on r.formulario = f.formulario
         WHERE z.escierredefinitivoinf = 'N' and f.activo ='S' and r.ultima_visita
         GROUP BY r.informante, r.formulario
         ORDER BY r.informante, r.formulario
       ) b
ON a.informante = b.informante and a.formulario = b.formulario
WHERE coalesce(b.periodoPositivo,'a0000m00') < PeriodoNegativo; 
