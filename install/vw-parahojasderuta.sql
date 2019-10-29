CREATE OR REPLACE VIEW parahojasderuta AS
 SELECT v.periodo,
    v.panel,
    v.tarea,
    v.informante,
    v.formulario,
    f.nombreformulario,
    v.fechasalida,
    v.razon,
    v.fechageneracion,
    v.visita,
    v.ultimavisita,
    NULLIF(v.razon, 1) AS razonimpresa,
    n.nombreinformante,
    n.tipoinformante,
    n.direccion
   FROM cvp.relvis v
     JOIN cvp.formularios f ON v.formulario = f.formulario
     JOIN cvp.informantes n ON v.informante = n.informante
  ORDER BY v.periodo, v.panel, v.tarea, v.informante, v.formulario;

GRANT SELECT ON TABLE parahojasderuta TO cvp_usuarios;
GRANT SELECT ON TABLE parahojasderuta TO cvp_recepcionista;
