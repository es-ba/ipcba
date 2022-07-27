--res_cuadro_matriz_up
create or replace function res_cuadro_matriz_up(parametro1 text, p_periodo text, parametro4 text, pPonerCodigos boolean, pdesde text, porden text, p_separador text) 
  returns setof res_mat2
  language plpgsql
as
$BODY$
declare
    vAnchoNumeros text:='100';
    v_periodo_desde text:=pdesde; --'a2013m01';
    v_formato_renglon text:=case when pPonerCodigos then 'DW11n'::text else 'D.W2n'::text end;
    v_formato_renglon_cabezal text:=case when pPonerCodigos then 'E1111'::text else 'E1.21'::text end;
    v_formato_renglon_padres text:=case when pPonerCodigos then 'GW11n'::text else 'G.W2n'::text end;
    
begin
  return query select 'anchos'::text as formato_renglon,
                      'auto'::text, 
                      'auto'::text,
                      'auto'::text,
                      null::text,
                      vAnchoNumeros;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
                      case when pPonerCodigos then 'Producto'::text else 'Descripción'::text end,
                      case when pPonerCodigos then 'Descripción'::text else null end,
                      'Unidad de medida'::text,
                      null::text,
                      null::text;
  return query select formato_renglon, producto, nombreproducto, unidadmedidaabreviada, nombreperiodo, promprod from (
                select case when porden = 'desc' then row_number() over (order by periodo desc ,q.ordenpor)+100 
                         else row_number() over (order by periodo, q.ordenpor)+100 end,
                    q.formato_renglon, q.producto, q.nombreproducto, q.unidadmedidaabreviada,
                    devolver_mes_anio(periodo) as nombreperiodo, q.promprod
                 from 
                 (select * from
                 (
                 select 
                    v_formato_renglon::text as formato_renglon,
                    p.grupopadre,
                    case when pPonerCodigos then producto::text else null end as producto,
                    nombreproducto::text,
                    unidadmedidaabreviada::text,
                    periodo,
                    replace(round(promprod::numeric,2)::text,'.',p_separador) as promprod,
                    /*periodo||*/p.grupopadre||producto::text as ordenpor
                 from preciosmedios_albs_var p
				      join calculos_def cd on p.calculo = cd.calculo
                      left join gru_grupos g on g.agrupacion = 'E' and g.grupo = p.producto 
                      left join cvp.grupos u on g.agrupacion = u.agrupacion and g.grupo_padre = u.grupo 
                 where (gruponivel1 = parametro4 or g.grupo_padre = parametro4)
                   and cd.principal and coalesce(u.nivel,1) = 1
                   and periodo between v_periodo_desde and p_Periodo
               
                 union
                 select distinct  
                    v_formato_renglon_padres::text as formato_renglon,
                    p.grupopadre, 
                    null as producto, 
                    substr(nombregrupopadre,1,1)||lower(substr(nombregrupopadre,2)) as nombreproducto, 
                    null as unidadmedidaabreviada,
                    periodo,
                    null as promprod,
                    /*periodo||*/p.grupopadre||'P0000000'::text as ordenpor
                 from preciosmedios_albs_var p
				      join calculos_def cd on p.calculo = cd.calculo
                      left join gru_grupos g on g.agrupacion = 'E' and g.grupo = p.producto 
                      left join cvp.grupos u on g.agrupacion = u.agrupacion and g.grupo_padre = u.grupo 
                 where (gruponivel1 = parametro4 or g.grupo_padre = parametro4)
                   and cd.principal
                   and periodo between v_periodo_desde and p_Periodo
                ) as d order by ordenpor, periodo) as q) as x
               ;
end;
$BODY$;
--test 
--SELECT * from cvp.res_cuadro_matriz_up('Precios Medios Bienes y Servicios','a2022m05'::text, 'C2',true,'a2022m01','asc',',');  
--SELECT * from cvp.res_cuadro_matriz_up('Precios medios Alimentos','a2022m05'::text, 'C1',true,'a2022m01','asc',',');  
--SELECT * from cvp.res_cuadro_matriz_up('Precios Medios Bienes y Servicios','a2022m05'::text, 'C2',false,'a2022m01','desc',',');  
--SELECT * from cvp.res_cuadro_matriz_up('Precios medios Alimentos','a2022m05'::text, 'C1',false,'a2022m01','desc',',');  

--SELECT * from cvp.res_cuadro_matriz_up('Precios Medios Bienes y Servicios','a2022m05'::text, 'E2',false,'a2022m01','desc',',');  
--SELECT * from cvp.res_cuadro_matriz_up('Precios medios Alimentos','a2022m05'::text, 'E1',false,'a2022m01','desc',',');  
