CREATE OR REPLACE VIEW informantes_inactivos AS
SELECT a.informante,
    a.visita,
    a.formulario,
    a.periodonegativo
   FROM ( SELECT r.informante,
            r.visita,
            r.formulario,
            max(r.periodo) AS periodonegativo
           FROM cvp.relvis r
             JOIN cvp.razones z ON r.razon = z.razon
             --JOIN cvp.formularios f ON r.formulario = f.formulario
          WHERE (z.escierredefinitivoinf = 'S' OR z.escierredefinitivofor = 'S') AND /*.activo = 'S' AND*/ r.ultima_visita
          GROUP BY r.informante, r.visita, r.formulario
          ORDER BY r.informante, r.visita, r.formulario) a
     LEFT JOIN ( SELECT r.informante,
                   r.formulario,
                   max(r.periodo) AS periodopositivo
                   FROM cvp.relvis r
                   JOIN cvp.razones z ON r.razon = z.razon
                   --JOIN cvp.formularios f ON r.formulario = f.formulario
                   WHERE Not (z.escierredefinitivoinf = 'S' OR z.escierredefinitivofor = 'S') AND /*f.activo = 'S' AND*/ r.ultima_visita
                   GROUP BY r.informante, r.formulario
                   ORDER BY r.informante, r.formulario) b ON a.informante = b.informante AND a.formulario = b.formulario
   WHERE COALESCE(b.periodopositivo, 'a0000m00') < a.periodonegativo;
 

GRANT SELECT ON TABLE informantes_inactivos TO cvp_administrador;
