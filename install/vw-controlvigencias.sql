CREATE OR REPLACE VIEW controlvigencias as
SELECT * 
  FROM (SELECT a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion, d.valor, coalesce(comun.cuantos_dias_mes(a.periodo,d.valor),0) as cantdias,
          extract(day from (substr(cvp.moverperiodos(a.periodo,1),2,4)||'-'||substr(cvp.moverperiodos(a.periodo,1),7,2)||'-01')::date  - '1 day'::interval) ultimodiadelmes,
          Count(DISTINCT a.visita)::integer visitas, Sum(a.valor::decimal)::integer vigencias, 
          string_agg(coalesce(p.comentariosrelpre,' ')||' '||coalesce(p.observaciones,' '),' ') as comentarios
            FROM cvp.relvis r 
            LEFT JOIN cvp.relpre p on r.periodo = p.periodo and r.informante = p.informante and r.visita = p.visita and r.formulario = p.formulario
            LEFT JOIN cvp.relatr a on p.periodo = a.periodo and p.producto = a.producto and p.observacion = a.observacion and p.informante = a.informante and p.visita = a.visita
            LEFT JOIN (SELECT * FROM cvp.relatr WHERE atributo = 196 /*Día de la semana*/) d on a.periodo = d.periodo and a.producto = d.producto 
                                and a.informante = d.informante and a.observacion = d.observacion and a.visita = d.visita
            LEFT JOIN cvp.atributos t on a.atributo = t.atributo
            LEFT JOIN cvp.productos u on a.producto = u.producto 
            WHERE t.es_vigencia and r.razon  = 1
            GROUP BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion,d.valor, coalesce(comun.cuantos_dias_mes(a.periodo,d.valor),0)
             ,extract(day from (substr(cvp.moverperiodos(a.periodo,1),2,4)||'-'||substr(cvp.moverperiodos(a.periodo,1),7,2)||'-01')::date  - '1 day'::interval)
            ORDER BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion
        ) f 
  WHERE NOT ((visitas = 1 and vigencias = 1) or ultimodiadelmes = vigencias or cantdias = vigencias);

GRANT SELECT ON TABLE controlvigencias TO cvp_administrador;