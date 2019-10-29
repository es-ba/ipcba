CREATE OR REPLACE VIEW paralistadodecontroldeinformantes AS 
 SELECT distinct r.periodo, r.informante, r.panel, r.tarea, r.visita, r.formulario, r.razon, 
   COALESCE(z.escierredefinitivofor::character varying, 'N'::character varying) AS escierredefinitivofor, 
   COALESCE(z.espositivoformulario::character varying, 'N'::character varying) AS espositivofor, r.periodo_1, r.visita_1, r_1.razon AS razon_1, 
   COALESCE(z_1.escierredefinitivofor::character varying, 'N'::character varying) AS escierredefinitivofor_1, 
   COALESCE(z_1.espositivoformulario::character varying, 'N'::character varying) AS espositivofor_1, c.cantidadregistros, c.cantidadprecios, 
   COALESCE(j.atributosnoingresados, 0::bigint) AS atributosnoing, 
    CASE
        WHEN r.razon IS NULL THEN 'Falta ingresar'::text
        ELSE 
        CASE
            WHEN i.razonesnocoherentes = 'S'::text THEN 'Razones incoherentes entre formularios'::text
            ELSE 
            CASE
                WHEN COALESCE(z_1.escierredefinitivofor::character varying, 'N'::character varying)::text = 'S'::text AND COALESCE(z.escierredefinitivofor::character varying, 'N'::character varying)::text = 'N'::text THEN 'Razón incoherente respecto a la razón de la visita anterior'::text
                WHEN c.cantidadregistros = 0 THEN 'Falta generar renglones de precios'::text
                WHEN COALESCE(z.espositivoformulario::character varying, 'N'::character varying)::text = 'N'::text AND c.cantidadprecios > 0 THEN 'Respuesta negativa con algún precio ingresado'::text
                WHEN COALESCE(z.espositivoformulario::character varying, 'N'::character varying)::text = 'S'::text AND c.cantidadprecios < c.cantidadregistros THEN 'Falta ingresar renglones de precios'::text
                WHEN COALESCE(j.atributosnoingresados, 0::bigint) > 0 THEN 'Falta ingresar renglones de atributos'::text
                ELSE NULL::text
            END
        END
    END AS leyenda
   FROM (SELECT rv.periodo, rv.informante, rv.visita, rv.formulario, rv.razon, rv.panel, rv.tarea,
          rp_1.producto, rp_1.observacion, rp_1.periodo_1, rp_1.visita_1
          FROM cvp.relvis rv 
          LEFT JOIN cvp.relpre_1 rp_1 ON rv.periodo = rp_1.periodo AND rv.informante = rp_1.informante AND rv.visita = rp_1.visita
             AND rv.formulario = rp_1.formulario) r
   LEFT JOIN  (SELECT r.periodo, r.informante, r.visita, 'S'::text AS razonesnocoherentes
                 FROM cvp.relvis r
                 LEFT JOIN cvp.razones z ON r.razon = z.razon
                 GROUP BY r.periodo, r.informante, r.visita
                 HAVING min(COALESCE(z.escierredefinitivoinf::character varying, 'N'::character varying)::text) <> 
                        max(COALESCE(z.escierredefinitivoinf::character varying, 'N'::character varying)::text)) i 
                 ON r.periodo::text = i.periodo::text AND r.informante = i.informante AND r.visita = i.visita
   LEFT JOIN cvp.relvis r_1 
          ON r.periodo_1::text = r_1.periodo::text AND r.visita_1 = r_1.visita AND r.formulario = r_1.formulario AND r.informante = r_1.informante
   LEFT JOIN cvp.razones z ON r.razon = z.razon
   LEFT JOIN cvp.razones z_1 ON r_1.razon = z_1.razon
   LEFT JOIN ( SELECT v.periodo, v.informante, v.visita, v.formulario, COALESCE(a.cantidadregistros, 0::bigint) AS cantidadregistros, COALESCE(b.cantidadprecios, 0::bigint) AS cantidadprecios
   FROM ( SELECT relvis.periodo, relvis.informante, relvis.visita, relvis.formulario
           FROM cvp.relvis) v
   LEFT JOIN ( SELECT relpre.periodo, relpre.informante, relpre.visita, relpre.formulario, count(*) AS cantidadregistros
           FROM cvp.relpre
          GROUP BY relpre.periodo, relpre.informante, relpre.visita, relpre.formulario) a ON v.periodo::text = a.periodo::text AND v.informante = a.informante AND v.visita = a.visita AND v.formulario = a.formulario
   LEFT JOIN ( SELECT r.periodo, r.informante, r.visita, r.formulario, count(*) AS cantidadprecios
      FROM cvp.relpre r
   JOIN cvp.tipopre t ON r.tipoprecio::text = t.tipoprecio::text AND (t.espositivo::text = 'S'::text AND r.precio IS NOT NULL OR t.espositivo::text = 'N'::text AND r.precio IS NULL)
  GROUP BY r.periodo, r.informante, r.visita, r.formulario) b ON v.periodo::text = b.periodo::text AND v.informante = b.informante AND v.visita = b.visita AND v.formulario = b.formulario) c ON r.periodo::text = c.periodo::text AND r.informante = c.informante AND r.visita = c.visita AND r.formulario = c.formulario
   LEFT JOIN ( SELECT p.periodo, p.informante, p.visita, p.formulario, count(*) AS atributosnoingresados
   FROM cvp.relpre p
   JOIN cvp.relatr a ON a.periodo::text = p.periodo::text AND a.producto::text = p.producto::text AND a.observacion = p.observacion AND a.informante = p.informante AND a.visita = p.visita
   JOIN cvp.tipopre t ON p.tipoprecio::text = t.tipoprecio::text
   JOIN cvp.prodatr pa ON pa.atributo = a.atributo AND pa.producto::text = a.producto::text
  WHERE t.espositivo::text = 'S'::text AND a.valor IS NULL AND pa.normalizable::text = 'S'::text
  GROUP BY p.periodo, p.informante, p.visita, p.formulario) j ON r.periodo::text = j.periodo::text AND r.informante = j.informante AND r.visita = j.visita AND r.formulario = j.formulario;

GRANT SELECT ON TABLE paralistadodecontroldeinformantes TO cvp_usuarios;
