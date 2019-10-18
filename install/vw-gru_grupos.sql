create or replace view gru_grupos as 
 WITH RECURSIVE hijos_de(agrupacion, grupo_padre, grupo, esproducto) AS (
                 SELECT agrupacion, grupopadre AS grupo_padre, grupo, esproducto
                   FROM grupos
                   WHERE grupopadre IS NOT NULL
                 UNION ALL 
                 SELECT p.agrupacion, g.grupopadre AS grupo_padre, p.grupo, p.esproducto
                   FROM hijos_de p
                       JOIN grupos g ON g.grupo = p.grupo_padre AND g.agrupacion = p.agrupacion 
                   WHERE g.grupopadre IS NOT NULL
        ) 
 SELECT hijos_de.agrupacion, hijos_de.grupo_padre, hijos_de.grupo, hijos_de.esproducto
   FROM hijos_de
   UNION ALL
   SELECT DISTINCT agrupacion, grupo as grupo_padre, grupo, esproducto 
     FROM grupos 
     WHERE esproducto = 'N'
  ORDER BY grupo, grupo_padre, agrupacion;

GRANT SELECT ON TABLE gru_grupos TO cvp_administrador;