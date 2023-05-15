CREATE OR REPLACE VIEW paralistadodecontroldecm AS
 SELECT
    ccm.conjuntomuestral,
    ccm.tiposinformante,
    ccm.rubros,
    ccm.cantactivos,
    ccm.cantreemplazos,
        CASE
            WHEN ccm.tiposinformante > 1 THEN 'CM con distintos tipos de informante'
            ELSE NULL
        END AS leyenda1,
        CASE
            WHEN ccm.rubros > 1 THEN 'CM con distintos rubros'
            ELSE NULL
        END AS leyenda2,
        CASE
            WHEN ccm.cantactivos > 1 THEN 'CM con más de un informante activo'
            WHEN ccm.cantactivos = 0 THEN 'CM sin informante activo'
            ELSE NULL
        END AS leyenda3,
        CASE
            WHEN ccm.cantreemplazos = 0 THEN 'CM sin informantes para reemplazos'
            ELSE NULL
        END AS leyenda4
   FROM ( SELECT 
            pc.conjuntomuestral,
            t.tiposinformante,
            r.rubros,
            COALESCE(ac.cantidadactivos, 0::bigint) AS cantactivos,
            COALESCE(re.cantidadreemplazos, 0::bigint) AS cantreemplazos
           FROM conjuntomuestral pc
             LEFT JOIN (SELECT conjuntomuestral, count(DISTINCT tipoinformante) AS tiposinformante
                          FROM informantes
                          GROUP BY conjuntomuestral) t ON pc.conjuntomuestral = t.conjuntomuestral
             LEFT JOIN (SELECT conjuntomuestral, count(DISTINCT rubro) AS rubros
                          FROM informantes
                          GROUP BY conjuntomuestral) r ON pc.conjuntomuestral = r.conjuntomuestral
             LEFT JOIN (SELECT conjuntomuestral, count(*) cantidadactivos
                          FROM informantes a JOIN informantes_estado e on a.informante = e.informante
                          WHERE e.estado = 'Activo'
                          GROUP BY conjuntomuestral) ac ON pc.conjuntomuestral = ac.conjuntomuestral
             LEFT JOIN (SELECT conjuntomuestral, count(*) cantidadreemplazos
                          FROM informantes a JOIN informantes_estado e on a.informante = e.informante
                          WHERE e.estado = 'No usado'
                          GROUP BY conjuntomuestral) re ON pc.conjuntomuestral = re.conjuntomuestral) ccm;

GRANT SELECT ON TABLE paralistadodecontroldecm TO cvp_usuarios;
GRANT SELECT ON TABLE paralistadodecontroldecm TO cvp_recepcionista;
