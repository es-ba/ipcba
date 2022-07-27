--res_cuadro_matriz_hogar_var
--UTF8=Sí

create or replace function res_cuadro_matriz_hogar_var(parametro1 text, p_periodo text, parametro4 text, parametro6 integer, p_periododesde text, p_separador text) 
  returns setof res_mat
  language plpgsql
as
$BODY$
declare
    vMesActual text;
    vMesAnterior text;
    vCalculoAnterior integer;
    vAgrupacionPrincipal text;
    vAnchoNumeros text:='100';
    v_periodo_desde text:='a2012m01';
    v_periodo_hasta text:=p_periodo;
    v_formato_renglon text:='DW1n'; -- solo pongo letras para: el tipo de renglón, las columas laterales y una más para todos los datos.
    v_formato_renglon_cabezal text:='E111'; -- idem
begin
  return query select 'anchos'::text as formato_renglon,
                      'auto'::text, 
                      'auto'::text,
                      null::text,
                      100::text;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
                      'Valorización'::text, 
                      'Cód'::text,
                      null::text,
                      null::text;
  return query select v_formato_renglon::text as formato_renglon,
                      CASE WHEN v.nivel = 1 THEN v.nombrecanasta 
                                            ELSE v.nombregrupo END ::text as lateral1,
                      v.grupo::text as lateral2,
                      v.hogar::text as cabezal1,
                      case when v1.valorhoggru = 0 then '0'||p_separador||'0'::text else
                      replace(round((round(v.valorhoggru::numeric,2)/round(v1.valorhoggru::numeric,2)*100-100),1)::text,'.',p_separador) end as celda
                 from (select * from valorizacion_canasta_cuadros where periodo = p_periodo) v --inner join grupos g on v.agrupacion = g.agrupacion and v.grupo = g.grupo
                      join calculos_def cd on v.calculo = cd.calculo
                      left join (select * from valorizacion_canasta_cuadros where periodo = p_periododesde) v1 on v.calculo = v1.calculo and v.agrupacion = v1.agrupacion and v.grupo = v1.grupo and v.hogar = v1.hogar 
                 where v.agrupacion = parametro4
                   and cd.principal
                   --and v.periodo = p_periodo
                   --and v1.periodo = p_periododesde
                   and replace(replace(v.hogar,'5b','5.1'),'Hogar ','')::numeric < parametro6
                 ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, comun.para_ordenar_numeros(v.hogar);
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_matriz_hogar_var('Listado de Valorización de la Canasta', 'a2022m05'::text, 'A'::text, 18, 'a2022m01'::text, ',');  
--SELECT * from cvp.res_cuadro_matriz_hogar_var('Listado de Valorización de la Canasta para 5 hogares', 'a2022m05'::text, 'A'::text, 6, 'a2022m03'::text,',');  
