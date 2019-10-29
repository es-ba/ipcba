CREATE OR REPLACE VIEW paralistadodecontroldecm AS
 SELECT ccm.periodo,
    ccm.conjuntomuestral,
    ccm.tiposinformante,
    ccm.rubros,
    ccm.cantactivos,
    ccm.cantreemplazos,
        CASE
            WHEN ccm.tiposinformante > 1 THEN 'CM con distintos tipos de informante'::text
            ELSE NULL::text
        END AS leyenda1,
        CASE
            WHEN ccm.rubros > 1 THEN 'CM con distintos rubros'::text
            ELSE NULL::text
        END AS leyenda2,
        CASE
            WHEN ccm.cantactivos > 1 THEN 'CM con más de un informante activo'::text
            WHEN ccm.cantactivos = 0 THEN 'CM sin informante activo'::text
            ELSE NULL::text
        END AS leyenda3,
        CASE
            WHEN ccm.cantreemplazos = 0 THEN 'CM sin informantes para reemplazos'::text
            ELSE NULL::text
        END AS leyenda4
   FROM ( SELECT pc.periodo,
            pc.conjuntomuestral,
            t.tiposinformante,
            r.rubros,
            COALESCE(ac.cantidadactivos, 0::bigint) AS cantactivos,
            COALESCE(re.cantidadreemplazos, 0::bigint) AS cantreemplazos
           FROM ( SELECT periodos.periodo,
                    conjuntomuestral.conjuntomuestral
                   FROM cvp.periodos,
                    cvp.conjuntomuestral) pc
             LEFT JOIN ( SELECT informantes.conjuntomuestral,
                    count(DISTINCT informantes.tipoinformante) AS tiposinformante
                   FROM cvp.informantes
                  GROUP BY informantes.conjuntomuestral) t ON pc.conjuntomuestral = t.conjuntomuestral
             LEFT JOIN ( SELECT informantes.conjuntomuestral,
                    count(DISTINCT informantes.rubro) AS rubros
                   FROM cvp.informantes
                  GROUP BY informantes.conjuntomuestral) r ON pc.conjuntomuestral = r.conjuntomuestral
             LEFT JOIN ( SELECT a.periodo,
                    a.conjuntomuestral,
                    a.cantidad AS cantidadactivos
                   FROM ( SELECT e.periodo,
                            e.conjuntomuestral,
                            e.estado,
                            count(*) AS cantidad
                           FROM ( SELECT p.periodo,
                                    i.conjuntomuestral,
                                    i.informante,
                                    cvp.estadoinformante(p.periodo::text, i.informante) AS estado
                                   FROM cvp.periodos p,
                                    cvp.informantes i) e
                          GROUP BY e.periodo, e.conjuntomuestral, e.estado) a
                  WHERE a.estado = 'Activo'::text) ac ON pc.conjuntomuestral = ac.conjuntomuestral AND pc.periodo::text = ac.periodo::text
             LEFT JOIN ( SELECT a.periodo,
                    a.conjuntomuestral,
                    a.cantidad AS cantidadreemplazos
                   FROM ( SELECT e.periodo,
                            e.conjuntomuestral,
                            e.estado,
                            count(*) AS cantidad
                           FROM ( SELECT p.periodo,
                                    i.conjuntomuestral,
                                    i.informante,
                                    cvp.estadoinformante(p.periodo::text, i.informante) AS estado
                                   FROM cvp.periodos p,
                                    cvp.informantes i) e
                          GROUP BY e.periodo, e.conjuntomuestral, e.estado) a
                  WHERE a.estado = 'Inactivo'::text) re ON pc.conjuntomuestral = re.conjuntomuestral AND pc.periodo::text = re.periodo::text) ccm;

GRANT SELECT ON TABLE paralistadodecontroldecm TO cvp_usuarios;
GRANT SELECT ON TABLE paralistadodecontroldecm TO cvp_recepcionista;
