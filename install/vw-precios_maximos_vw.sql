CREATE OR REPLACE VIEW precios_maximos_vw AS
SELECT a.periodo, a.producto, a.nombreproducto, 
  CASE WHEN split_part(precios,'|',1 ) <> '' THEN split_part(precios,'|',1 ) ELSE NULL END as precio1,
  CASE WHEN split_part(precios,'|',2 ) <> '' THEN split_part(precios,'|',2 ) ELSE NULL END as precio2,
  CASE WHEN split_part(precios,'|',3 ) <> '' THEN split_part(precios,'|',3 ) ELSE NULL END as precio3,
  CASE WHEN split_part(precios,'|',4 ) <> '' THEN split_part(precios,'|',4 ) ELSE NULL END as precio4,
  CASE WHEN split_part(precios,'|',5 ) <> '' THEN split_part(precios,'|',5 ) ELSE NULL END as precio5,
  CASE WHEN split_part(precios,'|',6 ) <> '' THEN split_part(precios,'|',6 ) ELSE NULL END as precio6,
  CASE WHEN split_part(precios,'|',7 ) <> '' THEN split_part(precios,'|',7 ) ELSE NULL END as precio7,
  CASE WHEN split_part(precios,'|',8 ) <> '' THEN split_part(precios,'|',8 ) ELSE NULL END as precio8,
  CASE WHEN split_part(precios,'|',9 ) <> '' THEN split_part(precios,'|',9 ) ELSE NULL END as precio9,
  CASE WHEN split_part(precios,'|',10) <> '' THEN split_part(precios,'|',10) ELSE NULL END as precio10,
  split_part(informantes,';',1 ) as informantes1,
  split_part(informantes,';',2 ) as informantes2,
  split_part(informantes,';',3 ) as informantes3,
  split_part(informantes,';',4 ) as informantes4,
  split_part(informantes,';',5 ) as informantes5,
  split_part(informantes,';',6 ) as informantes6,
  split_part(informantes,';',7 ) as informantes7,
  split_part(informantes,';',8 ) as informantes8,
  split_part(informantes,';',9 ) as informantes9,
  split_part(informantes,';',10) as informantes10
  FROM (SELECT * FROM
             (SELECT periodo FROM cvp.periodos ORDER BY periodo DESC LIMIT 12) pe JOIN 
             (SELECT producto, nombreproducto FROM cvp.productos WHERE not excluir_control_precios_maxmin) pr on true) a
        LEFT JOIN cvp.periodo_maximos_precios(10) m ON a.periodo = m.periodo and a.producto = m.producto and a.nombreproducto = m.nombreproducto 
ORDER BY a.periodo, a.producto, a.nombreproducto;

GRANT SELECT ON TABLE precios_maximos_vw TO cvp_administrador;
