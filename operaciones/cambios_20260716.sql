set search_path = cvp, ccc;

INSERT INTO agrupaciones_ccc(
    agrupacion, nombreagrupacion, paravarioshogares, calcular_junto_grupo, valoriza, tipo_agrupacion)
    VALUES ('H', 'Agrupación para los totales de canasta de crianza', true, 'Z', false, 'CANASTA');

INSERT INTO ccc.grupos_ccc(
    agrupacion, grupo, nombregrupo, grupopadre, nivel, esproducto) VALUES 
    --('H', 'H' , null, null, 0, 'N'),
    ('H', 'H', 'Canasta de crianza', null , 0, 'N'),


    ('H', 'H1', 'Canasta de Bienes y servicios', 'H' , 1, 'N'),
    ('H', 'H2', 'Cuidados'                     , 'H' , 1, 'N'),
    
    ('H', 'G1', 'Canasta Alimentaria'    , 'H1', 2, 'N'),
    ('H', 'G2', 'Canasta No Alimentaria' , 'H1', 2, 'N'),

    ('H', 'G3', 'Cuidados'               , 'H2', 2, 'N');

drop view if exists valorizacion_canasta_totales_ccc;

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

UPDATE cuadros_ccc SET agrupacion = 'H' where funcion = 'ccc_cuadro_matriz_perfil';

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
    c.nombregrupo,
    replace(round(c.valorhoggru::numeric,2)::text, '.', p_separador)
    ORDER BY c.nivel DESC, c.grupo
    )::text as celda
    from (select pe.perfil as perfil_equivalente, COALESCE(n.nombrennyaper, n.nnya) AS hogar, n.orden, pp.*
        from perfiles pe join perfiles pp on pe.equivalente and pe.tipo = pp.tipo
        join nnyaper n on pp.perfil = n.perfil and pe.perfil = n.perfil_equivalente) p
    left join valorizacion_canasta_totales_ccc c on p.hogar = c.hogar
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


