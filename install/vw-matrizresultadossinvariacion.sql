CREATE OR REPLACE VIEW matrizresultadossinvariacion AS
SELECT periodo6 as periodo, 
m.producto  , m.tipoinformante   , m.informante, m.observacion         ,
m.promobs_1 , m.precioobservado_1, m.impobs_1  , m.antiguedadexcluido_1, m.antiguedadsinprecio_1, m.antiguedadconprecio_1, m.variacion_1, m.tipoprecio_1, m.razon_1,
m.promobs_2 , m.precioobservado_2, m.impobs_2  , m.antiguedadexcluido_2, m.antiguedadsinprecio_2, m.antiguedadconprecio_2, m.variacion_2, m.tipoprecio_2, m.razon_2,
m.promobs_3 , m.precioobservado_3, m.impobs_3  , m.antiguedadexcluido_3, m.antiguedadsinprecio_3, m.antiguedadconprecio_3, m.variacion_3, m.tipoprecio_3, m.razon_3,
m.promobs_4 , m.precioobservado_4, m.impobs_4  , m.antiguedadexcluido_4, m.antiguedadsinprecio_4, m.antiguedadconprecio_4, m.variacion_4, m.tipoprecio_4, m.razon_4,
m.promobs_5 , m.precioobservado_5, m.impobs_5  , m.antiguedadexcluido_5, m.antiguedadsinprecio_5, m.antiguedadconprecio_5, m.variacion_5, m.tipoprecio_5, m.razon_5,
m.promobs_6 , m.precioobservado_6, m.impobs_6  , m.antiguedadexcluido_6, m.antiguedadsinprecio_6, m.antiguedadconprecio_6, m.variacion_6, m.tipoprecio_6, m.razon_6,
m.atributo_1, m.atributo_2       , m.atributo_3, m.atributo_4          , m.atributo_5           , m.atributo_6
  FROM cvp.matrizresultados m
  WHERE variacion_1 = 0 
    and variacion_2 = 0 
    and variacion_3 = 0 
    and variacion_4 = 0 
    and variacion_5 = 0 
    and variacion_6 = 0; 

GRANT SELECT ON TABLE matrizresultadossinvariacion TO cvp_administrador;
