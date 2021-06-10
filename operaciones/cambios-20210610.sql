set search_path = cvp;

--se testea la consistencia de vigencias cuando hay una única visita, sólo si el tipoprecio es positivo
--cuando hay más de una visita, se testea con por lo menos un tipoprecio positivo
--detecta días de la semana mal escritos

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
            string_agg((COALESCE(p.comentariosrelpre, ' '::text) || ' '::text) || COALESCE(p.observaciones, ' '::text), ' '::text) AS comentarios,
            string_agg (COALESCE(p.tipoprecio, ' '::text), ' '::text order by p.visita) as tipoprecio,
		    sum(case when tp.espositivo = 'N' then 1 else 0 end) as cantnegativos,
		    sum(case when tp.espositivo = 'S' then 1 else 0 end) as cantpositivos			
           FROM relvis r
             LEFT JOIN relpre p ON r.periodo::text = p.periodo::text AND r.informante = p.informante AND r.visita = p.visita AND r.formulario = p.formulario
             LEFT JOIN relatr a ON p.periodo::text = a.periodo::text AND p.producto::text = a.producto::text AND p.observacion = a.observacion AND p.informante = a.informante AND p.visita = a.visita
             LEFT JOIN (SELECT *
                          FROM relatr
                          WHERE atributo = 196) d 
                        ON a.periodo = d.periodo AND a.producto = d.producto AND a.informante = d.informante AND a.observacion = d.observacion AND a.visita = d.visita
             LEFT JOIN atributos t ON a.atributo = t.atributo
             LEFT JOIN productos u ON a.producto = u.producto
             LEFT JOIN razones z on r.razon = z.razon
             LEFT JOIN tipopre tp on p.tipoprecio = tp.tipoprecio
          WHERE t.es_vigencia AND coalesce(z.espositivoformulario, 'N') = 'S' --and coalesce(tp.espositivo, 'N') = 'S' 
          GROUP BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion, d.valor, 
          (COALESCE(comun.cuantos_dias_mes(a.periodo::text, d.valor::text), 0)), 
          (date_part('day'::text, ((((substr(moverperiodos(a.periodo::text, 1), 2, 4) || '-'::text) || substr(moverperiodos(a.periodo::text, 1), 7, 2)) || '-01'::text)::date) - '1 day'::interval))
          ORDER BY a.periodo, a.informante, a.producto, u.nombreproducto, a.observacion) f
  WHERE NOT ((f.visitas = 1 AND ((cantnegativos = 0 AND cantpositivos = 0) OR cantnegativos > 0 OR f.ultimodiadelmes = f.vigencias OR (f.cantdias > 0 and f.vigencias = f.cantdias))) OR 
			 (f.visitas > 1 AND (f.visitas = cantpositivos AND (f.ultimodiadelmes = f.vigencias OR f.cantdias = f.vigencias)))
			);