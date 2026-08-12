-- FUNCTION: ccc.ccc_cuadro_matriz_hogar(text, text, text, text, text, integer, text, text)

-- DROP FUNCTION IF EXISTS ccc.ccc_cuadro_matriz_hogar(text, text, text, text, text, integer, text, text);

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
