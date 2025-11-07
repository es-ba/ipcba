-- View: ccc.gru_grupos_ccc

-- DROP VIEW ccc.gru_grupos_ccc;

CREATE OR REPLACE VIEW ccc.gru_grupos_ccc
 AS
 WITH RECURSIVE hijos_de(agrupacion, grupo_padre, grupo, esproducto) AS (
         SELECT grupos_ccc.agrupacion,
            grupos_ccc.grupopadre AS grupo_padre,
            grupos_ccc.grupo,
            grupos_ccc.esproducto
           FROM ccc.grupos_ccc
          WHERE grupos_ccc.grupopadre IS NOT NULL
        UNION ALL
         SELECT p.agrupacion,
            g.grupopadre AS grupo_padre,
            p.grupo,
            p.esproducto
           FROM hijos_de p
             JOIN ccc.grupos_ccc g ON g.grupo = p.grupo_padre AND g.agrupacion = p.agrupacion
          WHERE g.grupopadre IS NOT NULL
        )
 SELECT hijos_de.agrupacion,
    hijos_de.grupo_padre,
    hijos_de.grupo,
    hijos_de.esproducto
   FROM hijos_de
UNION ALL
 SELECT DISTINCT grupos_ccc.agrupacion,
    grupos_ccc.grupo AS grupo_padre,
    grupos_ccc.grupo,
    grupos_ccc.esproducto
   FROM ccc.grupos_ccc
  WHERE grupos_ccc.esproducto = 'N'::text
  ORDER BY 3, 2, 1;