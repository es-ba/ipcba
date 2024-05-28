--res_cuadro_iivv
--UTF8=Sí

create or replace function res_cuadro_iivv(parametro1 text, p_periodo text, parametro3 integer, parametro4 text, pponercodigos boolean, p_cuadro text, pempalmedesde boolean, 
                                         pempalmehasta boolean, pperiodoempalme text, p_separador text)
  returns SETOF res_col8
  language plpgsql
as
$BODY$
declare
    vMesActual text;
    vMesAnterior text;
    vCalculoAnterior integer;
    vAgrupacionPrincipal text;
    vAnchoNumeros text:='100';
begin
  
  select c.periodoanterior, c.calculoanterior, cd.agrupacionprincipal  
    into vMesanterior, vCalculoAnterior, vAgrupacionPrincipal
    from Calculos c, Calculos_def cd    
    where c.periodo=p_periodo AND cd.principal AND c.calculo= cd.calculo;
    
  return query select 0::bigint,'anchos'::text,'auto'::text,'auto'::text,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros;
  --return query select 1::bigint,'E4.2.2.'::text,parametro1::text,null::text
  return query select 1::bigint,case when p_cuadro='1' then 'U5.86.7...' else 'U9..6.7...' end::text,parametro1::text,null::text
                 , case when p_cuadro ='1' then 'Ponderación por división' else null end::text, 'Índice ¹'::text
                 , null::text,'Variación porcentual'
                 , null::text, null::text;
  return query select 2::bigint,'P...RRRRR'::text,null::text,null::text, null::text
                 , devolver_mes_anio(p_periodo)
                 , devolver_mes_anio(vMesAnterior),'Respecto del mes anterior'::text --'Respecto de '||devolver_mes_anio(vMesAnterior)::text
                 , 'Acumulado anual'::text, 'Interanual'::text;
  return query select row_number() over (order by cg.grupo)+100,
                      case when (cg.nivel=0 and p_cuadro ='1') then 'N.3.nnnnn'  
                           when (cg.nivel=0 and p_cuadro in ('2', 'A2','8')) then 'N.2nnnnnn' 
                           when pPonerCodigos then 'D11nnnnnn' else 'D.2nnnnnn' end as formato_renglon,
                      case when pPonerCodigos and cg.nivel<>0 then case when p_cuadro not like 'A2%' then 
                                                                     case when substr(cg.grupo,2,1)::integer <1 
                                                                        then substr(cg.grupo,3)::text 
                                                                        else substr(cg.grupo,2)::text end
                                                                    else cg.grupo::text end
                        else null end as grupo, 
                      overlay(lower(nombregrupo) placing upper(substr(nombregrupo,1,1)) from 1 for 1)::text,
                      case when p_cuadro='1' then replace(round((g.ponderador*100)::numeric,2)::text,'.',',')::text||' %'::text else null::text end,
                      replace(round(cg.indiceRedondeado::numeric,2)::text,'.',p_separador)::text,
                      case when co.periodo < pperiodoempalme then '...'
                        else replace(round(co.indiceRedondeado::numeric,2)::text,'.',p_separador)::text end,
                      case when co.indiceRedondeado=0 then null
                        when co.periodo < pperiodoempalme then '...'
                        else replace(round((cg.indiceRedondeado/co.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                      case when ca.indiceRedondeado=0 then null
                        when ca.periodo < pperiodoempalme then '...' 
                        else replace(round((cg.indiceRedondeado/ca.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                      case when cb.indiceRedondeado=0 then null 
                        when cb.periodo < pperiodoempalme then '...' 
                        else replace(round((cg.indiceRedondeado/cb.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end    
                 from calGru cg 
                 inner join calculos_def cd on cg.calculo = cd.calculo
                 inner join grupos g on g.agrupacion=cg.agrupacion and g.grupo=cg.grupo
                 left join calgru co on co.agrupacion=cg.agrupacion and co.grupo=cg.grupo and co.calculo=vCalculoAnterior and co.periodo=vMesAnterior
                 left join calgru ca on ca.agrupacion=cg.agrupacion and ca.grupo=cg.grupo and ca.calculo=cg.calculo 
                                     and ca.periodo =(('a' || (substr(cg.periodo, 2, 4)::integer - 1)) ||'m12')
                 left join calgru cb on cb.agrupacion=cg.agrupacion and cb.grupo=cg.grupo and cb.calculo=cg.calculo 
                                     and cb.periodo =periodo_igual_mes_anno_anterior(cg.periodo)
                 left join cuagru on cg.agrupacion = cuagru.agrupacion and cg.grupo = cuagru.grupo and cuagru.cuadro = p_cuadro                                     
                 where cg.agrupacion= parametro4
                   and cg.nivel <= parametro3
                   and cd.principal
                   and cg.periodo=p_Periodo
                   and (p_cuadro <> 'A2bis' or cuagru.cuadro is not null) 
                   and ((pempalmehasta and cg.periodo <= pperiodoempalme) or 
                        (pempalmedesde and cg.periodo >=  pperiodoempalme));
  -- */
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_iivv('Nivel general y capitulos'        , 'a2022m01', 1, 'Z', true, '1' , true, false, 'a2022m02', ',');  --cuadro 1
--SELECT * from cvp.res_cuadro_iivv('Nivel general y Aperturas'        , 'a2022m01', 3, 'Z', true, 'A2', true, false, 'a2022m02', ',');  --cuadro A2
--SELECT * from cvp.res_cuadro_iivv('Nivel general, bienes y servicios', 'a2022m01', 1, 'S', true, '2' , true, false, 'a2022m02', ',');  --cuadro 2
