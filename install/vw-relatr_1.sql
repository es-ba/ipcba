CREATE OR REPLACE VIEW relatr_1 AS 
 SELECT r.periodo, r.visita, r.producto, r.observacion, r.informante, r.atributo, r.valor
 , r_1.periodo AS periodo_1, r_1.visita AS visita_1, r_1.valor AS valor_1
   FROM cvp.relatr r
   --LEFT JOIN cvp.periodos p ON r.periodo = p.periodo
   LEFT JOIN cvp.relpre p_1 
      ON p_1.periodo = CASE WHEN r.visita > 1 THEN r.periodo 
                            ELSE --p.periodoanterior
                                (SELECT MAX(periodo)
                                    FROM cvp.relpre
                                    WHERE periodo < r.periodo
                                      AND producto = r.producto AND observacion = r.observacion AND informante = r.informante
                                )
                       END 
         AND ((p_1.ultima_visita = TRUE AND r.visita =1) or (r.visita > 1 and p_1.visita=r.visita -1)) 
         AND p_1.informante = r.informante AND p_1.producto = r.producto AND p_1.observacion = r.observacion
   LEFT JOIN cvp.relatr r_1 ON r_1.periodo = p_1.periodo AND r_1.visita= p_1.visita 
         AND r_1.informante = r.informante AND r_1.producto = r.producto AND r_1.observacion = r.observacion
         AND r_1.atributo = r.atributo;
   
GRANT SELECT ON TABLE relatr_1 TO cvp_usuarios;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE relatr_1 TO cvp_administrador;
