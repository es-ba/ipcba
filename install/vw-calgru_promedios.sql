CREATE OR REPLACE VIEW calgru_promedios AS
 SELECT c.periodo,
    c.calculo,
    c.agrupacion,
    c.grupo,
    c.variacion,
    c.impgru,
    c.valorprel,
    c.valorgru,
    c.grupopadre,
    c.nivel,
    c.esproducto,
    c.ponderador,
    c.indice,
    c.indiceprel,
    c.incidencia,
    c.indiceredondeado,
    c.incidenciaredondeada,
    c.ponderadorimplicito,
    (c0.valorgru + c1.valorgru + c.valorgru) / 3::double precision AS valorgrupromedio
   FROM cvp.calgru c
     JOIN cvp.calculos_def cd on c.calculo = cd.calculo
     LEFT JOIN cvp.periodos p ON c.periodo::text = p.periodo::text
     LEFT JOIN cvp.calgru c0 ON c0.periodo::text = p.periodoanterior::text AND c.calculo = c0.calculo AND c.agrupacion::text = c0.agrupacion::text AND c.grupo::text = c0.grupo::text
     LEFT JOIN cvp.calgru c1 ON c1.periodo::text = cvp.moverperiodos(c.periodo::text, 1) AND c1.calculo = c.calculo AND c1.agrupacion::text = c.agrupacion::text AND c1.grupo::text = c.grupo::text
  WHERE cd.principal;

GRANT SELECT ON TABLE calgru_promedios TO cvp_administrador;
