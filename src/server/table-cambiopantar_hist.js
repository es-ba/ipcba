"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'cambiopantar_hist',
        dbOrigin:'view',
        allow:{
            insert:false,
            delete:false,
            update:false,
        },        
        fields:[
            {name:'periodo'              ,typeName:'text'   }, 
            {name:'informante'           ,typeName:'integer'},
            {name:'visita'               ,typeName:'integer'},
            {name:'panel'                ,typeName:'integer'},
            {name:'tarea'                ,typeName:'integer'},
            {name:'panel_nuevo'          ,typeName:'integer'},
            {name:'tarea_nueva'          ,typeName:'integer'},
            {name:'formularios'          ,typeName:'text'   },
            {name:'modi_fecha'           ,typeName:'text'   },
            {name:'modi_value'           ,typeName:'text'   },
        ],
        primaryKey:['periodo','informante','visita','panel','tarea','panel_nuevo','tarea_nueva','modi_fecha'],
        sortColumns:[{column:'modi_fecha'}],
        foreignKeys:[
            {references:'informantes', fields:['informante'] },
        ],
        sql:{from:
            `(SELECT r.periodo, r.informante, r.visita, r_1.panel, r_1.tarea, r.panel as panel_nuevo, r.tarea as tarea_nueva, 
                string_agg(distinct concat (r.formulario::text,':', f.nombreformulario), chr(10) order by concat (r.formulario::text,':', f.nombreformulario)) formularios,
                concat(h.modi_fecha,' ',h.modi_hora,' ', h.usuario) modi_fecha,
                string_agg (distinct concat (h.campo,' ',change_value, ' '), ' ' order by concat (h.campo,' ',change_value, ' ')) as modi_value
                FROM relvis r
                JOIN periodos p ON r.periodo = p.periodo
                JOIN relvis r_1 ON r_1.periodo = p.periodoanterior and r_1.informante = r.informante and 
                                   r_1.formulario = r.formulario and r.visita = r_1.visita
                JOIN formularios f on r.formulario = f.formulario
                LEFT JOIN (SELECT concated_pk, campo, change_value, to_char(momento,'YYYY-MM-DD') modi_fecha, to_char(momento,'HH24:MI:SS') modi_hora, usuario
                            FROM his.his_campos_cvp 
                            WHERE esquema= 'cvp' and tabla='relvis' and (campo = 'panel' or campo = 'tarea') and operacion = 'U') h
                            ON concated_pk = r.periodo||'|'||r.informante||'|'||r.visita||'|'||r.formulario                      
              WHERE r.panel IS DISTINCT FROM r_1.panel or r.tarea IS DISTINCT FROM r_1.tarea
              group by r.periodo, r.informante, r.visita, r_1.panel, r.panel, r_1.tarea, r.tarea, concat(h.modi_fecha,' ',h.modi_hora,' ', h.usuario))`
            },
    },context);
}