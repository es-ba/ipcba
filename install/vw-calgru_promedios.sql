CREATE OR REPLACE VIEW calgru_promedios
 AS
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
    CASE WHEN p1.abierto = 'N' then (c0.valorgru + c1.valorgru + c.valorgru) / 3::double precision else null end AS valorgrupromedio
   FROM cvp.calgru c
     JOIN cvp.calculos_def cd ON c.calculo = cd.calculo
     JOIN cvp.calculos p ON c.periodo = p.periodo and c.calculo = p.calculo
     LEFT JOIN cvp.calgru c0 ON c0.periodo = p.periodoanterior AND p.calculoanterior = c0.calculo AND c.agrupacion = c0.agrupacion AND c.grupo = c0.grupo
     LEFT JOIN cvp.calgru c1 ON c1.periodo = cvp.moverperiodos(c.periodo, 1) AND c1.calculo = c.calculo AND c1.agrupacion = c.agrupacion AND c1.grupo = c.grupo
     LEFT JOIN cvp.calculos p1 ON c1.periodo = p1.periodo and c1.calculo = p1.calculo
  WHERE cd.principal;


GRANT SELECT ON TABLE calgru_promedios TO cvp_administrador;
