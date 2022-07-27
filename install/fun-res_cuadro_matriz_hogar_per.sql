--res_cuadro_matriz_hogar_per
create or replace function res_cuadro_matriz_hogar_per(parametro1 text, p_periodo text, parametro4 text, p_cuadro text, parametro6 integer, p_periodo_desde text, p_separador text) 
  returns setof res_mat2
  language plpgsql
as
$BODY$
declare
    vMesActual text;
    vMesAnterior text;
    vCalculoAnterior integer;
    vAgrupacionPrincipal text;
    vAnchoNumeros text:='100';
    v_periodo_desde text:=p_periodo_desde;
    v_periodo_hasta text:=p_periodo;
    v_formato_renglon text:='DW11n'; -- solo pongo letras para: el tipo de renglón, las columas laterales y una más para todos los datos.
    v_formato_renglon_cabezal text:='E1111'; -- idem
begin
  return query select 'anchos'::text as formato_renglon,
                      'auto'::text, 
                      'auto'::text,
                      'auto'::text,
                      null::text,
                      100::text;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
                      'Mes'::text, 
                      'Valorización'::text, 
                      'Cód'::text,
                      null::text,
                      null::text;
  return query select v_formato_renglon::text as formato_renglon,
                      cvp.devolver_mes_anio(periodo)::text as lateral1,
                      CASE WHEN v.nivel = 1 THEN v.nombrecanasta 
                                            ELSE v.nombregrupo END ::text as lateral2,
                      v.grupo::text as lateral3,
                      v.hogar::text as cabezal1,
                      replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador) as celda
                 from valorizacion_canasta_cuadros v --inner join grupos g on v.agrupacion = g.agrupacion and v.grupo = g.grupo
                 join calculos_def cd on v.calculo = cd.calculo
				 where ((p_cuadro <> 'CC' and v.agrupacion = parametro4) or (p_cuadro = 'CC' and ((v.agrupacion = 'D' and v.grupo in ('D1', 'D5')) OR (v.agrupacion = parametro4 and v.grupo in ('A1', 'A5'))))) 
                   and cd.principal
                   and v.periodo between v_periodo_desde and v_periodo_hasta
                   and replace(replace(v.hogar,'5b','5.1'),'Hogar ','')::numeric < parametro6
                 ORDER BY v.periodo, v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, comun.para_ordenar_numeros(v.hogar);
end;
$BODY$;

--test 
--SELECT * from cvp.res_cuadro_matriz_hogar_per('Listado de Comparación de líneas de la canasta para 5 hogares', 'a2022m05'::text, 'A'::text, 'CC', 6, 'a2022m01'::text,',');  
