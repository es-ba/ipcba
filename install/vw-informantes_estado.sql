--No usado      presentes en informantes pero no en relvis
--Nuevos        incorporados a relvis en el último periodo generado, aún sin razon
--Inactivo      con razon escierredefinitivoinf en el último periodo generado o
--              con razon escierredefinitivofor para todos sus formularios en el último periodo generado o
--              con última aparición en un periodo ya cerrado para ingreso
--Activo        con razon NO escierredefinitivoinf en el último periodo generado o
--              con razon NO escierredefinitivofor para por lo menos uno de sus formularios en el último periodo generado

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