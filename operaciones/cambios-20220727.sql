set search_path = cvp;

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

/****************************************************************************************************/
--res_cuadro_ii
--UTF8=Sí
CREATE OR REPLACE FUNCTION cvp.res_cuadro_ii(
    parametro1 text,
    p_periodo text,
    parametro3 integer,
    parametro4 text,
    pponercodigos boolean,
    p_cuadro text,
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
                      replace(cg.incidenciainteranualredondeada::text,'.',p_separador)::text                      
                 from calGru_vw cg
                 inner join calculos_def cd on cg.calculo = cd.calculo				 
                 inner join grupos g on g.agrupacion=cg.agrupacion and g.grupo=cg.grupo
                 left join cuagru on cg.agrupacion = cuagru.agrupacion and cg.grupo = cuagru.grupo and cuagru.cuadro = p_cuadro                                     
                 where cg.agrupacion= parametro4
                   and cg.nivel <= parametro3
                   and cd.principal
                   and cg.periodo=p_Periodo; 
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_ii('Nivel general y capitulos', 'a2022m05'::text, 1, 'Z'::text, true, '1a',',');  --cuadro 1a

/****************************************************************************************************/
--res_cuadro_iivv
--UTF8=Sí

create or replace function res_cuadro_iivv(parametro1 text, p_periodo text, parametro3 integer, parametro4 text, pponercodigos boolean, p_cuadro text, p_separador text)
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
                 , null::text,'Variación porcentual'||case when p_cuadro in ('1','A2bis') then ' *' else '' end::text
                 , null::text, null::text;
  return query select 2::bigint,'P...RRRRR'::text,null::text,null::text, null::text
                 , devolver_mes_anio(p_periodo)||' *'::text 
                 , devolver_mes_anio(vMesAnterior),'Respecto del mes anterior'::text --'Respecto de '||devolver_mes_anio(vMesAnterior)::text
                 , 'Acumulado Anual'::text, 'Interanual'::text;
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
                      replace(round(co.indiceRedondeado::numeric,2)::text,'.',p_separador)::text,
                      case when co.indiceRedondeado=0 then null 
                        else replace(round((cg.indiceRedondeado/co.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                      case when ca.indiceRedondeado=0 then null 
                        else replace(round((cg.indiceRedondeado/ca.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                      case when cb.indiceRedondeado=0 then null 
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
                   and (p_cuadro <> 'A2bis' or cuagru.cuadro is not null); 
  -- */
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_iivv('Nivel general y capitulos', 'a2022m05'::text, 1, 'Z'::text, true, '1',',');  --cuadro 1
--SELECT * from cvp.res_cuadro_iivv('Nivel general y Aperturas', 'a2022m05'::text, 3, 'Z'::text, true, 'A2',',');  --cuadro A2
--SELECT * from cvp.res_cuadro_iivv('Nivel general, bienes y servicios', 'a2022m05'::text, 1, 'S'::text, true, '2',',');  --cuadro 2

/****************************************************************************************************/
--res_cuadro_ivebs
--UTF8=Sí
create or replace function res_cuadro_ivebs(parametro1 text, p_periodo_hasta text, parametro3 integer, parametro4 text, p_periodo_desde text, p_separador text) 
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
                 cvp.devolver_mes_anio(c.periodo)||case when p_periodo_hasta =c.periodo then '*' else '' end,''::text, 
                 replace(round(c.indiceRedondeado::numeric,2)::text,'.',p_separador)::text, 
                 replace(round(b.indiceRedondeado::numeric,2)::text,'.',p_separador)::text  as indiceRedondeadobienes, 
                 replace(round(s.indiceRedondeado::numeric,2)::text,'.',p_separador)::text  as indiceRedondeadoserv,
                 case when parametro4='S' then null::text else  
                   replace(round(r.indiceRedondeado::numeric,2)::text,'.',p_separador)::text  end as indiceRedondeadoresto,  
                 case when co.indiceRedondeado=0 or c.periodo=v_periodo_desde then '...' 
                      else replace(round((c.indiceRedondeado/co.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,  
                 case when bo.indiceRedondeado=0 or c.periodo=v_periodo_desde then '...' 
                      else replace(round((b.indiceRedondeado/bo.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                 case when so.indiceRedondeado=0 or c.periodo=v_periodo_desde then '...' 
                      else replace(round((s.indiceRedondeado/so.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                 case when parametro4='S' then null::text else    
                 case when ro.indiceRedondeado=0 or c.periodo=v_periodo_desde then '...' 
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
                   and (case when c.agrupacion='S' then r.grupo='S1' else r.grupo='R3' end) ;    
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_ivebs('Mes', 'a2022m05'::text, 0, 'S'::text, 'a2022m01'::text,',');  --cuadro A1

/****************************************************************************************************/
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
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as cabezal1,
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
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as cabezal1,
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
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as cabezal1,
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
/****************************************************************************************************/
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
/****************************************************************************************************/
--res_cuadro_matriz_hogar
--UTF8=Sí

create or replace function res_cuadro_matriz_hogar(parametro1 text, p_periodo text, parametro4 text, p_cuadro text, parametro6 integer, p_separador text) 
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
                      replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador) as celda
                 from valorizacion_canasta_cuadros v --inner join grupos g on v.agrupacion = g.agrupacion and v.grupo = g.grupo
                  join calculos_def cd on v.calculo = cd.calculo
                 where ((p_cuadro <> 'CC' and v.agrupacion = parametro4) or (p_cuadro = 'CC' and ((v.agrupacion = 'D' and v.grupo in ('D1', 'D5')) OR (v.agrupacion = parametro4 and v.grupo in ('A1', 'A5'))))) 
                   and cd.principal
                   and v.periodo = p_periodo
                   and replace(replace(v.hogar,'5b','5.1'),'Hogar ','')::numeric < parametro6
                 ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, comun.para_ordenar_numeros(v.hogar);
end;
$BODY$;

--test 
--SELECT * from cvp.res_cuadro_matriz_hogar('Listado de Valorización de la Canasta', 'a2022m05'::text, 'A'::text, 'HH', 18, ',');  
--SELECT * from cvp.res_cuadro_matriz_hogar('Listado de Valorización de la Canasta para 5 hogares', 'a2022m05'::text, 'A'::text, 'HH', 6,',');  

/****************************************************************************************************/
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

/****************************************************************************************************/
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

/****************************************************************************************************/
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

/****************************************************************************************************/
--res_cuadro_matriz_ingreso
CREATE OR REPLACE FUNCTION res_cuadro_matriz_ingreso(parametro1 text, p_periodo text, p_hogar text, p_periododesde text, p_separador text)
  returns setof cvp.res_mat
  language plpgsql
as
$BODY$
declare
    v_formato_renglon text:='DW1n'; -- solo pongo letras para: el tipo de renglón, las columas laterales y una más para todos los datos.
    v_formato_renglon_cabezal text:='E111'; -- idem


begin
  return query select 'anchos'::text as formato_renglon,
                      'auto'::text, 
                      'auto'::text,
                      null::text,
                      100::text;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
                      'Mes'::text, 
                      'Estrato'::text, 
                      null::text,
                      null::text;

  return query  SELECT formato_renglon, lateral1, lateral2, cabezal1, celda from (
                SELECT v_formato_renglon::text as formato_renglon, x.orden, v.periodo,
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as lateral1,
                  X.nombre as lateral2,
                  'Mínimo' as cabezal1,
                  CASE WHEN nombre = 'En situación de indigencia'           THEN '0'||p_separador||'00'::text
                       WHEN nombre = 'En situación de pobreza no indigente' THEN replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'No pobres vulnerables'                THEN replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sector medio frágil'                  THEN replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sector medio - "Clase media"'         THEN replace(round((1.25*round(v.valorhoggru::numeric,2))::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sectores acomodados'                  THEN replace(round((4*   round(v.valorhoggru::numeric,2))::numeric,2)::text,'.',p_separador) end as celda
                  FROM 
                    (SELECT 1 as orden, 'En situación de indigencia'           AS nombre,	'D1' as grupominimo,	'D1' as grupomaximo UNION
                    SELECT  2 as orden, 'En situación de pobreza no indigente' AS nombre,	'D1' as grupominimo,	'D5' as grupomaximo UNION
                    SELECT  3 as orden, 'No pobres vulnerables'                AS nombre, 	'D5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  4 as orden, 'Sector medio frágil'                  AS nombre,	'A5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  5 as orden, 'Sector medio - "Clase media"'         AS nombre,	'A5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  6 as orden, 'Sectores acomodados'                  AS nombre, 	'A5' as grupominimo,	'A5' as grupomaximo) as X
                    left join valorizacion_canasta_cuadros v  on X.grupominimo = v.grupo 
                    left join valorizacion_canasta_cuadros v1 on v.periodo = v1.periodo /*and v.agrupacion = v1.agrupacion*/ and X.grupomaximo = v1.grupo
                               and v.calculo = v1.calculo and v.hogar = v1.hogar
				    join calculos_def cd on v.calculo = cd.calculo
                  WHERE v.agrupacion in ('A','D') 
                        and v.grupo in ('A1','A5', 'D1', 'D5')
                        and cd.principal
                        and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                        and v.hogar = p_hogar --tiene que ser parametro
                Union
                SELECT v_formato_renglon::text as formato_renglon, x.orden, v.periodo,
                  devolver_mes_anio(v.periodo)||CASE WHEN v.periodo=p_periodo THEN '***' ELSE '' END as lateral1,
                  X.nombre as lateral2,
                  'Máximo' as cabezal1,
                  CASE WHEN nombre = 'En situación de indigencia'           THEN replace(round((v1.valorhoggru-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'En situación de pobreza no indigente' THEN replace(round((v1.valorhoggru-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'No pobres vulnerables'                THEN replace(round((v1.valorhoggru-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sector medio frágil'                  THEN replace(round(((1.25*round(v1.valorhoggru::numeric,2))-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sector medio - "Clase media"'         THEN replace(round(((4*   round(v1.valorhoggru::numeric,2))-0.01)::numeric,2)::text,'.',p_separador)
                       WHEN nombre = 'Sectores acomodados'                  THEN 'Mas'::text end as celda
                  FROM 
                    (SELECT 1 as orden, 'En situación de indigencia'           AS nombre,	'D1' as grupominimo,	'D1' as grupomaximo UNION
                    SELECT  2 as orden, 'En situación de pobreza no indigente' AS nombre,	'D1' as grupominimo,	'D5' as grupomaximo UNION
                    SELECT  3 as orden, 'No pobres vulnerables'                AS nombre, 	'D5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  4 as orden, 'Sector medio frágil'                  AS nombre,	'A5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  5 as orden, 'Sector medio - "Clase media"'         AS nombre,	'A5' as grupominimo,	'A5' as grupomaximo UNION
                    SELECT  6 as orden, 'Sectores acomodados'                  AS nombre, 	'A5' as grupominimo,	'A5' as grupomaximo) as X
                    left join valorizacion_canasta_cuadros v  on X.grupominimo = v.grupo
                    join calculos_def cd on v.calculo = cd.calculo					
                    left join valorizacion_canasta_cuadros v1 on v.periodo = v1.periodo /*and v.agrupacion = v1.agrupacion*/ and X.grupomaximo = v1.grupo
                               and v.calculo = v1.calculo and v.hogar = v1.hogar
                  WHERE v.agrupacion in ('A','D') 
                        and v.grupo in ('A1','A5', 'D1', 'D5')
                        and cd.principal
                        and v.periodo between p_periododesde and p_periodo /* TIENE QUE SER PARAMETRO p_periodo*/
                        and v.hogar = p_hogar --tiene que ser parametro
                  ) resp
                  ORDER BY periodo, orden, cabezal1 desc;
end;
$BODY$;

--test
--SELECT * from res_cuadro_matriz_ingreso('Listado de Valorización de la Canasta', 'a2022m05'::text, 'Hogar 1', 'a2022m01'::text, '.');  
--SELECT * from res_cuadro_matriz_ingreso('Listado de Valorización de la Canasta', 'a2022m05'::text, 'Hogar 1', 'a2022m01'::text, '.');

/****************************************************************************************************/
--res_cuadro_matriz_linea
create or replace function res_cuadro_matriz_linea(parametro1 text, p_periodo text, parametro4 text, p_cuadro text, parametro6 integer, p_separador text) 
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
                      'Hogar'::text, 
                      'Descripción'::text,
                      null::text,
                      null::text;
  return query select v_formato_renglon::text as formato_renglon,
                      v.hogar::text as lateral1,
                      h.nombrehogar::text as lateral2, --v.grupo::text as lateral2,
                      CASE WHEN v.nivel = 1 THEN v.nombrecanasta 
                                            ELSE v.nombregrupo END ::text as cabezal1,
                      replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador) as celda
                 from valorizacion_canasta_cuadros v --inner join grupos g on v.agrupacion = g.agrupacion and v.grupo = g.grupo
                      inner join calculos_def cd on v.calculo = cd.calculo
					  inner join cvp.hogares h on v.hogar = h.hogar 
                 where --((p_cuadro <> 'LH' and v.agrupacion = parametro4) or (p_cuadro = 'LH' and ((v.agrupacion = 'D' and v.grupo in ('D1', 'D5')) OR (v.agrupacion = parametro4 and v.grupo in ('A1', 'A5'))))) 
                   v.agrupacion = parametro4 and v.grupo in ('A1', 'A5', 'D1', 'D5')
                   and cd.principal
                   and v.periodo = p_periodo
                   and replace(replace(v.hogar,'5b','5.1'),'Hogar ','')::numeric < parametro6
                 ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, comun.para_ordenar_numeros(v.hogar);
end;
$BODY$;
--test
--SELECT * from cvp.res_cuadro_matriz_linea('Listado de Valorización de la Canasta', 'a2022m05'::text, 'A'::text, 'LH', 18, ',');  
--SELECT * from cvp.res_cuadro_matriz_linea('Listado de Valorización de la Canasta para 5 hogares', 'a2022m05'::text, 'A'::text, 'LH', 6,',');  
--SELECT * from cvp.res_cuadro_matriz_linea('Listado de Valorización de la Canasta para 5 hogares', 'a2022m04'::text, 'D'::text, 'LH', 6,',');  
/****************************************************************************************************/
--res_cuadro_matriz_linea_var
create or replace function res_cuadro_matriz_linea_var(parametro1 text, p_periodo text, parametro4 text, p_cuadro text, parametro6 integer, p_periododesde text, p_separador text) 
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
                      'Hogar'::text, 
                      'Descripción'::text,
                      null::text,
                      null::text;
  return query select v_formato_renglon::text as formato_renglon,
                      v.hogar::text as lateral1,
                      h.nombrehogar::text as lateral2, --v.grupo::text as lateral2,
                      CASE WHEN v.nivel = 1 THEN v.nombrecanasta 
                                            ELSE v.nombregrupo END ::text as cabezal1,
                      --replace(round(v.valorhoggru::numeric,2)::text,'.',p_separador) as celda
                      case when v1.valorhoggru = 0 then '0'||p_separador||'0'::text else
                      replace(round((round(v.valorhoggru::numeric,2)/round(v1.valorhoggru::numeric,2)*100-100),1)::text,'.',p_separador) end as celda
                 from (select * from valorizacion_canasta_cuadros where periodo = p_periodo) v --inner join grupos g on v.agrupacion = g.agrupacion and v.grupo = g.grupo
                      left join (select * from valorizacion_canasta_cuadros where periodo = p_periododesde) v1 
                        on v.calculo = v1.calculo and v.agrupacion = v1.agrupacion and v.grupo = v1.grupo and v.hogar = v1.hogar
                      inner join cvp.hogares h on v.hogar = h.hogar
                      inner join calculos_def cd on v.calculo = cd.calculo					  
                 where --((p_cuadro <> 'LH' and v.agrupacion = parametro4) or (p_cuadro = 'LH' and ((v.agrupacion = 'D' and v.grupo in ('D1', 'D5')) OR (v.agrupacion = parametro4 and v.grupo in ('A1', 'A5'))))) 
                   v.agrupacion = parametro4 and v.grupo in ('A1', 'A5', 'D1', 'D5')
                   and cd.principal
                   and v.periodo = p_periodo
                   and replace(replace(v.hogar,'5b','5.1'),'Hogar ','')::numeric < parametro6
                 ORDER BY v.agrupacion, substr(v.grupo,1,2), v.nivel DESC NULLS LAST, v.grupo, comun.para_ordenar_numeros(v.hogar);
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_matriz_linea_var('Listado de Valorización de la Canasta', 'a2022m05'::text, 'A'::text, 'LH', 18,'a2022m03'::text, ',');  
--SELECT * from cvp.res_cuadro_matriz_linea_var('Listado de Valorización de la Canasta para 5 hogares', 'a2022m05'::text, 'A'::text, 'LH', 6,'a2022m03'::text,',');  
--SELECT * from cvp.res_cuadro_matriz_linea_var('Listado de Valorización de la Canasta para 5 hogares', 'a2022m05'::text, 'D'::text, 'LH', 6,'a2022m03'::text,',');  
/****************************************************************************************************/
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

/****************************************************************************************************/
--res_cuadro_piivvi
create or replace function res_cuadro_piivvi(parametro1 text, p_periodo text, parametro3 integer, parametro4 text, pponercodigos boolean, p_cuadro text, p_separador text)
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
    where c.periodo=p_periodo AND c.calculo=0 AND c.calculo= cd.calculo;
    
  return query select 0::bigint,'anchos'::text,'auto'::text,'auto'::text,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros,vAnchoNumeros;
  return query select 1::bigint
                 , 'U5.86.7..86'::text
                 , parametro1::text,null::text
                 , 'Ponderación'::text
                 , 'Índice ¹'::text
                 , null::text,'Variación porcentual *'::text,null::text, null::text
                 , 'Incidencia mensual *'::text;
  return query select 2::bigint,'P...RRRRR.'::text,null::text,null::text, null::text
                 , devolver_mes_anio(p_periodo)||' *'::text 
                 , devolver_mes_anio(vMesAnterior),'Respecto del mes anterior'::text
                 , 'Acumulado Anual'::text, 'Interanual'::text, null::text;
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
                      replace(round(co.indiceRedondeado::numeric,2)::text,'.',p_separador)::text,
                      case when co.indiceRedondeado=0 then null 
                        else replace(round((cg.indiceRedondeado/co.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                      case when ca.indiceRedondeado=0 then null 
                        else replace(round((cg.indiceRedondeado/ca.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,
                      case when cb.indiceRedondeado=0 then null 
                        else replace(round((cg.indiceRedondeado/cb.indiceRedondeado*100-100)::numeric,1)::text,'.',p_separador)::text end,    
                      replace(cg.incidenciaredondeada::text,'.',p_separador)::text
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
                   ; 
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_piivvi('Nivel general, bienes y servicios', 'a2022m04'::text, 1, 'S'::text, true, '2_pi',',');  --cuadro 2_pi
--SELECT * from cvp.res_cuadro_piivvi('Nivel general, bienes y servicios', 'a2022m04'::text, 1, 'R'::text, true, '8_pi',',');  --cuadro 8_pi

/****************************************************************************************************/
--res_cuadro_pp
CREATE OR REPLACE FUNCTION cvp.res_cuadro_pp(parametro1 text, p_periodo text, pdesde text, p_separador text)
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
                      'Código de Producto'::text,
                      'Descripción'::text,
                      'Unidad de Medida'::text,
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
                 where cd.principal
                   and periodo between v_periodo_desde and p_Periodo
                 order by c.producto, c.periodo
                ) as q
               ;
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_pp(' ', 'a2022m04', 'a2022m01', ',');
/****************************************************************************************************/
--res_cuadro_up
create or replace function res_cuadro_up(parametro1 text, p_periodo text, parametro4 text, pPonercodigos boolean, p_separador text) 
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
  return query select row_number() over (order by q.ordenpor)+100,
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
                    grupopadre||producto::text as ordenpor
                 from preciosmedios_albs_var p 
				 join calculos_def cd on p.calculo = cd.calculo
                 where gruponivel1 = parametro4
                   and cd.principal
                   and periodo=p_Periodo
               
                 union
                 select distinct --row_number() over (ordenpor)+100, 
                    'G.2..' as formato_renglon, 
                    grupopadre, 
                    null as producto, 
                    substr(nombregrupopadre,1,1)||lower(substr(nombregrupopadre,2)) as nombreproducto, 
                    null as unidadmedidaabreviada, 
                    null as promprod,
                    grupopadre||'P0000000'::text as ordenpor
                 from preciosmedios_albs_var p 
				 join calculos_def cd on p.calculo = cd.calculo
                 where gruponivel1 = parametro4
                   and cd.principal
                   and periodo=p_periodo
                ) as q
               ;
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_up(null, 'a2022m03'::text, 'C2',true, ',');  --Invocacion cuadros Cuadro I. Precios medios relevados de bienes y servicios. Ciudad de Buenos Aires
--SELECT * from cvp.res_cuadro_up(null, 'a2022m03'::text, 'C1',true, ',');  --Invocacion cuadros: Cuadro II. Precios medios relevados de productos alimenticios. Ciudad de Buenos Aires
/****************************************************************************************************/
--res_cuadro_vc
CREATE OR REPLACE FUNCTION cvp.res_cuadro_vc(
    parametro1 text,
    p_periodo text,
    parametro3 integer,
    parametro4 text,
    pponercodigos boolean,
    p_cuadro text,
    pdesde text, 
    p_separador text)
  RETURNS SETOF cvp.res_mat 
  language plpgsql
AS
$BODY$
declare
    vAnchoNumeros text:='100';
    v_periodo_desde text := pdesde;
begin
  
  return query select /*0::bigint,*/ 'anchos'::text,'auto'::text,'auto'::text, null::text, vAnchoNumeros;
  return query select /*1::bigint,*/ case when pPonerCodigos then'ULLR'::text else 'U2.R' end, 
                                 case when pPonerCodigos then 'Código'::text else 'Descripción'::text end,  
                                 case when pPonerCodigos then 'Descripción'::text else null end, null::text, 'Valorgru'::text;
  return query select /*row_number() over (order by c.grupo, c.periodo)+100,*/ 
                      case when pPonerCodigos then 'D11n'::text else 'D.2n'::text end as formato_renglon,
                      case when pPonerCodigos then c.grupo::text /*substr(c.grupo,2)::text*/ else null end as grupo,
                      g.nombregrupo::text, devolver_mes_anio(c.periodo)||case when c.periodo=p_Periodo then ' *'::text else ''::text end as nombreperiodo,
                      --replace(round(c.valorgru::numeric,2)::text, '.',p_separador) as valorgru
                      replace(round((CASE WHEN p_cuadro = 'X1' then c.valorgru ELSE c.valorgrupromedio END)::numeric,2)::text, '.',p_separador) as valorgru
                 from calGru_promedios c inner join calculos_def cd on c.calculo = cd.calculo inner join cvp.grupos g on c.agrupacion=g.agrupacion and c.grupo=g.grupo
                 where periodo between v_periodo_desde and p_Periodo
                   and cd.principal
                   and c.agrupacion=parametro4
                   and (c.nivel=parametro3 and c.grupopadre in ('A31','A32','A51','D31','D51')
                       or c.nivel=parametro3-1 and c.grupo not in ('A31','A32','A51','D31','D51'))
                 order by c.grupo, c.periodo;
end;
$BODY$;

--test
--Invocacion cuadro Cuadro X1. Exportación valores de canasta para CEDEM
--SELECT * from cvp.res_cuadro_vc(null, 'a2022m05'::text, 3, 'A', true,'X1','a2013m01',',');
--SELECT * from cvp.res_cuadro_vc(null, 'a2022m05'::text, 3, 'A', true,'X2','a2013m01',',');