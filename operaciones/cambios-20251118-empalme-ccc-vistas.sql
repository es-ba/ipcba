--empalme
--paso 1.1
set search_path= ccc,cvp;
set role cvpowner;
DROP TABLE IF EXISTS calgru_ccc_b1112_b21 cascade;
CREATE TABLE IF NOT EXISTS calgru_ccc_b1112_b21 AS SELECT periodo, calculo, agrupacion, grupo, indice, indiceredondeado FROM cvp.calgru WHERE FALSE;
ALTER TABLE calgru_ccc_b1112_b21 ADD PRIMARY KEY (periodo, calculo, agrupacion, grupo);
ALTER TABLE calgru_ccc_b1112_b21 ADD FOREIGN KEY (calculo) REFERENCES calculos_def (calculo);
ALTER TABLE calgru_ccc_b1112_b21 ADD FOREIGN KEY (agrupacion, grupo) REFERENCES grupos (agrupacion, grupo);
ALTER TABLE calgru_ccc_b1112_b21 ADD FOREIGN KEY (periodo) REFERENCES periodos (periodo);
GRANT SELECT ON TABLE calgru_ccc_b1112_b21 TO cvp_administrador, ccc_analista;

do $SQL_ENANCE$
 begin
 PERFORM enance_table('calgru_ccc_b1112_b21','periodo, calculo, agrupacion, grupo');
 end
$SQL_ENANCE$;

INSERT INTO calgru_ccc_b1112_b21 (periodo, calculo, agrupacion, grupo, indice, indiceredondeado)
SELECT periodo, calculo, agrupacion, grupo,
       --FORMULA 1:
       --indiceredondeado * sum(indiceredondeado_b1112 * ponderador_b1112) / sum(indiceredondeado_b1112_emp * ponderador_b1112_emp) indice_empalmado,
       --indiceredondeado * sum(indiceredondeado_b1112 * ponderador_b1112) / sum(indiceredondeado_b1112_emp * ponderador_b1112_emp) indice_empalmadoredondeado
       indiceredondeado * round((sum(producto_b1112)/sum(ponderador_b1112))::decimal,2) / round((sum(producto_b1112_emp)/sum(ponderador_b1112_emp))::decimal,2) indice_empalmado,
       indiceredondeado * round((sum(producto_b1112)/sum(ponderador_b1112))::decimal,2) / round((sum(producto_b1112_emp)/sum(ponderador_b1112_emp))::decimal,2) indice_empalmadoredondeado
FROM
  (SELECT vp.periodo, vp.calculo calculo_b1112, cn.calculo, vp.agrupacion agrupacion_b1112, vp.grupo grupo_b1112,
          cn.agrupacion as agrupacion, cn.grupo as grupo,
          cn.indiceredondeado indiceredondeado, vp.indiceredondeado indiceredondeado_b1112, vp.ponderador ponderador_b1112,
          ve.indiceredondeado indiceredondeado_b1112_emp , ve.ponderador ponderador_b1112_emp,
          cn.indice indice, vp.indice indice_b1112, ve.indice indice_b1112_emp,
          --
          vp.indice * vp.ponderador producto_b1112, ve.indice * ve.ponderador producto_b1112_emp
     FROM calgru_b1112 vp
       join parametros p on unicoregistro
       join calculos_b1112 cd on vp.calculo = cd.calculo
       join empalme_ccc_b1112 e on vp.agrupacion = e.agrupacion_b1112 and vp.grupo = e.grupo_b1112
       join (select c.*
               from calgru c
                 join parametros p on unicoregistro and c.periodo = p.periodo_empalme
                 join calculos_def d on c.calculo = d.calculo
                where d.principal
            ) cn on e.agrupacion = cn.agrupacion and e.grupo = cn.grupo
       join (select c.*
               from calgru_b1112 c
               join parametros p on unicoregistro and c.periodo = p.periodo_empalme
            ) ve on vp.calculo = ve.calculo and ve.agrupacion = e.agrupacion_b1112 and ve.grupo = e.grupo_b1112
      where vp.calculo = 0 and vp.periodo <= p.periodo_empalme
            and vp.periodo >= 'a2012m07' --primer periodo publicacion base 2011-2012
      order by vp.periodo desc, vp.calculo, vp.agrupacion, cn.grupo
  ) Q
group by periodo, calculo, agrupacion, grupo, indiceredondeado
order by periodo desc, calculo, agrupacion, grupo;

---------VISTAS----------------
DROP VIEW IF EXISTS calgru_ccc_empalme;
CREATE OR REPLACE VIEW calgru_ccc_empalme AS --pk: periodo, calculo, agrupacion, grupo verificada
SELECT *
  FROM (SELECT distinct c.periodo, c.calculo, c.agrupacion, c.grupo, c.indice, c.indiceredondeado
          FROM calgru c
          JOIN parametros p ON unicoregistro
          JOIN calculos_def cd ON c.calculo = cd.calculo
          JOIN empalme_ccc_b1112 e ON c.agrupacion = e.agrupacion and c.grupo = e.grupo
          WHERE cd.principal AND c.periodo > periodo_empalme
        UNION
        SELECT c.periodo, c.calculo, c.agrupacion, c.grupo, c.indice, c.indiceredondeado
          FROM calgru_ccc_b1112_b21 c
       ) Q;
GRANT SELECT ON TABLE calgru_ccc_empalme TO cvp_administrador, ccc_analista;

--La VISTA que va a la apicación:
DROP VIEW IF EXISTS calgru_ccc_b1112_b21_vw;
CREATE OR REPLACE VIEW calgru_ccc_b1112_b21_vw AS
SELECT ce.*,
   --coalesce(c.periodoanterior, cb.periodoanterior) as periodoanterior, coalesce(c.calculoanterior, cb.calculoprincipal_b21) as calculoanterior,
   --ce_a.indice indiceanterior , ce_a.indiceredondeado indiceredondeadoanterior,
  CASE WHEN ce_a.Indiceredondeado=0    THEN NULL ELSE ROUND((ce.Indiceredondeado/ce_a.Indiceredondeado*100-100)::decimal,1) END AS variacion,
  CASE WHEN ce_vi.indiceredondeado = 0 THEN NULL ELSE round((ce.indiceredondeado/ce_vi.indiceredondeado*100-100)::decimal,1) END AS variacioninteranualredondeada,
  CASE WHEN ce_va.indiceredondeado = 0 THEN NULL ELSE round((ce.indiceredondeado/ce_va.indiceredondeado*100-100)::decimal,1) END AS variacionacumuladaanualredondeada,
  coalesce (g.nombregrupo, pr.nombreproducto) as nombre, g.nivel
  FROM calgru_ccc_empalme ce
  JOIN parametros p ON unicoregistro
  LEFT JOIN grupos g ON ce.agrupacion = g.agrupacion and ce.grupo = g.grupo
  LEFT JOIN productos pr ON ce.grupo = pr.producto
  LEFT JOIN calculos c ON ce.periodo = c.periodo and ce.calculo = c.calculo and c.periodo > p.periodo_empalme
  LEFT JOIN calculos_b1112 cb ON ce.periodo = cb.periodo and ce.calculo = cb.calculoprincipal_b21 and cb.periodo <= p.periodo_empalme
  LEFT JOIN calgru_ccc_empalme ce_a ON ce_a.periodo = coalesce(c.periodoanterior, cb.periodoanterior)
             and ce_a.calculo = coalesce(c.calculoanterior, cb.calculoprincipal_b21) and ce_a.agrupacion = ce.agrupacion and ce_a.grupo = ce.grupo
  LEFT JOIN calgru_ccc_empalme ce_vi ON ce_vi.agrupacion = ce.agrupacion AND ce_vi.grupo = ce.grupo
             AND ce_vi.calculo = coalesce(c.calculoanterior, cb.calculoprincipal_b21)
             AND ce_vi.periodo = periodo_igual_mes_anno_anterior(ce.periodo)
  LEFT JOIN calgru_ccc_empalme ce_va ON ce_va.agrupacion = ce.agrupacion AND ce_va.grupo = ce.grupo
             AND ce_va.calculo = coalesce(c.calculoanterior, cb.calculoprincipal_b21)
             AND ce_va.periodo = ('a' || (substr(coalesce(ce.periodo), 2, 4)::integer - 1)::text || 'm12');

GRANT SELECT ON TABLE calgru_ccc_b1112_b21_vw TO cvp_administrador, ccc_analista;
