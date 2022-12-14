set search_path = cvp;
--el atributo vigencia copia del mes anterior como los demás atributos, no genera en forma diferenciada con la # de días del mes
-- como hasta ahora
CREATE OR REPLACE FUNCTION cvp.generar_formulario(
  pperiodo text,
  pinformante integer,
  pformulario integer,
  pfechageneracion timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    VOLATILE SECURITY DEFINER 
    
AS $BODY$
declare
  /* v100713
       genera los atributos según prodatr
     v100301
     la inclusión forzosa de nuevos productos verifica que eno esté presente el producto en el periodo anterior
       (esto para arreglar un posible problema con los productos que están en dos formularios asignados al mismo informante)
     v100224
     con inclusión forzosa de nuevos productos para determinado formulario (según forprod)
     v080924  
     con búsqueda de visita anterior
  */
  vcantidadpreciosgenerados integer;
  vvisita INTEGER := 1;
  vcantidadatributosgenerados integer;
  vcantidadatributosenformulario integer;
  vvisitasperiodoanterior integer;
  
begin
  --raise notice 'pap 1';
  insert into cvp.bitacora (que) values ('nueva generacion '||pperiodo||' i:'||pinformante||' f:'||pformulario||' g:'||pfechageneracion);

  --raise notice 'pap 2-- Insercion en relpre';
    insert into cvp.relpre(periodo, producto, observacion, informante, visita, formulario, precio, tipoprecio, especificacion, ultima_visita)
      select pperiodo, f.producto, f.observacion, pinformante, vvisita, f.formulario, null, null, f.especificacion, true
        from cvp.forobsinf f
          inner join cvp.informantes i on f.informante = i.informante and i.informante=pinformante
          inner join cvp.rubros ru on i.rubro=ru.rubro
          left join cvp.relpre r 
            on r.informante=pinformante 
              and r.formulario=f.formulario 
              and r.producto=f.producto 
              and r.observacion=f.observacion
              and r.periodo=pperiodo
              and r.visita=vvisita
        where f.formulario=pformulario
          and --(ru.despacho='A' or f.observacion=1)
            (f.dependedeldespacho = 'N' or ru.despacho = 'A' OR f.observacion = 1)
            and r.periodo is null;
  -- verifico que se haya generado al menos algún precio
  --raise notice 'pap 3';
  select count(*)
    into vcantidadpreciosgenerados
    from cvp.relpre
    where periodo=pperiodo
      and informante=pinformante
      and formulario=pformulario
      and visita=vvisita;
  -- Debe ser una excepcion  
  IF vcantidadpreciosgenerados=0 THEN
    --raise Exception 'Error, No se generaron filas del formulario del periodo %, informante%, formulario%  sin registros en relpre', pperiodo, pinformante, pformulario;  
    raise Notice 'ADVERTENCIA, No se generaron filas del formulario del periodo %, informante%, formulario%  sin registros en relpre', pperiodo, pinformante, pformulario;  
    
  END IF;

  select count(*) into vvisitasperiodoanterior
  from cvp.periodos p 
  inner join cvp.relvis v on p.periodoanterior = v.periodo 
  where p.periodo = pperiodo
      and v.informante=pinformante
      and v.formulario=pformulario
      and v.visita=vvisita;

  select count(*) into vcantidadatributosgenerados
    from cvp.relatr a
  left join cvp.periodos p on a.periodo = p.periodoanterior
    left join cvp.relpre r on
    a.periodo = r.periodo and 
    a.producto = r.producto and 
    a.observacion = r.observacion and 
    a.informante = r.informante and 
    a.visita = r.visita
    where p.periodo=pperiodo
      and a.informante=pinformante
      and r.formulario=pformulario
      and a.visita=vvisita;
    
  select count(*) into vcantidadatributosenformulario
  from cvp.prodatr pa
  left join cvp.forprod fp using (producto)
  where fp.formulario = pformulario;

  IF vcantidadatributosenformulario > 0 and vcantidadatributosgenerados=0 and vvisitasperiodoanterior > 0 THEN
    raise Exception 'Error, No se generaron los atributos del periodo anterior; periodo %, informante%, formulario% ', pperiodo, pinformante, pformulario;
  END IF;
  
  --raise notice 'pap 4';
    insert into cvp.relatr (periodo , producto  , observacion     , informante , atributo  , valor, visita, validar_con_valvalatr)
      select                rp.periodo, rp.producto, rp.observacion, rp.informante, f.atributo,
                               CASE WHEN r_1.atributo IS NULL THEN a.valorInicial 
                                 ELSE r_1.valor END ,  rp.visita, vv.validar
      from cvp.prodatr f 
        inner join cvp.relpre rp
          on rp.producto=f.producto 
            and rp.informante=pinformante
            and rp.formulario=pformulario
            and rp.periodo=pperiodo
            and rp.visita=vvisita
        INNER JOIN cvp.atributos a ON a.atributo=f.atributo    
        left join cvp.relatr ra 
          on ra.informante=rp.informante 
            and ra.atributo=f.atributo
            and ra.producto=rp.producto 
            and ra.observacion=rp.observacion
            and ra.periodo=rp.periodo
            and ra.visita=rp.visita
        left join cvp.relpre p_1
          on p_1.informante=rp.informante 
            and p_1.producto=rp.producto 
            and p_1.observacion=rp.observacion
            and p_1.periodo= (SELECT MAX(periodo)
                                FROM cvp.relatr
                                WHERE periodo < rp.periodo
                                  AND producto = rp.producto AND observacion = rp.observacion 
                                  AND informante = rp.informante AND atributo=f.atributo)
            and p_1.ultima_visita=true
        left join cvp.relatr r_1 
          on r_1.informante=rp.informante 
            and r_1.atributo=f.atributo
            and r_1.producto=rp.producto 
            and r_1.observacion=rp.observacion
            and r_1.periodo=p_1.periodo
            and r_1.visita=p_1.visita
        LEFT JOIN cvp.ValValAtr vv ON f.producto = vv.producto
            AND f.atributo = vv.atributo
            AND r_1.valor = vv.valor
      where ra.periodo is null
        and rp.informante=pinformante
        and rp.formulario=pformulario
        and rp.periodo=pperiodo
        and rp.visita=vvisita;
  
  --raise notice 'pap 5';
  return null;
end
$BODY$;

--se testea la consistencia de vigencias cuando hay una única visita
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
			string_agg (COALESCE(p.tipoprecio, ' '::text), ' '::text order by p.visita) as tipoprecio
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
  WHERE NOT ((f.visitas = 1 and f.vigencias = 1) OR f.ultimodiadelmes = f.vigencias OR f.cantdias = f.vigencias);