--DROP FUNCTION IF EXISTS ccc.ccc_cuadro_matriz_perfil(text, text, text, text, text, text, text);
--DROP FUNCTION IF EXISTS ccc.ccc_cuadro_matriz_perfil(text, text, text, text, text, text, text, text);
--DROP FUNCTION IF EXISTS ccc.ccc_cuadro_matriz_perfil(text, text, text, text, text, text, text, text, text);

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
SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m04'::text, 'a2026m04'::text, 'H'::text, 'C1', ',', 'NNYA_INQ','VAL', 'Mujer');
SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m04'::text, 'a2026m04'::text, 'H'::text, 'C1', ',', 'NNYA_INQ','VAR', 'Varón'); --variacion mensual
SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m01'::text, 'a2026m04'::text, 'H'::text, 'C2', ',', 'NNYA_PRO','VAL', 'Mujer');
SELECT * from ccc_cuadro_matriz_perfil('Listado de Valorización de la Canasta', 'a2026m01'::text, 'a2026m04'::text, 'H'::text, 'C2', ',', 'NNYA_PRO','VIA', 'Varón');  --variacion interanual
