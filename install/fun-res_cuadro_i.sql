--res_cuadro_i
--UTF8=Sí
create or replace function res_cuadro_i(parametro1 text, p_periodo text, parametro3 integer, parametro4 text, pPonerCodigos boolean, pCantDecimales integer, p_separador text) 
  returns setof res_col3
  language plpgsql
as
$BODY$
declare
    vAgrupacionPrincipal text;
    vAnchoNumeros text:='100';

begin
  return query select 0::bigint,'anchos'::text,'auto'::text,'auto'::text,vAnchoNumeros;

  return query select 1::bigint,'U2.R'::text,parametro1::text,null::text, devolver_mes_anio(p_periodo)||' *'::text;
  return query select row_number() over (order by i.grupo)+100,
          case when i.nivel=0 then 'N.2n' when pPonerCodigos then 'D11n' else 'D.2n' end as formato_renglon,
          case when pPonerCodigos  and i.nivel<>0 then
                    CASE WHEN substr(i.grupo,2,1)::integer <1 
                      THEN substr(i.grupo,3)::text 
                      ELSE substr(i.grupo,2)::text END
                 else null end as grupo,
          overlay(lower(nombregrupo) placing upper(substr(nombregrupo,1,1)) from 1 for 1)::text,
          replace(round(i.incidenciaredondeada::numeric,case when i.nivel=0 then 1 else pCantDecimales end)::text,'.',p_separador)::text
          --replace(round(i.incidencia::numeric,case when i.nivel=0 then 1 else case when parametro4 in ('S', 'R')then 1 else 2 end end)::text,'.',',')::text
                 from calgru i
				 inner join calculos_def cd on i.calculo = cd.calculo
                 inner join grupos g on i.agrupacion=g.agrupacion and i.grupo=g.grupo
                 where i.agrupacion= parametro4  --vAgrupacionPrincipal
                   and i.nivel <= parametro3
                   and cd.principal
                   and i.periodo=p_Periodo;
end;
$BODY$;

--test:
--SELECT * from cvp.res_cuadro_i('Nivel general y capítulos', 'a2022m05'::text, 1, 'Z', true, 2,',');           --Cuadro3 IPCBA. Incidencia de los capítulos en el nivel general
--SELECT * from cvp.res_cuadro_i('Nivel general, bienes y servicios', 'a2022m05'::text, 1, 'S', false, 1,',');  --Cuadro4a IPCBA. Incidencia de los bienes y servicios en el nivel general con un decimal
--SELECT * from cvp.res_cuadro_i('Nivel general, bienes y servicios', 'a2022m05'::text, 1, 'S', false, 2,',');  --Cuadro4b IPCBA. Incidencia de los bienes y servicios en el nivel general con dos decimales
