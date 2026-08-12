set search_path = ccc, cvp;
set role cvpowner;

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

UPDATE grupos_ccc SET nombrecanasta_tot = null WHERE nombrecanasta_tot is not null;
UPDATE grupos_ccc SET nombrecanasta_tot = 'Canasta total' WHERE agrupacion = 'H' and nivel = 0;

CREATE OR REPLACE VIEW valorizacion_canasta_totales_ccc AS
select * from (
select v.periodo, v.calculo, v.hogar, g.agrupacion, g.grupo_padre grupo, gc.grupopadre, gc.nivel,
CASE WHEN v.hogar like '%Hogar%' AND gc.nivel = 0 then gc.nombrecanasta_tot else gc.nombregrupo END as nombregrupo, sum(valorhoggru) valorhoggru
from valorizacion_canasta_ccc v 
join gru_grupos_ccc g on v.agrupacion = 'G' and g.agrupacion = 'H' and v.grupo = g.grupo 
join grupos_ccc gc on g.agrupacion = gc.agrupacion and g.grupo_padre = gc.grupo
group by v.periodo, v.calculo, v.hogar, g.agrupacion, g.grupo_padre, CASE WHEN v.hogar like '%Hogar%'  AND gc.nivel = 0 then gc.nombrecanasta_tot else gc.nombregrupo END, gc.grupopadre, gc.nivel
order by v.periodo, v.calculo, v.hogar, g.agrupacion, g.grupo_padre, CASE WHEN v.hogar like '%Hogar%'  AND gc.nivel = 0 then gc.nombrecanasta_tot else gc.nombregrupo END, gc.grupopadre, gc.nivel
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

update cuadros_ccc SET descripcion = 'Canastas de bienes y servicios y sus componentes para un niño, niña o adolescente según su edad. Inquilinos.'   where cuadro = 'C1_NNYA_INQ';
update cuadros_ccc SET descripcion = 'Canastas de bienes y servicios y sus componentes para un niño, niña o adolescente según su edad. Propietarios.' where cuadro = 'C1_NNYA_PRO';
update cuadros_ccc SET descripcion = 'Canastas de crianza y sus componentes para un niño, niña o adolescente según su edad. Inquilinos.'   where cuadro = 'C2_NNYA_INQ';
update cuadros_ccc SET descripcion = 'Canastas de crianza y sus componentes para un niño, niña o adolescente según su edad. Propietarios.' where cuadro = 'C2_NNYA_PRO';

delete from cuadros_ccc where cuadro like '%vi_%' or cuadro like '%v_%';

ALTER TABLE cuadros_ccc ALTER COLUMN cuadro TYPE character varying(11);

do $SQL_ENANCE$
 begin
 PERFORM enance_table('cuadros_ccc','cuadro');
 end
$SQL_ENANCE$;

/*
insert into cuadros_ccc
SELECT 
replace (cuadro,'_NNYA','v'||'_NNYA') cuadro, descripcion, funcion, parametro1, periodo, nivel, grupo, agrupacion, encabezado, pie, ponercodigos, 
agrupacion2, hogares, pie1, cantdecimales, desde, orden, encabezado2, activo, empalmedesde, empalmehasta, tipo_hogar
FROM ccc.cuadros_ccc
where cuadro like 'C%'
union
SELECT 
replace (cuadro,'_NNYA','vi'||'_NNYA') cuadro, descripcion, funcion, parametro1, periodo, nivel, grupo, agrupacion, encabezado, pie, ponercodigos, 
agrupacion2, hogares, pie1, cantdecimales, desde, orden, encabezado2, activo, empalmedesde, empalmehasta, tipo_hogar
FROM ccc.cuadros_ccc
where cuadro like 'C%';

update cuadros_ccc SET descripcion = 'Valorización de las           Canastas de bienes y servicios y sus componentes para un niño, niña o adolescente según su edad.    Inquilinos.'   where cuadro = 'C1_NNYA_INQ';
update cuadros_ccc SET descripcion = 'Valorización de las           Canastas de bienes y servicios y sus componentes para un niño, niña o adolescente según su edad.    Propietarios.' where cuadro = 'C1_NNYA_PRO';
update cuadros_ccc SET descripcion = 'Variación interanual de las   Canastas de bienes y servicios y sus componentes para un niño, niña o adolescente según su edad (%) Inquilinos.'   where cuadro = 'C1vi_NNYA_INQ';
update cuadros_ccc SET descripcion = 'Variación interanual de las   Canastas de bienes y servicios y sus componentes para un niño, niña o adolescente según su edad (%) Propietarios.' where cuadro = 'C1vi_NNYA_PRO';
update cuadros_ccc SET descripcion = 'Variación intermensual de las Canastas de bienes y servicios y sus componentes para un niño, niña o adolescente según su edad (%) Inquilinos.'   where cuadro = 'C1v_NNYA_INQ';
update cuadros_ccc SET descripcion = 'Variación intermensual de las Canastas de bienes y servicios y sus componentes para un niño, niña o adolescente según su edad (%) Propietarios.' where cuadro = 'C1v_NNYA_PRO';
update cuadros_ccc SET descripcion = 'Valorización de las           Canastas de crianza y sus componentes para un niño, niña o adolescente según su edad.               Inquilinos.'   where cuadro = 'C2_NNYA_INQ';
update cuadros_ccc SET descripcion = 'Valorización de las           Canastas de crianza y sus componentes para un niño, niña o adolescente según su edad.               Propietarios.' where cuadro = 'C2_NNYA_PRO';
update cuadros_ccc SET descripcion = 'Variación interanual de las   Canastas de crianza y sus componentes para un niño, niña o adolescente según su edad            (%) Inquilinos.'   where cuadro = 'C2vi_NNYA_INQ';
update cuadros_ccc SET descripcion = 'Variación interanual de las   Canastas de crianza y sus componentes para un niño, niña o adolescente según su edad            (%) Propietarios.' where cuadro = 'C2vi_NNYA_PRO';
update cuadros_ccc SET descripcion = 'Variación intermensual de las Canastas de crianza y sus componentes para un niño, niña o adolescente según su edad            (%) Inquilinos.'   where cuadro = 'C2v_NNYA_INQ';
update cuadros_ccc SET descripcion = 'Variación intermensual de las Canastas de crianza y sus componentes para un niño, niña o adolescente según su edad            (%) Propietarios.' where cuadro = 'C2v_NNYA_PRO';
*/

DROP FUNCTION IF EXISTS ccc.ccc_cuadro_matriz_perfil(text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS ccc.ccc_cuadro_matriz_perfil(text, text, text, text, text, text, text, text);
DROP FUNCTION IF EXISTS ccc.ccc_cuadro_matriz_perfil(text, text, text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION ccc.ccc_cuadro_matriz_perfil(
    parametro1 text,
    p_periodo_desde text,
    p_periodo_hasta text,
    parametro4 text,
    p_cuadro text,
    p_separador text,
    p_tipo_hogar text,
    p_indicador text,
    p_genero text)
    RETURNS SETOF ccc.type_cuadro_matriz_perfil
    LANGUAGE plpgsql

AS $BODY$
declare
  vAnchoNumeros text:='100';
  v_formato_renglon text:='DW1n'; -- solo pongo letras para: el tipo de renglón, las columas laterales y una más para todos los datos.
  v_formato_renglon_cabezal text:='E111';
  v_abreviatura text;
begin
  select abreviatura into v_abreviatura from indicadores where indicador = p_indicador;
  return query select 'anchos'::text as formato_renglon,
    'auto'::text,
    'auto'::text,
    'auto'::text,
    'auto'::text,
    100::text;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
    'Periodo'::text,
    'Genero'::text,
    'Perfil'::text,
    'edad'::text,
    null::text;  
  return query select v_formato_renglon::text as formato_renglon, periodo, genero, c.hogar, edad,
       json_object_agg(
       CASE WHEN p_indicador = 'VIA' OR p_indicador = 'VAR' THEN concat_ws(' ',c.nombregrupo, v_abreviatura) 
            ELSE c.nombregrupo 
       END, 
       CASE WHEN p_indicador = 'VIA' THEN replace(c.variacioninteranualredondeada::text, '.', p_separador)
            WHEN p_indicador = 'VAR' THEN replace(c.variacionredondeada::text, '.', p_separador)
            ELSE replace(c.valorhoggru::text, '.', p_separador)
       END
       ORDER BY c.nivel DESC, c.grupo
       )::text as celda
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
       and genero = p_genero
    group by  periodo, p.hogar, perfil, tipo, genero, c.hogar, edad, p.orden --, ny.nombrennya
    order by periodo, p.orden
;
end;
$BODY$;
-- test
--SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m04'::text, 'a2026m04'::text, 'H'::text, 'C1', ',', 'NNYA_INQ','VAL', 'Mujer');
--SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m04'::text, 'a2026m04'::text, 'H'::text, 'C1', ',', 'NNYA_INQ','VAR', 'Varón'); --variacion mensual
--SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m01'::text, 'a2026m04'::text, 'H'::text, 'C2', ',', 'NNYA_PRO','VAL', 'Mujer');
--SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m01'::text, 'a2026m04'::text, 'H'::text, 'C2', ',', 'NNYA_PRO','VIA', 'Varón');  --variacion interanual

CREATE OR REPLACE FUNCTION ccc.ccc_cuadro_matriz_hogar(
    parametro1 text,
    p_periodo_desde text,
    p_periodo_hasta text,
    parametro4 text,
    p_cuadro text,
    parametro6 integer,
    p_separador text,
    p_tipo_hogar text)
    RETURNS SETOF ccc.type_cuadro_matriz
    LANGUAGE plpgsql
AS $BODY$
declare
    v_formato_renglon text:='DW1n'; -- solo pongo letras para: el tipo de renglón, las columas laterales y una más para todos los datos.
    v_formato_renglon_cabezal text:='E111'; -- idem
begin
  return query select 'anchos'::text as formato_renglon,
    'auto'::text,
    'auto'::text,
    'auto'::text,
    null::text,
    100::text;
  return query select v_formato_renglon_cabezal::text as formato_renglon,
    'Periodo'::text,
    'Valorización'::text,
    'Código'::text,
    null::text,
    null::text;
  return query SELECT v_formato_renglon::text as formato_renglon,
    h.periodo as periodo,
    h.nombregrupo::text as lateral1,
    h.grupo::text as lateral2,
    null::text as cabezal1,
    json_object_agg(
        h.hogar,
        replace(round(h.valorhoggru::numeric,2)::text, '.', p_separador)
        ORDER BY coalesce(hog.orden, n.orden)
    )::text as celda
    FROM (SELECT cl.periodo , cl.calculo, cl.hogar, cl.agrupacion, cl.grupo, g.nivel, g.nombregrupo, cl.valorhoggru 
            FROM valorizacion_canasta_ccc cl  
            LEFT JOIN grupos_ccc g on cl.agrupacion = g.agrupacion and cl.grupo = g.grupo
            WHERE cl.agrupacion = parametro4 and (g.nivel = 3 or g.nivel = 1)
          UNION 
          SELECT periodo, calculo, hogar, agrupacion, grupo, nivel, nombregrupo, valorhoggru 
          FROM valorizacion_canasta_totales_ccc
          WHERE nivel = 0) h
    left join hogares_ccc hog on h.hogar = hog.hogar
    left join nnyaper n on coalesce (n.nombrennyaper, n.nnya) = h.hogar
    LEFT JOIN grupos_ccc g on h.agrupacion = g.agrupacion and h.grupo = g.grupo
    JOIN calculos_def cd on h.calculo = cd.calculo
    WHERE cd.principal
      and h.periodo between p_periodo_desde and p_periodo_hasta
      AND (
          parametro6 IS NULL
          OR
          (NULLIF(regexp_replace(REPLACE(h.hogar, '5b', '5.1'), '[^0-9.]', '', 'g'), ''))::numeric < parametro6
      )
      and h.hogar like p_tipo_hogar||'%'
    GROUP BY v_formato_renglon, h.periodo, h.nombregrupo, h.grupo
    ORDER BY h.periodo, h.grupo;
end;
$BODY$;

--test
--SELECT * from ccc_cuadro_matriz_hogar('Listado de Valorización de la Canasta', 'a2023m01'::text, 'a2025m05'::text, 'G'::text, 'H1', 16, ',', 'Hogar CCC');
--SELECT * from ccc_cuadro_matriz_hogar('Listado de Valorización de la Canasta', 'a2026m01'::text, 'a2026m01'::text, 'G'::text, 'H1', null, ',', 'NNYA');
