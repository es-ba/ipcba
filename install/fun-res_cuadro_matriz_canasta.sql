--res_cuadro_matriz_canasta
CREATE OR REPLACE FUNCTION res_cuadro_matriz_canasta(parametro1 text, p_periodo text, parametro4 text, pPonerCodigos boolean, p_hogar text, p_periododesde text, p_separador text)
  returns setof cvp.res_mat
  language plpgsql
as
$BODY$
declare
    v_formato_renglon text:=case when pPonerCodigos then 'DW1n'::text else 'D.Wn'::text end;
    v_formato_renglon_cabezal text:=case when pPonerCodigos then 'E111'::text else 'E1.1'::text end;
    v_linea_alimentaria text:=case when parametro4 = 'B' then 'CA' when parametro4 = 'D' then 'LI' else '' end;
    v_linea_total text:=case when parametro4 = 'B' then 'CT' when parametro4 = 'D' then 'LP' else '' end;
    v_basica text:=case when parametro4 <> 'B' then 'Básica ' else '' end;

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
                  devolver_mes_anio(v.periodo) as cabezal1,
                  replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador) as celda
                  FROM valorizacion_canasta_cuadros v --left join grupos g on v.agrupacion= g.agrupacion and v.grupo = g.grupo
                    join calculos_def cd on v.calculo = cd.calculo
				  WHERE v.agrupacion = parametro4 /*B*/
                        and cd.principal
                        and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                        and v.hogar = p_hogar --tiene que ser parametro
                  ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, v.periodo, comun.para_ordenar_numeros(v.hogar);
  return query  SELECT v_formato_renglon::text as formato_renglon, 
                  case when pPonerCodigos then v.grupo::text else null end as lateral1,
                  'Valor diario de la canasta '||v_basica||'alimentaria ('||v_linea_alimentaria||')**'::text as lateral2,
                  devolver_mes_anio(v.periodo) as cabezal1,
                  replace(round((v.valorhoggru::numeric/30),2)::text,'.',p_separador) as celda
                  FROM valorizacion_canasta_cuadros v --left join grupos g on v.agrupacion= g.agrupacion and v.grupo = g.grupo
                    join calculos_def cd on v.calculo = cd.calculo 
				  WHERE v.agrupacion = parametro4 /*B*/
                    and cd.principal
                    and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                    and v.hogar = p_hogar --tiene que ser parametro
                    and v.grupo in ('B1','D1') --es la canasta alimentaria
                  ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, v.periodo, comun.para_ordenar_numeros(v.hogar);
  return query  SELECT v_formato_renglon::text as formato_renglon, 
                  case when pPonerCodigos then v.grupo::text else null end as lateral1,
                  'Valor diario de la canasta '||v_basica||'total ('||v_linea_total||')**'::text as lateral2,
                  devolver_mes_anio(v.periodo) as cabezal1,
                  replace(round((v.valorhoggru::numeric/30),2)::text,'.',p_separador) as celda
                  FROM valorizacion_canasta_cuadros v --left join grupos g on v.agrupacion= g.agrupacion and v.grupo = g.grupo
                          join calculos_def cd on v.calculo = cd.calculo
						  WHERE v.agrupacion = parametro4 /*B*/
                            and cd.principal
                            and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                            and v.hogar = p_hogar --tiene que ser parametro
                            and v.grupo in ('B4','D5') --es la canasta total
                  ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, v.periodo, comun.para_ordenar_numeros(v.hogar);
end;
$BODY$;

--test
--SELECT * from res_cuadro_matriz_canasta('Listado de Valorización de la Canasta', 'a2022m05'::text, 'B'::text, true, 'Hogar 1', 'a2022m05'::text, '.');  
--SELECT * from res_cuadro_matriz_canasta('Listado de Valorización de la Canasta', 'a2022m05'::text, 'D'::text, false, 'Hogar 1', 'a2022m05'::text, '.');  
