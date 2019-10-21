CREATE OR REPLACE VIEW hojaderuta AS 
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.fechasalida,
    v.informante,
    i.tipoinformante,
    v.encuestador,
    COALESCE(p.nombre::text || ' '::text, ''::text) || COALESCE(p.apellido, ''::character varying)::text AS nombreencuestador,
        CASE
            WHEN min(v.razon) <> max(v.razon) THEN (min(v.razon) || '~'::text) || max(v.razon)
            ELSE COALESCE(min(v.razon) || ''::text, ''::text)
        END || lpad(' '::text, count(*)::integer, chr(10)) AS razon,
    v.visita,
    i.nombreinformante,
    i.direccion,
    cvp.formularioshdr(v.periodo::text, v.informante, v.visita, v.fechasalida, v.encuestador) AS formularios,
    lpad(' '::text, count(*)::integer, chr(10)) AS espacio,
    COALESCE(i.contacto,'')||chr(10)||COALESCE(i.telcontacto,'') as contacto,
    i.conjuntomuestral,
    i.ordenhdr,
    a.maxperiodoinformado,
    a.minperiodoinformado
   FROM cvp.relvis v
     JOIN cvp.informantes i ON v.informante = i.informante
     LEFT JOIN cvp.personal p ON v.encuestador::text = p.persona::text
     LEFT JOIN (SELECT informante, visita, max(periodo) AS maxperiodoinformado, min(periodo) AS minperiodoinformado
                FROM cvp.control_hojas_ruta
                WHERE control_hojas_ruta.razon = 1
                GROUP BY informante, visita) a ON v.informante = a.informante AND v.visita = a.visita
  GROUP BY v.periodo, v.panel, v.tarea, v.fechasalida, v.informante, i.tipoinformante, v.encuestador, v.visita, 
    COALESCE(p.nombre::text || ' '::text, ''::text) || COALESCE(p.apellido, ''::character varying)::text,
    COALESCE(i.contacto,'')||chr(10)||COALESCE(i.telcontacto,''),    
    i.nombreinformante, i.direccion, i.conjuntomuestral, i.ordenhdr, a.maxperiodoinformado, a.minperiodoinformado ;

GRANT SELECT ON TABLE hojaderuta TO cvp_usuarios;
