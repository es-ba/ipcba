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
