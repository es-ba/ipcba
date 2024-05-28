set search_path = cvp;

UPDATE cuadros set pie1 = '...  dato no disponible a la fecha de presentación de los resultados.¹ Base 2021 = 100. ' 
WHERE CUADRO in ('1a','1','A2bis','2_pi','8_pi');

UPDATE cuadros set 
encabezado = 'Cuadro LH||| IPCBA. Canasta alimentaria y Canasta total para hogares tipo. Ciudad de Buenos Aires'
WHERE cuadro = 'LH';

update cuadros set descripcion = 'Incidencia de los Bienes y Servicios en el Nivel General' where cuadro = '4bh';
update cuadros set parametro1 = 'Nivel General, Estacionales, Regulados y Resto IPCBA' where cuadro = '9b';
update cuadros set parametro1 = 'Nivel General, Bienes y Servicios'  where cuadro = '4bh';

update cuadros set parametro1 = 'Nivel General, Bienes y Servicios' where cuadro='2_pi';
update cuadros set parametro1 = 'Nivel General, Estacionales, Regulados y Resto IPCBA' where cuadro='8_pi';

CREATE OR REPLACE FUNCTION cvp.res_cuadro_ii(
    parametro1 text,
    p_periodo text,
    parametro3 integer,
    parametro4 text,
    pponercodigos boolean,
    p_cuadro text, 
    pempalmedesde boolean,
    pempalmehasta boolean,
    pperiodoempalme text,
    p_separador text)
  RETURNS SETOF cvp.res_col4 
  language plpgsql
  AS
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
    
  return query select 0::bigint,
                      'anchos'::text,
                      'auto'::text,
                      'auto'::text,
                      vAnchoNumeros,
                      vAnchoNumeros;
  return query select 1::bigint,
                      'U5.6.'::text,
                      parametro1::text,
                      null::text, 
                      devolver_mes_anio(p_periodo)::text,
                      null::text;
  return query select 2::bigint,
                     'P..RR'::text,
                     null::text,
                     null::text, 
                     'Mensual'::text,
                     'Interanual'::text;
  return query select row_number() over (order by cg.grupo)+100,
                      case when (cg.nivel=0 and p_cuadro in ('1a')) then 'N.2nn' 
                           when pPonerCodigos then 'D11nn' else 'D.2nn' end as formato_renglon,
                      case when pPonerCodigos and cg.nivel<>0 then case when substr(cg.grupo,2,1)::integer <1 
                                                                        then substr(cg.grupo,3)::text 
                                                                        else substr(cg.grupo,2)::text end
                           else null end as grupo, 
                      overlay(lower(nombregrupo) placing upper(substr(nombregrupo,1,1)) from 1 for 1)::text,
                      replace(cg.incidenciaredondeada::text,'.',p_separador)::text, 
                      case when pempalmedesde and cg.periodo <= moverperiodos(pperiodoempalme,11) then '...' else replace(cg.incidenciainteranualredondeada::text,'.',p_separador)::text end
                 from calGru_vw cg
                 inner join calculos_def cd on cg.calculo = cd.calculo
                 inner join grupos g on g.agrupacion=cg.agrupacion and g.grupo=cg.grupo
                 left join cuagru on cg.agrupacion = cuagru.agrupacion and cg.grupo = cuagru.grupo and cuagru.cuadro = p_cuadro
                 where cg.agrupacion= parametro4
                   and cg.nivel <= parametro3
                   and cd.principal
                   and cg.periodo=p_Periodo
                   and ((pempalmehasta and cg.periodo <= pperiodoempalme) or 
                        (pempalmedesde and cg.periodo >  pperiodoempalme));
end;
$BODY$;
-----------------------------------------------------
create or replace function res_cuadro_matriz_i(parametro1 text, p_periodo text, parametro3 integer, parametro4 text, pPonerCodigos boolean, p_cuadro text, pCantDecimales integer, pdesde text, porden text,
                                        pempalmedesde boolean, pempalmehasta boolean, pperiodoempalme text, p_separador text)
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
    v_periodo_tope_inf text:= case when p_cuadro = '3h_ia' then moverperiodos(pperiodoempalme, 12) 
                                   when p_cuadro in ('3h', '4bh','9b') then moverperiodos(pperiodoempalme, 1)
                                   else pperiodoempalme end;

    
begin
  return query select 'anchos'::text as formato_renglon,'auto'::text,'auto'::text,null::text,vAnchoNumeros;
  return query select v_formato_renglon_cabezal::text as formato_renglon,parametro1::text,null::text, null::text, null::text;
  return query select formato_renglon, grupo, nombregrupo, nombreperiodo, case when p_cuadro in ('A2bish', 'A2bish_con', 'A2bish_tot') then indicered else incidenciared end 
                from (
                select case when porden = 'desc' then row_number() over (order by periodo desc ,q.ordenpor)+100 
                         else row_number() over (order by periodo, q.ordenpor)+100 end,
                    q.formato_renglon, q.grupo, q.nombregrupo,
                    q.nombreperiodo, q.incidenciared, q.indicered
                 from (select
                       case when i.nivel=0 then 'N.2n' 
                            when pPonerCodigos then 'D11n' 
                            else 'D.2n' 
                       end as formato_renglon,
                       case when pPonerCodigos and i.nivel<>0 then 
                            case when p_cuadro like 'A2%' then i.grupo::text 
                                 else CASE WHEN substr(i.grupo,2,1)::integer <1 
                                      THEN substr(i.grupo,3)::text 
                                      ELSE substr(i.grupo,2)::text END
                            end                   
                       else null end as grupo, coalesce(cuagru.orden::text,i.grupo) as ordenpor, i.periodo,
                       overlay(lower(nombregrupo) placing upper(substr(nombregrupo,1,1)) from 1 for 1)::text as nombregrupo,
                       devolver_mes_anio(i.periodo) as nombreperiodo,
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
                   and ((pempalmehasta and i.periodo <= pperiodoempalme) or 
                        (pempalmedesde and i.periodo >=  v_periodo_tope_inf))
                        order by i.periodo, CASE WHEN p_cuadro = 'A2bish_con' THEN cuagru.orden::text ELSE i.grupo END) 
                as q) as x;
end;
$BODY$;
----------------------------------------------
--res_cuadro_ivebs
--UTF8=Sí
create or replace function res_cuadro_ivebs(parametro1 text, p_periodo_hasta text, parametro3 integer, parametro4 text, p_periodo_desde text,
                                            pempalmedesde boolean, pempalmehasta boolean, pperiodoempalme text, p_separador text) 
  returns setof res_col10
  language plpgsql
as
$BODY$
declare
    vAnchoNumeros text:='100';
    v_periodo_desde text;
begin
  
  v_periodo_desde := p_periodo_desde;
  return query select 0::bigint,'anchos'::text,'auto'::text,'auto'::text,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros, vAnchoNumeros, vAnchoNumeros;
  return query select 1::bigint, case when parametro4='S' then 'U5.7...7...'::text else 'U5.0...0...'::text end ,'Mes'::text, null::text,'Indice¹'::text,null::text, null::text, null::text,'Variación porcentual'::text,null::text, null::text, null::text;
  return query select 2::bigint, case when parametro4='S' then 'P..RRR.RRR.'::text else 'P..RRRRRRRR'::text end, null::text,null::text, 
               'Nivel General'::text, case when parametro4='S' then 'Bienes'::text  else 'Estacionales'::text end, 
                case when parametro4='S' then 'Servicios'::text else 'Regulados'::text end, 
                case when parametro4='S' then null::text  else 'Resto'::text end,
                'Nivel General'::text,
                case when parametro4='S' then 'Bienes'::text  else 'Estacionales'::text end, 
                case when parametro4='S' then 'Servicios'::text else 'Regulados'::text end, 
                case when parametro4='S' then null::text  else 'Resto'::text end;
  return query select row_number() over (order by c.periodo)+100, 
                 case when parametro4='S' then 'D11nnn.nnn.'::text  else 'D11nnnnnnnn'::text  end as formato_renglon,
                 --cvp.devolver_mes(c.periodo), case when p_periodo_hasta =c.periodo then substr(c.periodo,2,4)||'*' else substr(c.periodo,2,4) end, 
                 cvp.devolver_mes_anio(c.periodo),''::text, 
                 replace(round(c.indiceRedondeado::numeric,2)::text,'.',p_separador)::text, 
                 replace(round(b.indiceRedondeado::numeric,2)::text,'.',p_separador)::text  as indiceRedondeadobienes, 
                 replace(round(s.indiceRedondeado::numeric,2)::text,'.',p_separador)::text  as indiceRedondeadoserv,
                 case when parametro4='S' then null::text else  
                   replace(round(r.indiceRedondeado::numeric,2)::text,'.',p_separador)::text  end as indiceRedondeadoresto,  
                 case when co.indiceRedondeado=0 /*or c.periodo=v_periodo_desde*/ or c.periodo=pperiodoempalme then '...' 
                      else replace(round((c.indiceRedondeado/co.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,  
                 case when bo.indiceRedondeado=0 /*or c.periodo=v_periodo_desde*/ or c.periodo=pperiodoempalme then '...' 
                      else replace(round((b.indiceRedondeado/bo.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                 case when so.indiceRedondeado=0 /*or c.periodo=v_periodo_desde*/ or c.periodo=pperiodoempalme then '...' 
                      else replace(round((s.indiceRedondeado/so.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                 case when parametro4='S' then null::text else    
                 case when ro.indiceRedondeado=0 /*or c.periodo=v_periodo_desde*/ or c.periodo=pperiodoempalme then '...' 
                      else replace(round((r.indiceRedondeado/ro.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end  end 
                 from calgru c --nivel general
                 join calculos_def cd on c.calculo = cd.calculo
                 join calgru b on c.agrupacion=b.agrupacion and c.calculo=b.calculo and c.periodo=b.periodo  
                 join calgru s on c.agrupacion=s.agrupacion and c.calculo=s.calculo and c.periodo=s.periodo
                 join calgru r on c.agrupacion=r.agrupacion and c.calculo=r.calculo and c.periodo=r.periodo
                 join calculos ca  on ca.periodo=c.periodo and ca.calculo=c.calculo --pk verificada
                 left join calgru co on co.agrupacion=c.agrupacion and co.grupo=c.grupo and co.calculo=ca.calculoanterior and co.periodo=ca.periodoanterior 
                 left join calgru bo on bo.agrupacion=b.agrupacion and bo.grupo=b.grupo and bo.calculo=ca.calculoanterior and bo.periodo=ca.periodoanterior
                 left join calgru so on so.agrupacion=s.agrupacion and so.grupo=s.grupo and so.calculo=ca.calculoanterior and so.periodo=ca.periodoanterior 
                 left join calgru ro on ro.agrupacion=r.agrupacion and ro.grupo=r.grupo and ro.calculo=ca.calculoanterior and ro.periodo=ca.periodoanterior 
                 where c.agrupacion=parametro4 and cd.principal and c.periodo <= p_periodo_hasta and c.periodo >= v_periodo_desde and c.nivel=parametro3  
                   and b.grupo=parametro4||'1' 
                   and s.grupo=parametro4||'2'
                   and (case when c.agrupacion='S' then r.grupo='S1' else r.grupo='R3' end) 
                   and ((pempalmehasta and c.periodo <= pperiodoempalme) or 
                        (pempalmedesde and c.periodo >=  pperiodoempalme))
;    
end;
$BODY$;
----------------------------------------------------------
--res_cuadro_iivv
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
-----------------------------------------------
--res_cuadro_piivvi
create or replace function res_cuadro_piivvi(parametro1 text, p_periodo text, parametro3 integer, parametro4 text, pponercodigos boolean, p_cuadro text, 
                                             pempalmedesde boolean, pempalmehasta boolean, pperiodoempalme text, p_separador text)
  returns SETOF res_col9
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
    
  return query select 0::bigint,'anchos'::text,'auto'::text,'auto'::text,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros;
  return query select 1::bigint
                 , 'U5.86.7..86'::text
                 , parametro1::text,null::text
                 , 'Ponderación'::text
                 , 'Índice ¹'::text
                 , null::text,'Variación porcentual'::text,null::text, null::text
                 , 'Incidencia mensual'::text;
  return query select 2::bigint,'P...RRRRR.'::text,null::text,null::text, null::text
                 , devolver_mes_anio(p_periodo) 
                 , devolver_mes_anio(vMesAnterior),'Respecto del mes anterior'::text
                 , 'Acumulado anual'::text, 'Interanual'::text, null::text;
  return query select row_number() over (order by cg.grupo)+100,
                      case when cg.nivel=0 then 'N.3.nnnnnn'
                           when pPonerCodigos then 'D11nnnnnnn' 
                           else 'D.2nnnnnnn' end as formato_renglon,
                      case when pPonerCodigos and cg.nivel<>0 then 
                        case when substr(cg.grupo,2,1)::integer <1 then substr(cg.grupo,3)::text 
                          else substr(cg.grupo,2)::text end
                        else null end as grupo, 
                      overlay(lower(nombregrupo) placing upper(substr(nombregrupo,1,1)) from 1 for 1)::text,
                      replace(round((g.ponderador*100)::numeric,2)::text,'.',',')::text||' %'::text,
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
                        else replace(round((cg.indiceRedondeado/cb.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                      case when co.periodo < pperiodoempalme then '...'
                        else replace(cg.incidenciaredondeada::text,'.',p_separador)::text end
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
                   and ((pempalmehasta and cg.periodo <= pperiodoempalme) or 
                        (pempalmedesde and cg.periodo >=  pperiodoempalme))
                 ; 
end;
$BODY$;
---------------------------------------------
--res_cuadro_i
create or replace function res_cuadro_i(parametro1 text, p_periodo text, parametro3 integer, parametro4 text, pPonerCodigos boolean, pCantDecimales integer,
                                        pempalmedesde boolean, pempalmehasta boolean, pperiodoempalme text, p_separador text) 
  returns setof res_col3
  language plpgsql
as
$BODY$
declare
    vAgrupacionPrincipal text;
    vAnchoNumeros text:='100';

begin
  return query select 0::bigint,'anchos'::text,'auto'::text,'auto'::text,vAnchoNumeros;

  return query select 1::bigint,'U2.R'::text,parametro1::text,null::text, devolver_mes_anio(p_periodo);
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
                   and i.periodo=p_Periodo
                   and ((pempalmehasta and i.periodo <= pperiodoempalme) or 
                        (pempalmedesde and i.periodo >  pperiodoempalme));
end;
$BODY$;
------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cvp.res_cuadro_pp(parametro1 text, p_periodo text, pdesde text, pempalmedesde boolean, 
                                         pempalmehasta boolean, pperiodoempalme text, p_separador text)
  RETURNS SETOF res_mat2 
  language plpgsql
  AS
$BODY$
declare

    vAnchoNumeros text:='100';
    v_periodo_desde text:=pdesde;

begin
  return query select /*0::bigint,*/
                  'anchos'::text,
                  'auto'::text,
                  'auto'::text,
                  'auto'::text,
                  null::text,
                  vAnchoNumeros;

  return query select /*1::bigint,*/
                      'E1111'::text,
                      'Código de producto'::text,
                      'Descripción'::text,
                      'Unidad de medida'::text,
                      null::text,
                      'Precio relevado'::text;
  return query select /*row_number() over (order by q.ordenpor)+100,*/
                      q.formato_renglon, 
                      q.producto, q.nombreproducto, q.unidadmedidaabreviada, q.nombreperiodo, q.promprod
                 from 
                 (
                 select 
                    'D11Cn'::text as formato_renglon,
                    c.producto::text,
                    nombreproducto::text,
                    unidadmedidaabreviada::text,
                    devolver_mes_anio(periodo) as nombreperiodo,
                    replace(round(promDiv::numeric,2)::text,'.',p_separador) as promprod
                    /*,c.producto as ordenpor*/
                 from productos p inner join calDiv c on p.producto=c.producto and c.division='0'
                 inner join calculos_def cd on c.calculo = cd.calculo
                 where cd.principal and p."cluster" is distinct from 3
                   and periodo between v_periodo_desde and p_Periodo
                   and ((pempalmehasta and periodo <= pperiodoempalme) or 
                        (pempalmedesde and periodo >  pperiodoempalme))
                 order by c.producto, c.periodo
                ) as q
               ;
end;
$BODY$;

