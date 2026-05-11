"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'personal_sin_carga',
        fields:[
            {name:'fecha'                            , typeName:'date'},
            {name:'persona'                          , typeName:'text'},
            {name:'labor'                            , typeName:'text'},
        ],
        primaryKey:['fecha','persona'],
        foreignKeys:[
            {references:'personal', fields:['persona']},
        ],
        sortColumns:[{column:'fecha'}, {column:'persona'}],
        sql:{
            from: `(SELECT p.persona, f.fecha, p.labor
                FROM (
                    SELECT per.persona, per.labor
                    FROM personal per
                    JOIN tareas t ON per.persona = t.encuestador
                    JOIN ipcba.usuarios u ON per.username = u.usu_usu
                    WHERE t.operativo = 'C'
                      AND per.labor IN ('E', 'S')
                      AND per.activo = 'S'
                      AND u.usu_activo = true
                ) p
                CROSS JOIN (
                    SELECT DISTINCT f.fecha
                    FROM fechas f
                    JOIN relpan rp ON f.fecha = rp.fechasalida
                    WHERE f.seleccionada_planificacion = 'S'
                ) f
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM reltar rt
                    JOIN relpan rp2 ON rp2.periodo = rt.periodo AND rp2.panel = rt.panel
                    WHERE rt.encuestador = p.persona
                      AND f.fecha BETWEEN COALESCE(rt.fechasalidadesde, rp2.fechasalida)
                                      AND COALESCE(rt.fechasalidahasta, rp2.fechasalida)
                )
                AND NOT EXISTS (
                    SELECT 1
                    FROM licencias l
                    WHERE l.persona = p.persona
                      AND f.fecha BETWEEN l.fechadesde AND l.fechahasta
                )
            )`,
        }
    },context);
}