--res_cuadro_up
create or replace function res_cuadro_up(parametro1 text, p_periodo text, parametro4 text, pPonercodigos boolean, pempalmedesde boolean, 
                                         pempalmehasta boolean, pperiodoempalme text, p_separador text) 
  returns setof res_col4
  language plpgsql
as
$BODY$
declare

    vAnchoNumeros text:='100';

begin
  return query select 0::bigint,'anchos'::text,
       'auto'::text,
       'auto'::text,'auto'::text,vAnchoNumeros;

  return query select 1::bigint,case when pPonerCodigos then 'ULLLR'::text else 'U2.LR'::text end, 
                 case when pPonerCodigos then 'Código de Producto'::text else 'Descripción'::text end,
                 case when pPonerCodigos then 'Descripción'::text else null end, 'Unidad de medida'::text, 'Precio medio'::text;
  return query select row_number() over (order by q.grupopadre, q.orden, q.producto)+100,
                    q.formato_renglon, q.producto, q.nombreproducto, q.unidadmedidaabreviada, q.promprod
                 from 
                 (
                 select 
                    --'D111n'::text
                    --as formato_renglon,
                    case when pPonerCodigos then 'D111n' else 'D.21n' end as formato_renglon,
                    grupopadre,
                    case when pPonerCodigos then producto::text else null end as producto,
                    nombreproducto::text,
                    unidadmedidaabreviada::text,
                    replace(round(promprod::numeric,2)::text,'.',p_separador) as promprod,
                    grupopadre||producto::text as ordenpor, coalesce(cg.orden, 0) as orden
                 from preciosmedios_albs_var p 
                 join calculos_def cd on p.calculo = cd.calculo
                 left join cuagru cg on p.agrupacion = cg.agrupacion and p.producto = cg.grupo and cg.cuadro = CASE WHEN parametro4 = 'C1' THEN '7' ELSE '6' END
                 where gruponivel1 = parametro4
                   and cd.principal
                   and periodo=p_Periodo
                   and ((pempalmehasta and periodo <= pperiodoempalme) or 
                        (pempalmedesde and periodo >  pperiodoempalme))
               
                 union
                 select distinct --row_number() over (ordenpor)+100, 
                    'G.2..' as formato_renglon, 
                    grupopadre, 
                    'Q0000000' as producto,
                    substr(nombregrupopadre,1,1)||lower(substr(nombregrupopadre,2)) as nombreproducto, 
                    null as unidadmedidaabreviada, 
                    null as promprod,
                    grupopadre||'Q0000000'::text as ordenpor, 0 AS orden
                 from preciosmedios_albs_var p 
                 join calculos_def cd on p.calculo = cd.calculo
                 where gruponivel1 = parametro4
                   and cd.principal
                   and periodo=p_periodo
                   and ((pempalmehasta and periodo <= pperiodoempalme) or 
                        (pempalmedesde and periodo >  pperiodoempalme))
                ) as q
               ;
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_up(null, 'a2022m03'::text, 'C2',true, true, false , 'a2022m02',',');  --Invocacion cuadros Cuadro I. Precios medios relevados de bienes y servicios. Ciudad de Buenos Aires
--SELECT * from cvp.res_cuadro_up(null, 'a2022m03'::text, 'C1',true, true, false , 'a2022m02',',');  --Invocacion cuadros: Cuadro II. Precios medios relevados de productos alimenticios. Ciudad de Buenos Aires