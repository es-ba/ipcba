--res_cuadro_matriz_i
--UTF8=Sí
create or replace function res_cuadro_matriz_i(parametro1 text, p_periodo text, parametro3 integer, parametro4 text, pPonerCodigos boolean, p_cuadro text, pCantDecimales integer, pdesde text, porden text, p_separador text)
  returns setof res_mat
  language plpgsql
as
$BODY$
declare
    vAgrupacionPrincipal text;
    vAnchoNumeros text:='100';
    v_periodo_desde text:=pdesde;
    --v_formato_renglon text:=case when pPonerCodigos then 'DW1n'::text else 'D.W2n'::text end;
    --v_formato_renglon_cabezal text:=case when pPonerCodigos then 'E111'::text else 'E1.21'::text end;   
    v_formato_renglon text:=case when pPonerCodigos then 'DW1n'::text else 'D.Wn'::text end;
    v_formato_renglon_cabezal text:=case when pPonerCodigos then 'E2.1'::text else 'E2.1'::text end;

    
begin
  return query select 'anchos'::text as formato_renglon,'auto'::text,'auto'::text,null::text,vAnchoNumeros;
  return query select v_formato_renglon_cabezal::text as formato_renglon,parametro1::text,null::text, null::text, null::text;
  return query select formato_renglon, grupo, nombregrupo, nombreperiodo, case when p_cuadro in ('A2bish', 'A2bish_con', 'A2bish_tot') then indicered else incidenciared end 
                from (
                select case when porden = 'desc' then row_number() over (order by periodo desc ,q.ordenpor)+100 
                         else row_number() over (order by periodo, q.ordenpor)+100 end,
                    q.formato_renglon, q.grupo, q.nombregrupo,
                    q.nombreperiodo, q.incidenciared, q.indicered
                 from 
                 (
          select
          case when i.nivel=0 then 'N.2n' when pPonerCodigos then 'D11n' else 'D.2n' end as formato_renglon,
          case when pPonerCodigos and i.nivel<>0 then 
            case when p_cuadro like 'A2%' then i.grupo::text 
              else CASE WHEN substr(i.grupo,2,1)::integer <1 
                      THEN substr(i.grupo,3)::text 
                   ELSE substr(i.grupo,2)::text END
              end                   
          else null end as grupo, coalesce(cuagru.orden::text,i.grupo) as ordenpor, i.periodo,
          overlay(lower(nombregrupo) placing upper(substr(nombregrupo,1,1)) from 1 for 1)::text as nombregrupo,
          devolver_mes_anio(i.periodo)||case when i.periodo=p_Periodo then ' *'::text else ''::text end as nombreperiodo,
          CASE WHEN p_cuadro = '3h_ia' THEN
            replace(round(i.incidenciainteranualredondeada::numeric,case when i.nivel=0 then 1 else pCantDecimales end)::text,'.',p_separador)::text
          ELSE
            replace(round(i.incidenciaredondeada::numeric,case when i.nivel=0 then 1 else pCantDecimales end)::text,'.',p_separador)::text 
          END as incidenciared,
          replace(round(i.indice::numeric,pCantDecimales)::text,'.',p_separador)::text as indicered
                 from (select * from calgru_vw order by periodo, calculo, agrupacion, grupo) i
				 inner join calculos_def df on i.calculo = df.calculo
                 inner join grupos g on i.agrupacion=g.agrupacion and i.grupo=g.grupo
                 left join cuagru on i.agrupacion = cuagru.agrupacion and i.grupo = cuagru.grupo and cuagru.cuadro = p_cuadro
                 where i.agrupacion= parametro4
                   and i.nivel <= parametro3
                   and df.principal
                   and i.periodo between v_periodo_desde and p_Periodo
                   and (p_cuadro not in ('A2bish', 'A2bish_con') or cuagru.cuadro is not null)
                   order by i.periodo, CASE WHEN p_cuadro = 'A2bish_con' THEN cuagru.orden::text ELSE i.grupo END) as q) as x;
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_matriz_i('Nivel general y capítulos', 'a2022m05'::text, 1, 'Z', true,'3h', 2,'a2022m01','desc',',');  --Cuadro3h IPCBA. Incidencia de los capítulos en el nivel general
--SELECT * from cvp.res_cuadro_matriz_i('Nivel general, bienes y servicios', 'a2022m05'::text, 1, 'S', false,'4bh', 2,'a2022m01','desc',',');  --Cuadro4bh IPCBA. Incidencia de los bienes y servicios en el nivel general con dos decimales
--SELECT * from cvp.res_cuadro_matriz_i('Apertura'                         , 'a2022m05'      , 3, 'Z', true ,'A2bish',2,'a2022m01','asc',','); --CuadroA2bish Índices IPCBA por aperturas.
