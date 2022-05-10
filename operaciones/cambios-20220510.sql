set search_path = cvp;

CREATE OR REPLACE VIEW matrizperiodos6 AS
SELECT p.periodo as periodo6, CASE WHEN p.periodo='a2010m01' THEN NULL ELSE a.periodo END as periodo5,
       CASE WHEN p.periodo<='a2010m02' THEN NULL ELSE b.periodo END as periodo4,
       CASE WHEN p.periodo<='a2010m03' THEN NULL ELSE c.periodo END as periodo3,
       CASE WHEN p.periodo<='a2010m04' THEN NULL ELSE d.periodo END as periodo2,
       CASE WHEN p.periodo<='a2010m05' THEN NULL ELSE e.periodo END as periodo1
      FROM calculos p
        join calculos_def cd on p.calculo = cd.calculo 
        left join (select s.* from calculos s join calculos_def df1 on s.calculo = df1.calculo where df1.principal) a on a.periodo = p.periodoanterior
        left join (select t.* from calculos t join calculos_def df2 on t.calculo = df2.calculo where df2.principal) b on b.periodo = a.periodoanterior
        left join (select u.* from calculos u join calculos_def df3 on u.calculo = df3.calculo where df3.principal) c on c.periodo = b.periodoanterior
        left join (select v.* from calculos v join calculos_def df4 on v.calculo = df4.calculo where df4.principal) d on d.periodo = c.periodoanterior
        left join (select w.* from calculos w join calculos_def df5 on w.calculo = df5.calculo where df5.principal) e on e.periodo = d.periodoanterior
       where cd.principal; 
------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW matrizresultados AS
SELECT x.producto, x.tipoinformante, x.informante, x.observacion,
        ROUND(col1.PromObs::NUMERIC,2) as PromObs_1, ROUND(p1.precio::NUMERIC,2) AS precioObservado_1, 
        col1.ImpObs AS ImpObs_1, col1.antiguedadExcluido AS antiguedadExcluido_1,
        col1.antiguedadSinPrecio AS antiguedadSinPrecio_1, col1.antiguedadConPrecio AS antiguedadConPrecio_1,
        ROUND((col1.PromObs/col0.PromObs*100-100)::NUMERIC,1)::NUMERIC(8,1) AS Variacion_1,
        p1.tipoPrecio AS tipoPrecio_1, v1.razon as razon_1,
        ROUND(col2.PromObs::NUMERIC,2) as PromObs_2, ROUND(p2.precio::NUMERIC,2) AS precioObservado_2, 
        col2.ImpObs AS ImpObs_2, col2.antiguedadExcluido AS antiguedadExcluido_2,
        col2.antiguedadSinPrecio AS antiguedadSinPrecio_2, col2.antiguedadConPrecio AS antiguedadConPrecio_2,
        ROUND((col2.PromObs/col1.PromObs*100-100)::NUMERIC,1)::NUMERIC(8,1) AS Variacion_2,
        p2.tipoPrecio AS tipoPrecio_2, v2.razon as razon_2,
        ROUND(col3.PromObs::NUMERIC,2) as PromObs_3, ROUND(p3.precio::NUMERIC,2) AS precioObservado_3,
        col3.ImpObs AS ImpObs_3, col3.antiguedadExcluido AS antiguedadExcluido_3,
        col3.antiguedadSinPrecio AS antiguedadSinPrecio_3, col3.antiguedadConPrecio AS antiguedadConPrecio_3,
        ROUND((col3.PromObs/col2.PromObs*100-100)::NUMERIC,1)::NUMERIC(8,1) AS Variacion_3,
        p3.tipoPrecio AS tipoPrecio_3, v3.razon as razon_3,
        ROUND(col4.PromObs::NUMERIC,2) as PromObs_4, ROUND(p4.precio::NUMERIC,2) AS precioObservado_4,
        col4.ImpObs AS ImpObs_4, col4.antiguedadExcluido AS antiguedadExcluido_4,
        col4.antiguedadSinPrecio AS antiguedadSinPrecio_4, col4.antiguedadConPrecio AS antiguedadConPrecio_4,
        ROUND((col4.PromObs/col3.PromObs*100-100)::NUMERIC,1)::NUMERIC(8,1) AS Variacion_4,
        p4.tipoPrecio AS tipoPrecio_4, v4.razon as razon_4, 
        ROUND(col5.PromObs::NUMERIC,2) as PromObs_5, ROUND(p5.precio::NUMERIC,2) AS precioObservado_5,
        col5.ImpObs AS ImpObs_5, col5.antiguedadExcluido AS antiguedadExcluido_5, 
        col5.antiguedadSinPrecio AS antiguedadSinPrecio_5, col5.antiguedadConPrecio AS antiguedadConPrecio_5,
        ROUND((col5.PromObs/col4.PromObs*100-100)::NUMERIC,1)::NUMERIC(8,1) AS Variacion_5,
        p5.tipoPrecio AS tipoPrecio_5, v5.razon as razon_5,
        ROUND(col6.PromObs::NUMERIC,2) as PromObs_6, ROUND(p6.precio::NUMERIC,2) AS precioObservado_6,
        col6.ImpObs AS ImpObs_6, col6.antiguedadExcluido AS antiguedadExcluido_6,
        col6.antiguedadSinPrecio AS antiguedadSinPrecio_6, col6.antiguedadConPrecio AS antiguedadConPrecio_6,
        ROUND((col6.PromObs/col5.PromObs*100-100)::NUMERIC,1)::NUMERIC(8,1) AS Variacion_6, 
        p6.tipoPrecio AS tipoPrecio_6, v6.razon as razon_6,        
        matrizresultados_atributos_fun(p.periodo1::text, x.informante, x.producto::text, x.observacion, 1) AS atributo_1,
        matrizresultados_atributos_fun(p.periodo2::text, x.informante, x.producto::text, x.observacion, 1) AS atributo_2,
        matrizresultados_atributos_fun(p.periodo3::text, x.informante, x.producto::text, x.observacion, 1) AS atributo_3,
        matrizresultados_atributos_fun(p.periodo4::text, x.informante, x.producto::text, x.observacion, 1) AS atributo_4,
        matrizresultados_atributos_fun(p.periodo5::text, x.informante, x.producto::text, x.observacion, 1) AS atributo_5,
        matrizresultados_atributos_fun(p.periodo6::text, x.informante, x.producto::text, x.observacion, 1) AS atributo_6,
        p.periodo6
  FROM  matrizperiodos6 as p 
    JOIN (SELECT r.producto, i.tipoinformante, r.informante, r.observacion, a.periodo6 
            FROM calObs r, matrizperiodos6 a, informantes i
            WHERE  ( a.periodo1 IS NULL OR r.periodo >= a.periodo1) AND r.periodo <=a.periodo6 
               AND r.informante= i.informante
            GROUP BY r.producto, i.tipoinformante, r.informante, r.observacion, a.periodo6) x  ON x.periodo6= p.periodo6
      LEFT JOIN (select c.* from CalObs c join calculos_def cd on c.calculo = cd.calculo where cd.principal) col1 ON col1.informante=x.informante AND col1.observacion=x.observacion AND col1.producto=x.producto AND col1.periodo= p.periodo1 
      LEFT JOIN (select c.* from CalObs c join calculos_def cd on c.calculo = cd.calculo where cd.principal) col2 ON col2.informante=x.informante AND col2.observacion=x.observacion AND col2.producto=x.producto AND col2.periodo= p.periodo2 
      LEFT JOIN (select c.* from CalObs c join calculos_def cd on c.calculo = cd.calculo where cd.principal) col3 ON col3.informante=x.informante AND col3.observacion=x.observacion AND col3.producto=x.producto AND col3.periodo= p.periodo3 
      LEFT JOIN (select c.* from CalObs c join calculos_def cd on c.calculo = cd.calculo where cd.principal) col4 ON col4.informante=x.informante AND col4.observacion=x.observacion AND col4.producto=x.producto AND col4.periodo= p.periodo4 
      LEFT JOIN (select c.* from CalObs c join calculos_def cd on c.calculo = cd.calculo where cd.principal) col5 ON col5.informante=x.informante AND col5.observacion=x.observacion AND col5.producto=x.producto AND col5.periodo= p.periodo5 
      LEFT JOIN (select c.* from CalObs c join calculos_def cd on c.calculo = cd.calculo where cd.principal) col6 ON col6.informante=x.informante AND col6.observacion=x.observacion AND col6.producto=x.producto AND col6.periodo= p.periodo6 
      LEFT JOIN relpre p1 ON p1.informante=x.informante AND p1.observacion=x.observacion AND p1.producto=x.producto AND p1.visita= 1 AND p1.periodo= p.periodo1 
      LEFT JOIN relpre p2 ON p2.informante=x.informante AND p2.observacion=x.observacion AND p2.producto=x.producto AND p2.visita= 1 AND p2.periodo= p.periodo2
      LEFT JOIN relpre p3 ON p3.informante=x.informante AND p3.observacion=x.observacion AND p3.producto=x.producto AND p3.visita= 1 AND p3.periodo= p.periodo3
      LEFT JOIN relpre p4 ON p4.informante=x.informante AND p4.observacion=x.observacion AND p4.producto=x.producto AND p4.visita= 1 AND p4.periodo= p.periodo4
      LEFT JOIN relpre p5 ON p5.informante=x.informante AND p5.observacion=x.observacion AND p5.producto=x.producto AND p5.visita= 1 AND p5.periodo= p.periodo5
      LEFT JOIN relpre p6 ON p6.informante=x.informante AND p6.observacion=x.observacion AND p6.producto=x.producto AND p6.visita= 1 AND p6.periodo= p.periodo6
      LEFT JOIN relvis v1 ON v1.informante=x.informante AND v1.formulario=p1.formulario AND v1.visita= 1 AND v1.periodo= p.periodo1
      LEFT JOIN relvis v2 ON v2.informante=x.informante AND v2.formulario=p2.formulario AND v2.visita= 1 AND v2.periodo= p.periodo2
      LEFT JOIN relvis v3 ON v3.informante=x.informante AND v3.formulario=p3.formulario AND v3.visita= 1 AND v3.periodo= p.periodo3
      LEFT JOIN relvis v4 ON v4.informante=x.informante AND v4.formulario=p4.formulario AND v4.visita= 1 AND v4.periodo= p.periodo4
      LEFT JOIN relvis v5 ON v5.informante=x.informante AND v5.formulario=p5.formulario AND v5.visita= 1 AND v5.periodo= p.periodo5
      LEFT JOIN relvis v6 ON v6.informante=x.informante AND v6.formulario=p6.formulario AND v6.visita= 1 AND v6.periodo= p.periodo6
      LEFT JOIN periodos p0 ON p0.periodo=p.periodo1 AND p0.periodoAnterior <>p.periodo1
      LEFT JOIN (select c.* from CalObs c join calculos_def cd on c.calculo = cd.calculo where cd.principal) col0 
        ON col0.informante=x.informante AND col0.observacion=x.observacion AND col0.producto=x.producto AND col0.periodo= p0.periodoAnterior;
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW preciosmedios_albs AS 
 SELECT gruponivel1, nombregruponivel1, x.grupopadre, x.nombregrupopadre, x.producto, x.nombreproducto, x.unidadmedidaabreviada,
        ROUND(c1.promdiv::DECIMAL,2) AS promprod1,
        ROUND(c2.promdiv::DECIMAL,2) AS promprod2, 
        ROUND(c3.promdiv::DECIMAL,2) AS promprod3, 
        ROUND(c4.promdiv::DECIMAL,2) AS promprod4,
        ROUND(c5.promdiv::DECIMAL,2) AS promprod5, 
        ROUND(c6.promdiv::DECIMAL,2) AS promprod6, 
        c1.periodo as periodo1 , c2.periodo as periodo2 ,c3.periodo as periodo3 ,c4.periodo as periodo4, c5.periodo as periodo5, c6.periodo as periodo6,
        x.agrupacion   
   FROM cvp.matrizperiodos6 p
   JOIN ( SELECT c.producto, p.nombreproducto, p.unidadmedidaabreviada, g.agrupacion, c.calculo, a.periodo6, g.nivel, g.grupopadre,g2.nombregrupo as nombregrupopadre,g2.grupopadre as gruponivel1, g3.nombregrupo as  nombregruponivel1 
            FROM cvp.caldiv c
            JOIN cvp.calculos_def cd on c.calculo = cd.calculo
            JOIN cvp.grupos g ON g.grupo = c.producto AND g.esproducto = 'S'
            JOIN cvp.productos p ON g.grupo = p.producto AND g.esproducto = 'S'
            JOIN cvp.matrizperiodos6 a ON (a.periodo1 IS NULL OR c.periodo >= a.periodo1) AND c.periodo <= a.periodo6
            LEFT JOIN cvp.grupos g2 ON  g.grupopadre=g2.grupo AND g2.agrupacion=g.agrupacion
            LEFT JOIN cvp.grupos g3 ON g2.grupopadre=g3.grupo AND g3.agrupacion=g2.agrupacion
            WHERE cd.principal AND g.esproducto = 'S'  AND g.agrupacion='C'  AND c.division='0' -- AND g.agrupacion in ('A','B','C')
            GROUP BY c.producto, p.nombreproducto, p.unidadmedidaabreviada, g.agrupacion, c.calculo, a.periodo6, g.nivel, g.grupopadre,g2.nombregrupo,g2.nombregrupo,g2.grupopadre,g3.nombregrupo
        ) x ON x.periodo6 = p.periodo6
   LEFT JOIN cvp.caldiv c1 ON x.producto = c1.producto AND c1.periodo = p.periodo1 AND c1.calculo = x.calculo AND c1.division='0'
   LEFT JOIN cvp.caldiv c2 ON x.producto= c2.producto AND c2.periodo = p.periodo2 AND c2.calculo = x.calculo  AND c2.division='0'
   LEFT JOIN cvp.caldiv c3 ON x.producto = c3.producto AND c3.periodo = p.periodo3 AND c3.calculo = x.calculo AND c3.division='0'
   LEFT JOIN cvp.caldiv c4 ON x.producto = c4.producto AND c4.periodo = p.periodo4 AND c4.calculo = x.calculo AND c4.division='0'
   LEFT JOIN cvp.caldiv c5 ON x.producto = c5.producto AND c5.periodo = p.periodo5 AND c5.calculo = x.calculo AND c5.division='0'
   LEFT JOIN cvp.caldiv c6 ON x.producto = c6.producto AND c6.periodo = p.periodo6 AND c6.calculo = x.calculo AND c6.division='0'
   LEFT JOIN cvp.periodos p0 ON p0.periodo = p.periodo1 AND p0.periodoanterior <> p.periodo1
   LEFT JOIN cvp.caldiv cl0 ON x.producto = cl0.producto AND cl0.periodo = p0.periodoanterior AND cl0.calculo = x.calculo AND cl0.division='0'
   ORDER BY agrupacion, periodo6, gruponivel1, grupopadre, producto;        
---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW preciosmedios_albs_var AS 
  SELECT g2.grupopadre AS gruponivel1, g3.nombregrupo AS nombregruponivel1, g.grupopadre, g2.nombregrupo AS nombregrupopadre, c.producto,
         coalesce(p.nombreparapublicar::character varying(250),p.nombreproducto) as nombreproducto,p.unidadmedidaabreviada, 
         ROUND(c0.promdiv::DECIMAL,2) AS promprodant, 
         ROUND(c.promdiv ::DECIMAL,2) AS promprod,  
         CASE WHEN c0.promdiv=0 THEN null ELSE round((c.promdiv/c0.promdiv*100-100)::decimal,1) END AS variacion,
         CASE WHEN ca.promdiv=0 THEN null ELSE round((c.promdiv/ca.promdiv*100-100)::decimal,1) END AS variaciondiciembre,
         CASE WHEN cm.promdiv=0 THEN null ELSE round((c.promdiv/cm.promdiv*100-100)::decimal,1) END AS variacionmesanioanterior,         
         g.agrupacion,c.calculo, c.periodo, c0.calculo AS calculoant,c0.periodo periodoant,ca.periodo periododiciembre,cm.periodo periodoaniooanterior
    FROM cvp.caldiv c
    JOIN cvp.calculos_def df on c.calculo = df.calculo
    JOIN cvp.grupos g ON g.grupo=c.producto AND g.esproducto='S'
    JOIN cvp.productos p ON g.grupo=p.producto AND g.esproducto='S'
    JOIN cvp.calculos pa ON c.periodo=pa.periodo and  'A'=pa.agrupacionprincipal AND  0=pa.calculo
    JOIN cvp.caldiv c0 ON  c.producto=c0.producto AND c0.calculo=pa.calculoAnterior AND  c0.periodo=pa.periodoAnterior  AND c0.division='0'
    LEFT JOIN cvp.caldiv ca ON c.producto=ca.producto AND c.calculo=ca.calculo AND  ca.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m12' AND ca.division='0'
    LEFT JOIN cvp.caldiv cm ON c.producto=cm.producto AND c.calculo=cm.calculo AND  cm.periodo='a'||(substr(c.periodo,2,4)::integer-1)||'m'||substr(c.periodo,7,2)  AND cm.division='0'
    LEFT JOIN cvp.grupos g2 ON g.grupopadre = g2.grupo AND g2.agrupacion = g.agrupacion
    LEFT JOIN cvp.grupos g3 ON g2.grupopadre = g3.grupo AND g3.agrupacion = g2.agrupacion
    WHERE df.principal AND  (g.esproducto='S'  AND g.agrupacion='C') AND c.division='0'
   ORDER BY agrupacion, periodo, gruponivel1, grupopadre, producto;
------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW promedios_maximos_minimos AS 
 SELECT v.periodo, v.producto, f.nombreproducto, n.tipoinformante, r.despacho, v.observacion,
   round(EXP(AVG(LN(v.precionormalizado)))::DECIMAL,2) avgp, 
   round(MIN(v.precionormalizado)::DECIMAL,2) minp,  round(MAX(v.precionormalizado)::DECIMAL,2) maxp,
   round((EXP(AVG(LN((v.precionormalizado/COALESCE(v.precionormalizado_1,co.promobs)))))*100 -100)::DECIMAL,1) as avgv, 
   round(MIN((v.precionormalizado/COALESCE(v.precionormalizado_1,co.promobs))*100 -100)::DECIMAL,1) as minv,   
   round(MAX((v.precionormalizado/COALESCE(v.precionormalizado_1,co.promobs))*100 -100)::DECIMAL,1) as maxv,
   SUM( CASE WHEN ta.espositivo='S'  THEN 1
             ELSE 0
             END) as cantreales,
   SUM( CASE WHEN ta.espositivo='N'  THEN 1
             ELSE 0
             END) as cantnegativos, 
   SUM(CASE WHEN coalesce(v.cambio,'0')='C'  THEN 1
            ELSE 0
            END)  as cantcambios,       
   COUNT(*) cantcasos,   
   SUM( CASE WHEN 
             (SELECT ta.espositivo
                FROM cvp.relvis vi
                WHERE ta.tipoprecio=coalesce(v.tipoprecio,'0') --si comento esta condicion tarda mas 
                AND vi.informantereemplazante is not null
                AND v.informante=vi.informantereemplazante
                AND v.periodo=vi.periodo
                AND v.visita=vi.visita )='S'   THEN 1
            ELSE 0
            END) as cantreemplazos,  
    SUM( CASE WHEN v.tipoprecio is null   THEN 1
             ELSE 0
             END) as cantnulos 
   FROM cvp.relpre_1 v
   JOIN cvp.productos f ON v.producto = f.producto
   JOIN cvp.informantes n ON v.informante = n.informante
   JOIN cvp.rubros r ON n.rubro=r.rubro 
   LEFT JOIN cvp.tipopre ta ON ta.tipoprecio=coalesce(v.tipoprecio,'0')
   LEFT JOIN (select c.* from cvp.CalObs c join cvp.calculos_def cd on c.calculo = cd.calculo where cd.principal) co 
                           ON v.periodo_1 = co.periodo  AND v.informante = co.informante 
                           AND v.producto = co.producto AND v.observacion = co.observacion 
   GROUP BY v.periodo,v.producto,f.nombreproducto,n.tipoinformante,r.despacho, v.observacion
   ORDER BY v.periodo,v.producto,n.tipoinformante,r.despacho,v.observacion; --confirmar si se agrega observacion al orden
