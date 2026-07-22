set search_path = ccc, cvp;

INSERT INTO agrupaciones_ccc(
    agrupacion, nombreagrupacion, paravarioshogares, calcular_junto_grupo, valoriza, tipo_agrupacion)
    VALUES ('H', 'Agrupación para los totales de canasta de crianza', true, 'Z', false, 'CANASTA');

INSERT INTO grupos_ccc(
    agrupacion, grupo, nombregrupo, grupopadre, nivel, esproducto) VALUES 
    --('H', 'H' , null, null, 0, 'N'),
    ('H', 'H', 'Canasta de crianza', null , 0, 'N'),


    ('H', 'H1', 'Canasta de Bienes y servicios', 'H' , 1, 'N'),
    ('H', 'H2', 'Cuidados'                     , 'H' , 1, 'N'),
    
    ('H', 'G1', 'Canasta Alimentaria'    , 'H1', 2, 'N'),
    ('H', 'G2', 'Canasta No Alimentaria' , 'H1', 2, 'N'),

    ('H', 'G3', 'Cuidados'               , 'H2', 2, 'N');

drop view if exists cvp.valorizacion_canasta_totales_var_ccc;
drop view if exists ccc.valorizacion_canasta_totales_var_ccc;

drop view if exists cvp.valorizacion_canasta_totales_ccc;
drop view if exists ccc.valorizacion_canasta_totales_ccc;

CREATE OR REPLACE VIEW valorizacion_canasta_totales_ccc AS
select * from (
select v.periodo, v.calculo, v.hogar, g.agrupacion, g.grupo_padre grupo, gc.grupopadre, gc.nivel,
gc.nombregrupo, sum(valorhoggru) valorhoggru
from valorizacion_canasta_ccc v 
join gru_grupos_ccc g on v.agrupacion = 'G' and g.agrupacion = 'H' and v.grupo = g.grupo 
join grupos_ccc gc on g.agrupacion = gc.agrupacion and g.grupo_padre = gc.grupo
group by v.periodo, v.calculo, v.hogar, g.agrupacion, g.grupo_padre, gc.nombregrupo, gc.grupopadre, gc.nivel
order by v.periodo, v.calculo, v.hogar, g.agrupacion, g.grupo_padre, gc.nombregrupo, gc.grupopadre, gc.nivel
)
;
GRANT SELECT ON TABLE valorizacion_canasta_totales_ccc TO cvp_administrador, ccc_analista;

--select * from valorizacion_canasta_totales_ccc where periodo ='a2026m04';

CREATE OR REPLACE VIEW valorizacion_canasta_totales_var_ccc AS
select * from (
select v.periodo, v.calculo, v.hogar, v.agrupacion, v.grupo, v.grupopadre, v.nivel, v.nombregrupo, v.valorhoggru, 
CASE WHEN v_a.valorhoggru=0 THEN null ELSE (v.valorhoggru::decimal/v_a.valorhoggru::decimal*100-100)::decimal END as variacion,
CASE WHEN v_b.valorhoggru=0 THEN null ELSE (v.valorhoggru::decimal/v_b.valorhoggru::decimal*100-100)::decimal END as variacioninteranual,
round(CASE WHEN v_a.valorhoggru=0 THEN null ELSE (v.valorhoggru::decimal/v_a.valorhoggru::decimal*100-100)::decimal END, 1) as variacionredondeada,
round(CASE WHEN v_b.valorhoggru=0 THEN null ELSE (v.valorhoggru::decimal/v_b.valorhoggru::decimal*100-100)::decimal END, 1) as variacioninteranualredondeada
from valorizacion_canasta_totales_ccc v
join periodos p on v.periodo = p.periodo
left join valorizacion_canasta_totales_ccc v_a on v_a.periodo = p.periodoanterior and v_a.calculo = v.calculo and v_a.hogar = v.hogar and v_a.agrupacion = v.agrupacion and v_a.grupo = v.grupo
left join valorizacion_canasta_totales_ccc v_b on v_b.periodo = periodo_igual_mes_anno_anterior(v_a.periodo) and v_b.calculo = v.calculo and v_b.hogar = v.hogar and v_b.agrupacion = v.agrupacion and v_b.grupo = v.grupo
)
;
GRANT SELECT ON TABLE valorizacion_canasta_totales_var_ccc TO cvp_administrador, ccc_analista;

UPDATE cuadros_ccc SET agrupacion = 'H' where funcion = 'ccc_cuadro_matriz_perfil';
UPDATE cuadros_ccc SET tipo_hogar = 'Hogar' where cuadro = 'H1_HOGAR';

create or replace function ccc_cuadro_matriz_perfil(parametro1 text, p_periodo_desde text, p_periodo_hasta text, parametro4 text, p_cuadro text, 
  p_separador text, p_tipo_hogar text)
  returns setof ccc.type_cuadro_matriz_perfil
  language plpgsql
as
$BODY$
declare
  vAnchoNumeros text:='100';
  v_formato_renglon text:='DW1n'; -- solo pongo letras para: el tipo de renglón, las columas laterales y una más para todos los datos.
  v_formato_renglon_cabezal text:='E111';
begin
  return query select 'anchos'::text as formato_renglon,
    'auto'::text,
    'auto'::text,
    'auto'::text,
    'auto'::text,
    --'auto'::text,
    100::text;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
    'Periodo'::text,
    'Genero'::text,
    'Perfil'::text,
    'edad'::text,
    null::text;  
  return query select v_formato_renglon::text as formato_renglon, periodo, genero, c.hogar, edad
    , json_object_agg(
    c.nombregrupo,
    replace(round(c.valorhoggru::numeric,2)::text, '.', p_separador) 
    ORDER BY c.nivel DESC, c.grupo
    )::text as celda

    --, json_object_agg(
    --c.nombregrupo||' %', 
    --replace(c.variacionredondeada::text, '.', p_separador)
    --ORDER BY c.nivel DESC, c.grupo
    --)::text as celda

    --, json_object_agg(
    --c.nombregrupo||' % interanual', 
    --replace(c.variacioninteranualredondeada::text, '.', p_separador)
    --ORDER BY c.nivel DESC, c.grupo
    --)::text as celda

    from (select pe.perfil as perfil_equivalente, COALESCE(n.nombrennyaper, n.nnya) AS hogar, n.orden, pp.*
        from perfiles pe join perfiles pp on pe.equivalente and pe.tipo = pp.tipo
        join nnyaper n on pp.perfil = n.perfil and pe.perfil = n.perfil_equivalente) p
    left join valorizacion_canasta_totales_var_ccc c on p.hogar = c.hogar
    join cvp.calculos_def cd on c.calculo = cd.calculo
    where c.agrupacion = parametro4 and c.hogar like p_tipo_hogar||'%'
       and cd.principal
       and periodo between p_periodo_desde and p_periodo_hasta
       and CASE WHEN p_cuadro like 'C1%' THEN c.grupo in ('G1','G2','H1') 
                WHEN p_cuadro like 'C2%' THEN c.grupo in ('H','H1','H2')
                end 
    group by  periodo, p.hogar, perfil, tipo, genero, c.hogar, edad, p.orden --, ny.nombrennya
    order by periodo, p.orden
;
end;
$BODY$;
-- test
SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m04'::text, 'a2026m04'::text, 'H'::text, 'C1', ',', 'NNYA_INQ');
SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m01'::text, 'a2026m04'::text, 'H'::text, 'C2', ',', 'NNYA_PRO');
