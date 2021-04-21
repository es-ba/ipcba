CREATE OR REPLACE VIEW controlvigencias as
 SELECT *
   FROM (SELECT a.periodo,
            a.informante,
            a.producto,
            u.nombreproducto,
            a.observacion,
            d.valor,
            COALESCE(comun.cuantos_dias_mes(a.periodo::text, d.valor::text), 0) AS cantdias,
            date_part('day'::text, ((((substr(moverperiodos(a.periodo::text, 1), 2, 4) || '-'::text) || substr(moverperiodos(a.periodo::text, 1), 7, 2)) || '-01'::text)::date) - '1 day'::interval) AS ultimodiadelmes,
            count(DISTINCT a.visita)::integer AS visitas,
            sum(a.valor::numeric)::integer AS vigencias,
            string_agg((COALESCE(p.comentariosrelpre, ' '::text) || ' '::text) || COALESCE(p.observaciones, ' '::text), ' '::text) AS comentarios
           FROM relvis r
             LEFT JOIN relpre p ON r.periodo::text = p.periodo::text AND r.informante = p.informante AND r.visita = p.visita AND r.formulario = p.formulario
             LEFT JOIN relatr a ON p.periodo::text = a.periodo::text AND p.producto::text = a.producto::text AND p.observacion = a.observacion AND p.informante = a.informante AND p.visita = a.visita
             LEFT JOIN (SELECT *
                          FROM relatr
                          WHERE atributo = 196) d 
                        ON a.periodo = d.periodo AND a.producto = d.producto AND a.informante = d.informante AND a.observacion = d.observacion AND a.visita = d.visita
             LEFT JOIN atributos t ON a.atributo = t.atributo
             LEFT JOIN productos u ON a.producto = u.producto
          WHERE t.es_vigencia AND r.razon = 1
          GROUP BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion, d.valor, 
          (COALESCE(comun.cuantos_dias_mes(a.periodo::text, d.valor::text), 0)), 
          (date_part('day'::text, ((((substr(moverperiodos(a.periodo::text, 1), 2, 4) || '-'::text) || substr(moverperiodos(a.periodo::text, 1), 7, 2)) || '-01'::text)::date) - '1 day'::interval))
          ORDER BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion) f
  WHERE NOT (f.visitas = 1 OR f.ultimodiadelmes = f.vigencias OR f.cantdias = f.vigencias);

GRANT SELECT ON TABLE controlvigencias TO cvp_usuarios;
GRANT SELECT ON TABLE controlvigencias TO cvp_administrador;

