set search_path = cvp;

select informante, formularios, string_agg(producto, ', ') as productos
  from (
select informante, producto, count(*) as cantidad, string_agg(distinct formulario::text, ', ') as formularios
  from relvis inner join forprod using (formulario)
  where periodo='a2022m03' and visita=1
  group by informante, producto
  having count(*)>1
  order by informante) x
  group by informante, formularios
  order by 1, 2;