set search_path =cvp;
--en ambas bases:
ALTER TABLE cuadros ADD COLUMN empalmedesde boolean;
ALTER TABLE cuadros ADD COLUMN empalmehasta boolean;

UPDATE cuadros set empalmedesde = false;
UPDATE cuadros set empalmehasta = false;

ALTER TABLE cuadros_funciones ADD COLUMN usa_empalmedesde boolean;
ALTER TABLE cuadros_funciones ADD COLUMN usa_empalmehasta boolean;

UPDATE cuadros_funciones set usa_empalmedesde = false;
UPDATE cuadros_funciones set usa_empalmehasta = false;
--FILTRO POR PERIODOS VÁLIDOS SEGÚN PERIODO EMPALME (TABLA parametros)
--CUADROS PRECIOS PROMEDIOS
--version ipc4:
UPDATE cuadros set empalmedesde = true WHERE funcion in ('res_cuadro_up','res_cuadro_matriz_up','res_cuadro_pp');
UPDATE cuadros_funciones set usa_empalmedesde = true, usa_empalmehasta = true WHERE funcion in ('res_cuadro_up','res_cuadro_matriz_up','res_cuadro_pp');

UPDATE cuadros set empalmedesde = true WHERE funcion in ('res_cuadro_iivv','res_cuadro_ii','res_cuadro_piivvi','res_cuadro_i','res_cuadro_matriz_i','res_cuadro_ivebs');
UPDATE cuadros_funciones set usa_empalmedesde = true, usa_empalmehasta = true WHERE funcion in ('res_cuadro_iivv','res_cuadro_ii','res_cuadro_piivvi','res_cuadro_i','res_cuadro_matriz_i','res_cuadro_ivebs');

set role cvpowner;
drop function if exists res_cuadro_up;
drop function if exists res_cuadro_matriz_up;
drop function if exists res_cuadro_pp;
drop function if exists res_cuadro_iivv;
drop function if exists res_cuadro_ii;
drop function if exists res_cuadro_piivvi;
drop function if exists res_cuadro_i;
drop function if exists res_cuadro_matriz_i;
drop function if exists res_cuadro_ivebs;


--res_cuadro_up
create or replace function res_cuadro_up(parametro1 text, p_periodo text, parametro4 text, pPonercodigos boolean, pempalmedesde boolean, 
                                         pempalmehasta boolean, pperiodoempalme text, p_separador text) 
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
  return query select row_number() over (order by q.grupopadre, q.orden, q.producto)+100,
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
                    grupopadre||producto::text as ordenpor, coalesce(cg.orden, 0) as orden
                 from preciosmedios_albs_var p 
                 join calculos_def cd on p.calculo = cd.calculo
                 left join cuagru cg on p.agrupacion = cg.agrupacion and p.producto = cg.grupo and cg.cuadro = CASE WHEN parametro4 = 'C1' THEN '7' ELSE '6' END
                 where gruponivel1 = parametro4
                   and cd.principal
                   and periodo=p_Periodo
                   and ((pempalmehasta and periodo <= pperiodoempalme) or 
                        (pempalmedesde and periodo >  pperiodoempalme))
               
                 union
                 select distinct --row_number() over (ordenpor)+100, 
                    'G.2..' as formato_renglon, 
                    grupopadre, 
                    'Q0000000' as producto,
                    substr(nombregrupopadre,1,1)||lower(substr(nombregrupopadre,2)) as nombreproducto, 
                    null as unidadmedidaabreviada, 
                    null as promprod,
                    grupopadre||'Q0000000'::text as ordenpor, 0 AS orden
                 from preciosmedios_albs_var p 
                 join calculos_def cd on p.calculo = cd.calculo
                 where gruponivel1 = parametro4
                   and cd.principal
                   and periodo=p_periodo
                   and ((pempalmehasta and periodo <= pperiodoempalme) or 
                        (pempalmedesde and periodo >  pperiodoempalme))
                ) as q
               ;
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_up(null, 'a2022m03'::text, 'C2',true, true, false , 'a2022m02',',');  --Invocacion cuadros Cuadro I. Precios medios relevados de bienes y servicios. Ciudad de Buenos Aires
--SELECT * from cvp.res_cuadro_up(null, 'a2022m03'::text, 'C1',true, true, false , 'a2022m02',',');  --Invocacion cuadros: Cuadro II. Precios medios relevados de productos alimenticios. Ciudad de Buenos Aires
------------------------------------------------------
--res_cuadro_matriz_up
create or replace function res_cuadro_matriz_up(parametro1 text, p_periodo text, parametro4 text, pPonerCodigos boolean, pdesde text, porden text,
                                                pempalmedesde boolean, pempalmehasta boolean, pperiodoempalme text, p_separador text) 
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
                select case when porden = 'desc' then row_number() over (order by periodo desc , q.grupopadre, q.orden, q.producto)+100 
                         else row_number() over (order by periodo, q.grupopadre, q.orden, q.producto)+100 end,
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
                    /*periodo||*/p.grupopadre||producto::text as ordenpor, coalesce(cg.orden, 0) as orden
                 from preciosmedios_albs_var p
                      join calculos_def cd on p.calculo = cd.calculo
                      left join gru_grupos g on g.agrupacion = 'E' and g.grupo = p.producto 
                      left join cvp.grupos u on g.agrupacion = u.agrupacion and g.grupo_padre = u.grupo
                      left join cuagru cg on p.agrupacion = cg.agrupacion and p.producto = cg.grupo and cg.cuadro = CASE WHEN parametro4 = 'C1' THEN '7h' 
                                                                                                                         WHEN parametro4 = 'C2' THEN '6h'
                                                                                                                         WHEN parametro4 = 'E1' THEN '7hApp'
                                                                                                                         ELSE '6hApp' END
                 where (gruponivel1 = parametro4 or g.grupo_padre = parametro4)
                   and cd.principal and coalesce(u.nivel,1) = 1
                   and periodo between v_periodo_desde and p_Periodo
                   and ((pempalmehasta and periodo <= pperiodoempalme) or 
                        (pempalmedesde and periodo >  pperiodoempalme))
               
                 union
                 select distinct  
                    v_formato_renglon_padres::text as formato_renglon,
                    p.grupopadre, 
                    'Q0000000' as producto, 
                    substr(nombregrupopadre,1,1)||lower(substr(nombregrupopadre,2)) as nombreproducto, 
                    null as unidadmedidaabreviada,
                    periodo,
                    null as promprod,
                    /*periodo||*/p.grupopadre||'Q0000000'::text as ordenpor, 0 as orden
                 from preciosmedios_albs_var p
                      join calculos_def cd on p.calculo = cd.calculo
                      left join gru_grupos g on g.agrupacion = 'E' and g.grupo = p.producto 
                      left join cvp.grupos u on g.agrupacion = u.agrupacion and g.grupo_padre = u.grupo 
                 where (gruponivel1 = parametro4 or g.grupo_padre = parametro4)
                   and cd.principal
                   and periodo between v_periodo_desde and p_Periodo
                   and ((pempalmehasta and periodo <= pperiodoempalme) or 
                        (pempalmedesde and periodo >  pperiodoempalme))
               ) as d order by d.grupopadre, d.orden, d.producto, periodo) as q) as x
               ;
end;
$BODY$;
--test 
--SELECT * from cvp.res_cuadro_matriz_up('Precios Medios Bienes y Servicios','a2022m05'::text, 'C2',true,'a2022m01','asc', true, false , 'a2022m02',',');  
--SELECT * from cvp.res_cuadro_matriz_up('Precios medios Alimentos','a2022m05'::text, 'C1',true,'a2022m01','asc', true, false , 'a2022m02',',');  
--SELECT * from cvp.res_cuadro_matriz_up('Precios Medios Bienes y Servicios','a2022m05'::text, 'C2',false,'a2022m01','desc', true, false , 'a2022m02',',');  
--SELECT * from cvp.res_cuadro_matriz_up('Precios medios Alimentos','a2022m05'::text, 'C1',false,'a2022m01','desc', true, false , 'a2022m02',',');  

--SELECT * from cvp.res_cuadro_matriz_up('Precios Medios Bienes y Servicios','a2022m05'::text, 'E2',false,'a2022m01','desc', true, false , 'a2022m02',',');  
--SELECT * from cvp.res_cuadro_matriz_up('Precios medios Alimentos','a2022m05'::text, 'E1',false,'a2022m01','desc', true, false , 'a2022m02',',');  
--------------------------------------------------------------
--res_cuadro_pp
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
                 where cd.principal and p."cluster" is distinct from 3
                   and periodo between v_periodo_desde and p_Periodo
                   and ((pempalmehasta and periodo <= pperiodoempalme) or 
                        (pempalmedesde and periodo >  pperiodoempalme))
                 order by c.producto, c.periodo
                ) as q
               ;
end;
$BODY$;
--test
--SELECT * from cvp.res_cuadro_pp(' ', 'a2022m04', 'a2022m01', true, false , 'a2022m02', ',');
---------------------------------------------------------------
--FIN CUADROS PRECIOS PROMEDIOS
/****************************************************************************************************/
--CUADROS INDICE
--res_cuadro_iivv
--este--
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
                   and (p_cuadro <> 'A2bis' or cuagru.cuadro is not null) 
                   and ((pempalmehasta and cg.periodo <= pperiodoempalme) or 
                        (pempalmedesde and cg.periodo >  pperiodoempalme));
  -- */
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_iivv('Nivel general y capitulos'        , 'a2022m01', 1, 'Z', true, '1' , true, false, 'a2022m02', ',');  --cuadro 1
--SELECT * from cvp.res_cuadro_iivv('Nivel general y Aperturas'        , 'a2022m01', 3, 'Z', true, 'A2', true, false, 'a2022m02', ',');  --cuadro A2
--SELECT * from cvp.res_cuadro_iivv('Nivel general, bienes y servicios', 'a2022m01', 1, 'S', true, '2' , true, false, 'a2022m02', ',');  --cuadro 2

-------------------------------------------------
--res_cuadro_ii
--UTF8=Sí
--este--
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
                      replace(cg.incidenciainteranualredondeada::text,'.',p_separador)::text
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
--test
--SELECT * from cvp.res_cuadro_ii('Nivel general y capitulos', 'a2022m05', 1, 'Z', true, '1a', true, false, 'a2022m02', ',');  --cuadro 1a

------------------------------
--res_cuadro_piivvi
--este--
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
                   and ((pempalmehasta and cg.periodo <= pperiodoempalme) or 
                        (pempalmedesde and cg.periodo >  pperiodoempalme))
                 ; 
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_piivvi('Nivel general, bienes y servicios', 'a2022m01', 1, 'S', true, '2_pi', true, false, 'a2022m02', ',');  --cuadro 2_pi
--SELECT * from cvp.res_cuadro_piivvi('Nivel general, bienes y servicios', 'a2022m02', 1, 'R', true, '8_pi', true, false, 'a2022m02', ',');  --cuadro 8_pi
----------------------------------------------------------------------------------
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

--test:
--SELECT * from cvp.res_cuadro_i('Nivel general y capítulos'        , 'a2022m01', 1, 'Z', true , 2, true, false, 'a2022m02',',');  --Cuadro3 IPCBA. Incidencia de los capítulos en el nivel general
--SELECT * from cvp.res_cuadro_i('Nivel general, bienes y servicios', 'a2022m01', 1, 'S', false, 1, true, false, 'a2022m02',',');  --Cuadro4a IPCBA. Incidencia de los bienes y servicios en el nivel general con un decimal
--SELECT * from cvp.res_cuadro_i('Nivel general, bienes y servicios', 'a2022m01', 1, 'S', false, 2, true, false, 'a2022m02',',');  --Cuadro4b IPCBA. Incidencia de los bienes y servicios en el nivel general con dos decimales

-----------------------------------------------------------------------------
--res_cuadro_matriz_i
--este--
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
                        (pempalmedesde and i.periodo >  pperiodoempalme))
                        order by i.periodo, CASE WHEN p_cuadro = 'A2bish_con' THEN cuagru.orden::text ELSE i.grupo END) 
                as q) as x;
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_matriz_i('Nivel general y capítulos'        , 'a2022m05', 1, 'Z', true ,'3h'    , 2,'a2022m01','desc', true, false, 'a2022m02',',');  --Cuadro3h IPCBA. Incidencia de los capítulos en el nivel general
--SELECT * from cvp.res_cuadro_matriz_i('Nivel general, bienes y servicios', 'a2022m05', 1, 'S', false,'4bh'   , 2,'a2022m01','desc', true, false, 'a2022m02',',');  --Cuadro4bh IPCBA. Incidencia de los bienes y servicios en el nivel general con dos decimales
--SELECT * from cvp.res_cuadro_matriz_i('Apertura'                         , 'a2022m05', 3, 'Z', true ,'A2bish', 2,'a2022m01','asc' , true, false, 'a2022m02',',');  --CuadroA2bish Índices IPCBA por aperturas.

----------------------------------------------------------------------------------------
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
                   and (case when c.agrupacion='S' then r.grupo='S1' else r.grupo='R3' end) 
                   and ((pempalmehasta and c.periodo <= pperiodoempalme) or 
                        (pempalmedesde and c.periodo >  pperiodoempalme))
;    
end;
$BODY$;

--test
--SELECT * from cvp.res_cuadro_ivebs('Mes', 'a2022m05', 0, 'S', 'a2022m01', true, false, 'a2022m02', ',');  --cuadro A1

--FIN CUADROS INDICE

------------------------------------------------------------------------
set search_path = expo;
CREATE OR REPLACE FUNCTION actualizar_esquema_expo(
    pperiodo text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN 
    DELETE FROM expo.tb_imp_indices;
    DELETE FROM expo.tb_imp_rubros WHERE nivel=2;
    DELETE FROM expo.tb_imp_rubros WHERE nivel=1;
    DELETE FROM expo.tb_imp_rubros WHERE nivel=0;
    DELETE FROM expo.tb_imp_columnas;
    DELETE FROM expo.tb_imp_periodos;
    DELETE FROM expo.tb_imp_parametros;
    
    INSERT INTO expo.tb_imp_parametros(codigo, descripcion, valor) VALUES ('Periodo_Actual','Periodo a partir del cual se realiza la importacion',pperiodo);
    INSERT INTO expo.tb_imp_parametros(codigo, descripcion, valor) VALUES ('Cantidad_Maxima_Perfiles','Cantidad máxima de perfiles que puede cargar un usuario normal(los Tutores no tienen máximo)',5);
    INSERT INTO expo.tb_imp_parametros(codigo, descripcion, valor) VALUES ('Momento_Exportacion_Origen','Momento de Exportacion de la base IPCBA',to_char(clock_timestamp(),'yyyy-mm-dd HH24:MI:ss'));
    INSERT INTO expo.tb_imp_parametros(codigo, descripcion, valor) VALUES ('Momento_Exportacion_Destino','Momento Exportacion a MySql tuinflacion',null);
    INSERT INTO expo.tb_imp_periodos(periodo, anio, mes)
        SELECT c.periodo, p.ano, p.mes
          FROM cvp.calculos c join cvp.periodos p on c.periodo=p.periodo 
          JOIN cvp.calculos_def cd on c.calculo = cd.calculo 
          WHERE cd.principal and c.abierto='N' and c.periodo <= pperiodo
          ORDER by c.periodo desc
          LIMIT 13;
    -- solo las columnas correspondientes al periodo pperiodo      
    INSERT INTO expo.tb_imp_columnas(periodo, columna, periodo_denominador, texto_columna)
        SELECT periodo, columna, periodo_denominador, texto_columna
            FROM (
                  SELECT periodo, 1 as columna, 
                         cvp.periodo_mes_anterior(periodo) as periodo_denominador,
                         'Respecto del mes anterior' as texto_columna
                    FROM cvp.calculos
                    WHERE abierto='N' and periodo =pperiodo 
                  UNION
                    SELECT periodo, 2 as columna, cvp.periodo_diciembre_anterior(periodo) as periodo_denominador,'Acumulado Anual' as texto_columna
                      FROM cvp.calculos
                      WHERE abierto='N' and periodo =pperiodo and 
                            substr(periodo,7,2) not in ('01','12') 
                  UNION
                    SELECT periodo, 
                           case when substr(periodo,7,2) in ('01','12') then 2  else 3 end as columna,
                           cvp.periodo_igual_mes_anno_anterior(periodo) as periodo_denominador,
                           'Variacion Interanual' as texto_columna
                      FROM cvp.calculos
                      WHERE abierto='N' and periodo =pperiodo 
                  ORDER BY periodo, columna ) as tt ;   
    INSERT INTO expo.tb_imp_rubros(rubro, nombre_rubro,explicacion_rubro,nivel,rubro_padre,aparece_en_resultados)
          select replace(grupo, 'Z','R') rubro,
                 overlay(lower(nombregrupo) placing upper(substr(nombregrupo,1,1)) from 1 for 1) as nombre_rubro,
                 explicaciongrupo as explicacion_rubro,nivel,
                 replace(grupopadre,'Z','R') as rubro_padre, 1 as aparece_en_resultados
              from cvp.grupos
              where agrupacion= 'Z' and nivel<=1
              order by nivel, grupo;
    INSERT INTO expo.tb_imp_indices(periodo,rubro,indice)
            select c.periodo, replace(c.grupo, 'Z','R') rubro, c.indiceredondeado indice
                from cvp.calgru c join cvp.grupos g on c.grupo=g.grupo and c.agrupacion= g.agrupacion
                      join cvp.calculos a on a.periodo=c.periodo AND a.calculo= c.calculo
                      join cvp.calculos_def cd on a.calculo = cd.calculo 
                where g.agrupacion='Z' and cd.principal and g.nivel<=1 and 
                      a.abierto='N' and (c.periodo=pperiodo or
                                         c.periodo in (select x.periodo_denominador from expo.tb_imp_columnas x where x.periodo=pperiodo))
            order by periodo, rubro ;                     
END
$BODY$;

--SELECT expo.actualizar_esquema_expo('a2024m01');
------------------

set search_path = cvp;
--select count(*) from novobs where estado is null;

alter table novobs disable trigger novobs_abi_trg; 
delete from novobs where estado is null;
alter table novobs enable trigger novobs_abi_trg; 

alter table novobs alter column estado set not null;

------------------------------
set search_path = cvp;
set role cvpowner;

DROP FUNCTION IF EXISTS calculo_borrarcopia(text, integer);

CREATE OR REPLACE FUNCTION calculo_borrarcopia(
    pperiodo text,
    pcalculo integer)
    RETURNS text
    LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$

DECLARE    
  vAbierto character varying(1);
  vCalculoprincipal integer := (select calculo from calculos_def where principal);
  vexiste integer;
  vultimocalculo integer := (select max(calculo) from calculos where periodo = pperiodo);
BEGIN  

SET search_path = cvp;
--Controles: Verificar que exista el calculo que se quiere borrar
SELECT 1 INTO vexiste 
   FROM calculos c 
   WHERE periodo=pPeriodo AND calculo=pcalculo;
IF vexiste is distinct from 1 THEN 
   RAISE EXCEPTION 'ERROR no existe el periodo %, calculo %', pperiodo, pcalculo;
END IF;
--Controles: Verificar que no se quiera borrar el calculo principal
IF vCalculoprincipal=pCalculo THEN
   RAISE EXCEPTION 'ERROR no se puede borrar el cálculo principal';
END IF;
--Controles: Verificar que calculo principal no este cerrado   
SELECT abierto INTO vAbierto 
   FROM calculos c 
   WHERE periodo=pPeriodo AND calculo=vCalculoprincipal;
IF vAbierto='N' THEN
   RAISE EXCEPTION 'ERROR no se puede borrar porque el calculo esta principal cerrado';
END IF;
--Controles: Verificar que el calculo que se quiere borrar sea el último calculo para el periodo
IF vultimocalculo is distinct from pCalculo THEN
   RAISE EXCEPTION 'ERROR el cálculo % no es el último cálculo para el periodo %', pcalculo, pperiodo;
END IF;
--
    
DELETE FROM CalObs            WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalDiv            WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalProd           WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalProdAgr        WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalGru            WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalHogGru         WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalHogSubtotales  WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM CalProdResp       WHERE periodo=pPeriodo AND calculo=pCalculo;
DELETE FROM Calculos          WHERE periodo=pPeriodo AND calculo=pCalculo;

RETURN 'listo';
END;
$BODY$;

/*
set search_path = cvp;

select * from calculos order by periodo desc, calculo;

select * from (
select 'CalObs'           ,periodo,calculo,count(*) FROM CalObs            WHERE periodo='a2024m04' group by 1,2,3 union
select 'CalDiv'           ,periodo,calculo,count(*) FROM CalDiv            WHERE periodo='a2024m04' group by 1,2,3 union
select 'CalProd'          ,periodo,calculo,count(*) FROM CalProd           WHERE periodo='a2024m04' group by 1,2,3 union
select 'CalProdAgr'       ,periodo,calculo,count(*) FROM CalProdAgr        WHERE periodo='a2024m04' group by 1,2,3 union
select 'CalGru'           ,periodo,calculo,count(*) FROM CalGru            WHERE periodo='a2024m04' group by 1,2,3 union
select 'CalHogGru'        ,periodo,calculo,count(*) FROM CalHogGru         WHERE periodo='a2024m04' group by 1,2,3 union
select 'CalHogSubtotales' ,periodo,calculo,count(*) FROM CalHogSubtotales  WHERE periodo='a2024m04' group by 1,2,3 union
select 'CalProdResp'      ,periodo,calculo,count(*) FROM CalProdResp       WHERE periodo='a2024m04' group by 1,2,3 union
select 'Calculos'         ,periodo,calculo,count(*) FROM Calculos          WHERE periodo='a2024m04' group by 1,2,3 
) X order by 1,2,3;

select calculo_borrarcopia('a2024m04', 0);
select calculo_borrarcopia('a2024m04', 20);
select calculo_borrarcopia('a2024m04', 21);
select calculo_borrarcopia('a2024m01', 21);
select calculo_borrarcopia('a2024m04', 23);
select calculo_borrarcopia('a2024m04', 22);
*/