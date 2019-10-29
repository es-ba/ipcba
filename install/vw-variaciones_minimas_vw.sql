CREATE OR REPLACE VIEW variaciones_minimas_vw AS
SELECT a.periodo, a.producto, a.nombreproducto, 
  CASE WHEN split_part(variaciones,'|',1) <> '' THEN ROUND(split_part(variaciones,'|',1)::DECIMAL,2) ELSE NULL   END as variacion1,
  CASE WHEN split_part(variaciones,'|',2) <> '' THEN ROUND(split_part(variaciones,'|',2)::DECIMAL,2) ELSE NULL   END as variacion2,
  CASE WHEN split_part(variaciones,'|',3) <> '' THEN ROUND(split_part(variaciones,'|',3)::DECIMAL,2) ELSE NULL   END as variacion3,
  CASE WHEN split_part(variaciones,'|',4) <> '' THEN ROUND(split_part(variaciones,'|',4)::DECIMAL,2) ELSE NULL   END as variacion4,
  CASE WHEN split_part(variaciones,'|',5) <> '' THEN ROUND(split_part(variaciones,'|',5)::DECIMAL,2) ELSE NULL   END as variacion5,
  CASE WHEN split_part(variaciones,'|',6) <> '' THEN ROUND(split_part(variaciones,'|',6)::DECIMAL,2) ELSE NULL   END as variacion6,
  CASE WHEN split_part(variaciones,'|',7) <> '' THEN ROUND(split_part(variaciones,'|',7)::DECIMAL,2) ELSE NULL   END as variacion7,
  CASE WHEN split_part(variaciones,'|',8) <> '' THEN ROUND(split_part(variaciones,'|',8)::DECIMAL,2) ELSE NULL   END as variacion8,
  CASE WHEN split_part(variaciones,'|',9) <> '' THEN ROUND(split_part(variaciones,'|',9)::DECIMAL,2) ELSE NULL   END as variacion9,
  CASE WHEN split_part(variaciones,'|',10) <> '' THEN ROUND(split_part(variaciones,'|',10)::DECIMAL,2) ELSE NULL END as variacion10,
  nullif(split_part(informantes,';',1),'') as informantes1,
  nullif(split_part(informantes,';',2),'') as informantes2,
  nullif(split_part(informantes,';',3),'') as informantes3,
  nullif(split_part(informantes,';',4),'') as informantes4,
  nullif(split_part(informantes,';',5),'') as informantes5,
  nullif(split_part(informantes,';',6),'') as informantes6,
  nullif(split_part(informantes,';',7),'') as informantes7,
  nullif(split_part(informantes,';',8),'') as informantes8,
  nullif(split_part(informantes,';',9),'') as informantes9,
  nullif(split_part(informantes,';',10),'') as informantes10
  FROM (SELECT * FROM
             (SELECT periodo FROM cvp.periodos ORDER BY periodo DESC LIMIT 12) pe JOIN 
             (SELECT producto, nombreproducto FROM cvp.productos WHERE not excluir_control_precios_maxmin) pr on true) a
        LEFT JOIN cvp.periodo_minimas_variaciones(10) m ON a.periodo = m.periodo and a.producto = m.producto and a.nombreproducto = m.nombreproducto 
  ORDER BY a.periodo, a.producto, a.nombreproducto;

GRANT SELECT ON TABLE variaciones_minimas_vw TO cvp_administrador;
