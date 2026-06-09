set search_path = ccc, cvp;

ALTER TABLE grupos_ccc ADD COLUMN nombrecanasta_ali text;
ALTER TABLE grupos_ccc ADD COLUMN nombrecanasta_bys text;
ALTER TABLE grupos_ccc ADD COLUMN nombrecanasta_cui text;
ALTER TABLE grupos_ccc ADD COLUMN nombrecanasta_tot text;

do $SQL_ENANCE$
 begin
 PERFORM enance_table('grupos_ccc','agrupacion, grupo');
 end
$SQL_ENANCE$;

UPDATE grupos_ccc SET nombrecanasta_ali = 'Canasta alimentaria'           where agrupacion = 'G' and grupo = 'G1';
UPDATE grupos_ccc SET nombrecanasta_ali = 'Canasta no alimentaria'        where agrupacion = 'G' and grupo = 'G2';

UPDATE grupos_ccc SET nombrecanasta_bys = 'Canasta de bienes y servicios' where agrupacion = 'G' and grupo = 'G1';
UPDATE grupos_ccc SET nombrecanasta_bys = 'Canasta de bienes y servicios' where agrupacion = 'G' and grupo = 'G2';

UPDATE grupos_ccc SET nombrecanasta_cui = 'Costo del cuidado'             where agrupacion = 'G' and grupo = 'G3';

UPDATE grupos_ccc SET nombrecanasta_tot = 'Canasta total'                 where agrupacion = 'G' and grupo = 'G1';
UPDATE grupos_ccc SET nombrecanasta_tot = 'Canasta total'                 where agrupacion = 'G' and grupo = 'G2';
UPDATE grupos_ccc SET nombrecanasta_tot = 'Canasta total'                 where agrupacion = 'G' and grupo = 'G3';

INSERT INTO cuadros_funciones_ccc
SELECT 'ccc_cuadro_matriz_perfil' as funcion, usa_parametro1, usa_periodo, usa_nivel, usa_grupo, usa_agrupacion, usa_ponercodigos, 
usa_agrupacion2, usa_cuadro, usa_hogares, usa_cantdecimales, usa_desde, usa_orden, usa_empalmedesde, usa_empalmehasta
FROM cuadros_funciones_ccc
WHERE funcion = 'ccc_cuadro_matriz_hogar';

INSERT INTO cuadros_ccc
SELECT 'C1_NNYA_INQ' cuadro, descripcion, 'ccc_cuadro_matriz_perfil' funcion, parametro1, periodo, nivel, grupo, agrupacion, encabezado, pie, ponercodigos, 
agrupacion2, hogares, pie1, cantdecimales, desde, orden, encabezado2, activo, empalmedesde, empalmehasta, tipo_hogar
FROM cuadros_ccc
WHERE cuadro = 'H1_NNYA_INQ';

INSERT INTO cuadros_ccc
SELECT 'C1_NNYA_PRO' cuadro, descripcion, 'ccc_cuadro_matriz_perfil' funcion, parametro1, periodo, nivel, grupo, agrupacion, encabezado, pie, ponercodigos, 
agrupacion2, hogares, pie1, cantdecimales, desde, orden, encabezado2, activo, empalmedesde, empalmehasta, tipo_hogar
FROM cuadros_ccc
WHERE cuadro = 'H1_NNYA_PRO';

INSERT INTO cuadros_ccc
SELECT 'C2_NNYA_INQ' cuadro, descripcion, 'ccc_cuadro_matriz_perfil' funcion, parametro1, periodo, nivel, grupo, agrupacion, encabezado, pie, ponercodigos, 
agrupacion2, hogares, pie1, cantdecimales, desde, orden, encabezado2, activo, empalmedesde, empalmehasta, tipo_hogar
FROM cuadros_ccc
WHERE cuadro = 'H1_NNYA_INQ';

INSERT INTO cuadros_ccc
SELECT 'C2_NNYA_PRO' cuadro, descripcion, 'ccc_cuadro_matriz_perfil' funcion, parametro1, periodo, nivel, grupo, agrupacion, encabezado, pie, ponercodigos, 
agrupacion2, hogares, pie1, cantdecimales, desde, orden, encabezado2, activo, empalmedesde, empalmehasta, tipo_hogar
FROM cuadros_ccc
WHERE cuadro = 'H1_NNYA_PRO';

drop view if exists valorizacion_canasta_totales_ccc;
CREATE OR REPLACE VIEW valorizacion_canasta_totales_ccc AS
select * from (
select v.periodo, v.calculo, v.hogar, v.agrupacion, 1 as orden, g.nombrecanasta_ali nombrecanasta,
string_agg(v.grupo, '-' order by v.grupo) as grupo, sum(valorhoggru) valorhoggru
from valorizacion_canasta_ccc v 
join grupos_ccc g on v.agrupacion = g.agrupacion and v.grupo = g.grupo
where g.nombrecanasta_ali is not null
group by v.periodo, v.calculo, v.hogar, v.agrupacion, orden, g.nombrecanasta_ali
union
select v.periodo, v.calculo, v.hogar, v.agrupacion, 2 as orden, g.nombrecanasta_bys nombrecanasta,
string_agg(v.grupo, '-' order by v.grupo) as grupo, sum(valorhoggru) valorhoggru
from valorizacion_canasta_ccc v 
join grupos_ccc g on v.agrupacion = g.agrupacion and v.grupo = g.grupo
where g.nombrecanasta_bys is not null
group by v.periodo, v.calculo, v.hogar, v.agrupacion, orden, g.nombrecanasta_bys
union
select v.periodo, v.calculo, v.hogar, v.agrupacion, 3 as orden, g.nombrecanasta_cui nombrecanasta,
string_agg(v.grupo, '-' order by v.grupo) as grupo, sum(valorhoggru) valorhoggru
from valorizacion_canasta_ccc v 
join grupos_ccc g on v.agrupacion = g.agrupacion and v.grupo = g.grupo
where g.nombrecanasta_cui is not null
group by v.periodo, v.calculo, v.hogar, v.agrupacion, orden, g.nombrecanasta_cui
union
select v.periodo, v.calculo, v.hogar, v.agrupacion, 4 as orden, g.nombrecanasta_tot nombrecanasta,
string_agg(v.grupo, '-' order by v.grupo) as grupo, sum(valorhoggru) valorhoggru
from valorizacion_canasta_ccc v 
join grupos_ccc g on v.agrupacion = g.agrupacion and v.grupo = g.grupo
where g.nombrecanasta_tot is not null
group by v.periodo, v.calculo, v.hogar, v.agrupacion, orden, g.nombrecanasta_tot
)
;
GRANT SELECT ON TABLE valorizacion_canasta_totales_ccc TO cvp_administrador, ccc_analista;

--select * from valorizacion_canasta_totales_ccc where periodo ='a2026m04';

DROP TYPE IF EXISTS ccc.type_cuadro_matriz_perfil cascade;

CREATE TYPE ccc.type_cuadro_matriz_perfil AS
(
    formato_renglon text,
    periodo text,
    lateral1 text,
    lateral2 text,
    lateral3 text,
    --lateral4 text,
    celda text
);

ALTER TYPE ccc.type_cuadro_matriz_perfil
    OWNER TO cvpowner;

DROP FUNCTION if exists ccc_cuadro_matriz_perfil(text,text,text,text,text,integer,text,text);
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
    --'nombrennya'::text,
    null::text;  
  return query select v_formato_renglon::text as formato_renglon, periodo, genero, c.hogar, edad, --ny.nombrennya,
    json_object_agg(
    c.nombrecanasta,
    replace(round(c.valorhoggru::numeric,2)::text, '.', p_separador)
    ORDER BY c.orden, c.grupo
    )::text as celda
    from (select pe.perfil as perfil_equivalente, COALESCE(n.nombrennyaper, n.nnya) AS hogar, n.orden, pp.*
        from perfiles pe join perfiles pp on pe.equivalente and pe.tipo = pp.tipo
        join nnyaper n on pp.perfil = n.perfil and pe.perfil = n.perfil_equivalente) p
    left join valorizacion_canasta_totales_ccc c on p.hogar = c.hogar
    join cvp.calculos_def cd on c.calculo = cd.calculo
    where c.agrupacion = parametro4 and c.hogar like p_tipo_hogar||'%'
       and cd.principal
       and periodo between p_periodo_desde and p_periodo_hasta
       and CASE WHEN p_cuadro like 'C1%' THEN c.orden between 1 and 2 
                WHEN p_cuadro like 'C2%' THEN c.orden between 2 and 4
                end 
    group by  periodo, p.hogar, perfil, tipo, genero, c.hogar, edad, p.orden --, ny.nombrennya
    order by periodo, p.orden
;
end;
$BODY$;

--test
SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m04'::text, 'a2026m04'::text, 'G'::text, 'C1', ',', 'NNYA_INQ');
SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m01'::text, 'a2026m04'::text, 'G'::text, 'C2', ',', 'NNYA_PRO');

