
set search_path = cvp;

CREATE OR REPLACE VIEW preciosmedios_albs_var AS
  SELECT g2.grupopadre AS gruponivel1, g3.nombregrupo AS nombregruponivel1, g.grupopadre, g2.nombregrupo AS nombregrupopadre, c.producto,
         coalesce(p.nombreparapublicar::character varying(250),p.nombreproducto) as nombreproducto,p.unidadmedidaabreviada,
         ROUND(c0.promdiv::DECIMAL,2) AS promprodant,
         ROUND(c.promdiv ::DECIMAL,2) AS promprod,  
         CASE WHEN c0.promdiv=0 THEN null ELSE round((c.promdiv/c0.promdiv*100-100)::decimal,1) END AS variacion,
         CASE WHEN ca.promdiv=0 THEN null ELSE round((c.promdiv/ca.promdiv*100-100)::decimal,1) END AS variaciondiciembre,
         CASE WHEN cm.promdiv=0 THEN null ELSE round((c.promdiv/cm.promdiv*100-100)::decimal,1) END AS variacionmesanioanterior,        
         g.agrupacion,c.calculo, c.periodo, c0.calculo AS calculoant,c0.periodo periodoant,ca.periodo periododiciembre,cm.periodo periodoaniooanterior
    FROM cvp.caldiv c
    JOIN cvp.calculos_def df on c.calculo = df.calculo
    JOIN cvp.grupos g ON g.grupo=c.producto AND g.esproducto='S'
    JOIN cvp.productos p ON g.grupo=p.producto AND g.esproducto='S'
    JOIN cvp.calculos pa ON c.periodo=pa.periodo and  'A'=pa.agrupacionprincipal AND  df.calculo=pa.calculo
    JOIN cvp.caldiv c0 ON  c.producto=c0.producto AND c0.calculo=pa.calculoAnterior AND  c0.periodo=pa.periodoAnterior  AND c0.division='0'
    LEFT JOIN cvp.caldiv ca ON c.producto=ca.producto AND c.calculo=ca.calculo AND  ca.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m12' AND ca.division='0'
    LEFT JOIN cvp.caldiv cm ON c.producto=cm.producto AND c.calculo=cm.calculo AND  cm.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m'||substr(c.periodo,7,2)  AND cm.division='0'
    LEFT JOIN cvp.grupos g2 ON g.grupopadre = g2.grupo AND g2.agrupacion = g.agrupacion
    LEFT JOIN cvp.grupos g3 ON g2.grupopadre = g3.grupo AND g3.agrupacion = g2.agrupacion
    WHERE df.principal AND  (g.esproducto='S'  AND g.agrupacion='C') AND c.division='0' AND p."cluster" is distinct from 3
   ORDER BY agrupacion, periodo, gruponivel1, grupopadre, producto;

--res_cuadro_i
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
                   and i.periodo=p_Periodo;
end;
$BODY$;

--res_cuadro_iivv
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
                   and (p_cuadro <> 'A2bis' or cuagru.cuadro is not null); 
  -- */
end;
$BODY$;

--res_cuadro_matriz_i
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
                   order by i.periodo, CASE WHEN p_cuadro = 'A2bish_con' THEN cuagru.orden::text ELSE i.grupo END) as q) as x;
end;
$BODY$;

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
                      g.nombregrupo::text, devolver_mes_anio(c.periodo) as nombreperiodo,
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
                 where cd.principal and p."cluster" is distinct from 3
                   and periodo between v_periodo_desde and p_Periodo
                 order by c.producto, c.periodo
                ) as q
               ;
end;
$BODY$;

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
                   ; 
end;
$BODY$;