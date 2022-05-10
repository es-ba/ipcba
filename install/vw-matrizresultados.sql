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

GRANT SELECT ON TABLE matrizresultados TO cvp_administrador;
