set search_path = cvp;
drop view if exists paralistadodecontroldecm;
DROP view if exists informantes_estado;
CREATE or REPLACE view informantes_estado as
SELECT i.informante, periodo, ingresando, mincierreinf, maxcierreinf, mincierrefor, maxcierrefor,
       CASE 
            WHEN W.periodo is null THEN 'No Usado'
            --ultima visita en un periodo ABIERTO para ingreso:
            WHEN ingresando = 'S' THEN
            CASE 
                --ultima visita no es cierre definitivo de informante y es primera aparicion aún sin ingresar
                WHEN mincierreinf = 'N' AND maxcierreinf = 'N' AND informantenuevo is not null THEN 'Nuevo'
                --ultima visita no es cierre definitivo de informante y ya tiene visitas ingresadas
                WHEN mincierreinf = 'N' AND maxcierreinf = 'N' AND informantenuevo is null THEN 'Activo'
                --ultima visita es cierre definitivo de informante
                WHEN mincierreinf = 'S' AND maxcierreinf = 'S' THEN 'Inactivo'
                --aún no puedo determinar, veo que pasa anivel de formulario
                WHEN mincierreinf = 'N' AND maxcierreinf = 'S' THEN
                        --ultima visita con todos sus formularios con cierre definitivo de formulario
                   CASE WHEN mincierrefor = 'S' AND maxcierrefor = 'S' THEN 'Inactivo'
                        --ultima visita con todos sus formularios sin cierre definitivo de formulario
                        WHEN mincierrefor = 'N' AND maxcierrefor = 'N' THEN 'Activo'
                        --ultima visita con por lo menos uno de sus formularios sin cierre definitivo de formulario
                        WHEN mincierrefor = 'N' AND maxcierrefor = 'S' THEN 'Activo'
                   END
            END
            --ultima visita en un periodo CERRADO para ingreso:
            WHEN ingresando = 'N' THEN 'Inactivo'
       END AS estado
    FROM
    informantes i 
    LEFT JOIN
    (SELECT periodo, informante, ingresando, min(escierredefinitivoinf) mincierreinf, max(escierredefinitivoinf) maxcierreinf,
            min(escierredefinitivofor) mincierrefor, max(escierredefinitivofor) maxcierrefor
       FROM 
       (
       SELECT coalesce(escierredefinitivoinf,'N') escierredefinitivoinf,
              coalesce(escierredefinitivofor,'N') escierredefinitivofor, ingresando, r.* 
       FROM relvis r
       JOIN periodos p on r.periodo = p.periodo 
       JOIN (SELECT informante, MAX(periodo) maxperiodoaparicion
             FROM relvis
             WHERE ultima_visita
             GROUP BY informante) pa ON r.informante = pa.informante and r.periodo = pa.maxperiodoaparicion
       LEFT JOIN razones z on r.razon = z.razon
       ) Q
    GROUP BY periodo, informante, ingresando
    ) W ON i.informante = W.informante
    LEFT JOIN
    (SELECT informante informantenuevo
       FROM relvis
       GROUP BY informante
       HAVING count (distinct periodo) = 1 and min(razon) is null and max(razon) is null) N ON W.informante = N.informantenuevo;
 
GRANT SELECT ON TABLE informantes_estado TO cvp_administrador;

CREATE OR REPLACE VIEW paralistadodecontroldecm AS
 SELECT
    ccm.conjuntomuestral,
    ccm.tiposinformante,
    ccm.rubros,
    ccm.cantactivos,
    ccm.cantreemplazos,
        CASE
            WHEN ccm.tiposinformante > 1 THEN 'CM con distintos tipos de informante'
            ELSE NULL
        END AS leyenda1,
        CASE
            WHEN ccm.rubros > 1 THEN 'CM con distintos rubros'
            ELSE NULL
        END AS leyenda2,
        CASE
            WHEN ccm.cantactivos > 1 THEN 'CM con más de un informante activo'
            WHEN ccm.cantactivos = 0 THEN 'CM sin informante activo'
            ELSE NULL
        END AS leyenda3,
        CASE
            WHEN ccm.cantreemplazos = 0 THEN 'CM sin informantes para reemplazos'
            ELSE NULL
        END AS leyenda4
   FROM ( SELECT 
            pc.conjuntomuestral,
            t.tiposinformante,
            r.rubros,
            COALESCE(ac.cantidadactivos, 0::bigint) AS cantactivos,
            COALESCE(re.cantidadreemplazos, 0::bigint) AS cantreemplazos
           FROM conjuntomuestral pc
             LEFT JOIN (SELECT conjuntomuestral, count(DISTINCT tipoinformante) AS tiposinformante
                          FROM informantes
                          GROUP BY conjuntomuestral) t ON pc.conjuntomuestral = t.conjuntomuestral
             LEFT JOIN (SELECT conjuntomuestral, count(DISTINCT rubro) AS rubros
                          FROM informantes
                          GROUP BY conjuntomuestral) r ON pc.conjuntomuestral = r.conjuntomuestral
             LEFT JOIN (SELECT conjuntomuestral, count(*) cantidadactivos
                          FROM informantes a JOIN informantes_estado e on a.informante = e.informante
                          WHERE e.estado = 'Activo'
                          GROUP BY conjuntomuestral) ac ON pc.conjuntomuestral = ac.conjuntomuestral
             LEFT JOIN (SELECT conjuntomuestral, count(*) cantidadreemplazos
                          FROM informantes a JOIN informantes_estado e on a.informante = e.informante
                          WHERE e.estado = 'No usado'
                          GROUP BY conjuntomuestral) re ON pc.conjuntomuestral = re.conjuntomuestral) ccm;

GRANT SELECT ON TABLE paralistadodecontroldecm TO cvp_usuarios;
GRANT SELECT ON TABLE paralistadodecontroldecm TO cvp_recepcionista;
