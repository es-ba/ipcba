--res_cuadro_matriz_canasta_var

CREATE OR REPLACE FUNCTION res_cuadro_matriz_canasta_var(parametro1 text, p_periodo text, parametro4 text, pPonerCodigos boolean, p_hogar text, p_periododesde text, p_separador text)
  returns setof cvp.res_mat
  language plpgsql
as
$BODY$
declare
    v_formato_renglon text:=case when pPonerCodigos then 'DW1n'::text else 'D.Wn'::text end;
    v_formato_renglon_cabezal text:=case when pPonerCodigos then 'E111'::text else 'E1.1'::text end;

begin
  return query select 'anchos'::text as formato_renglon,
                      'auto'::text, 
                      'auto'::text,
                      null::text,
                      100::text;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
                      case when pPonerCodigos then 'Cód'::text else 'Componentes de las diferentes canastas'::text end,
                      case when pPonerCodigos then 'Componentes de las diferentes canastas'::text else null end,
                      null::text,
                      null::text;
  return query  SELECT v_formato_renglon::text as formato_renglon,
                  case when pPonerCodigos then v.grupo::text else null end as lateral1,
                  CASE WHEN v.nivel = 1 THEN v.nombrecanasta 
                  ELSE v.nombregrupo END ::text as lateral2,
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as cabezal1,
                  case when v1.valorhoggru = 0 then '0'||p_separador||'0'::text else
                  replace(round((round(v.valorhoggru::numeric,2)/round(v1.valorhoggru::numeric,2)*100-100),1)::text,'.',p_separador) end as celda
                  FROM (SELECT * FROM valorizacion_canasta_cuadros WHERE periodo = p_periodo) v
				    join calculos_def cd on v.calculo = cd.calculo
                    LEFT JOIN (SELECT * FROM valorizacion_canasta_cuadros WHERE periodo = p_periododesde) v1
                      on v.calculo = v1.calculo and v.hogar = v1.hogar and v.agrupacion = v1.agrupacion and v.grupo = v1.grupo 
                  WHERE --v.periodo = p_periodo
                        --and v1.periodo = p_periododesde and 
                        v.agrupacion = parametro4
                        and cd.principal
                        and v.hogar = p_hogar --tiene que ser parametro
                  ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, v.periodo, comun.para_ordenar_numeros(v.hogar);
  return query  SELECT v_formato_renglon::text as formato_renglon, 
                  case when pPonerCodigos then v.grupo::text else null end as lateral1,
                  'Valor diario de la canasta Básica alimentaria (LI)**'::text as lateral2,
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as cabezal1,
                  case when v1.valorhoggru = 0 then '0'||p_separador||'0'::text else
                  replace(round((round(v.valorhoggru::numeric/30,2)/round(v1.valorhoggru::numeric/30,2)*100-100),1)::text,'.',p_separador) end as celda
                  FROM (SELECT * FROM valorizacion_canasta_cuadros WHERE periodo = p_periodo) v
				    join calculos_def cd on v.calculo = cd.calculo
                    LEFT JOIN (SELECT * FROM valorizacion_canasta_cuadros WHERE periodo = p_periododesde) v1 
                      on v.calculo = v1.calculo and v.hogar = v1.hogar and v.agrupacion = v1.agrupacion and v.grupo = v1.grupo
                  WHERE --v.periodo = p_periodo
                    --and v1.periodo =  p_periododesde and 
                    v.agrupacion = parametro4
                    and cd.principal
                    and v.hogar = p_hogar --tiene que ser parametro
                    and v.grupo in ('B1','D1') --es la canasta alimentaria
                  ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, v.periodo, comun.para_ordenar_numeros(v.hogar);
  return query  SELECT v_formato_renglon::text as formato_renglon, 
                  case when pPonerCodigos then v.grupo::text else null end as lateral1,
                  'Valor diario de la canasta Básica total (LP)**'::text as lateral2,
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as cabezal1,
                  case when v1.valorhoggru = 0 then '0'||p_separador||'0'::text else
                  replace(round((round(v.valorhoggru::numeric/30,2)/round(v1.valorhoggru::numeric/30,2)*100-100),1)::text,'.',p_separador) end as celda
                  FROM (SELECT * FROM valorizacion_canasta_cuadros WHERE periodo = p_periodo) v
				    join calculos_def cd on v.calculo = cd.calculo
                    LEFT JOIN (SELECT * FROM valorizacion_canasta_cuadros WHERE periodo = p_periododesde) v1 
                      on v.calculo = v1.calculo and v.hogar = v1.hogar and v.agrupacion = v1.agrupacion and v.grupo = v1.grupo
                          WHERE  --v.periodo = p_periodo
                            --and v1.periodo =  p_periododesde and 
                            v.agrupacion = parametro4
                            and cd.principal
                            and v.hogar = p_hogar --tiene que ser parametro
                            and v.grupo in ('B4','D5') --es la canasta total
                  ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, v.periodo, comun.para_ordenar_numeros(v.hogar);
end;
$BODY$;

--test
--SELECT * from res_cuadro_matriz_canasta_var('Listado de Valorización de la Canasta', 'a2022m05'::text, 'B'::text, true, 'Hogar 1', 'a2022m01'::text, '.');  
--SELECT * from res_cuadro_matriz_canasta_var('Listado de Valorización de la Canasta', 'a2022m05'::text, 'B'::text, false, 'Hogar 1', 'a2022m01'::text, '.');  
