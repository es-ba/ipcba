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
            {name:'formulario'           ,typeName:'integer'},
            {name:'nombreformulario'     ,typeName:'text'   },
            {name:'panel'                ,typeName:'integer'},
            {name:'tarea'                ,typeName:'integer'},
            {name:'panel_nuevo'          ,typeName:'integer'},
            {name:'tarea_nueva'          ,typeName:'integer'},
            {name:'campo'                ,typeName:'text'   },
            {name:'change_value'         ,typeName:'text'   },
            {name:'modi_fecha'           ,typeName:'text'   },
            {name:'modi_hora'            ,typeName:'text'   },
            {name:'usuario'              ,typeName:'text'   },
        ],
        primaryKey:['periodo','informante','formulario','visita','campo','change_value'],
        sortColumns:[{column:'periodo'},{column:'panel_nuevo'},{column:'tarea_nueva'},{column:'informante'},{column:'visita'},{column:'formulario'}],
        foreignKeys:[
            {references:'informantes', fields:['informante'] },
        ],
        sql:{from:
            `(SELECT r.periodo, r.informante, r.visita, r.formulario, f.nombreformulario, r_1.panel, r_1.tarea, 
                r.panel as panel_nuevo, r.tarea as tarea_nueva, h.campo, h.change_value, h.modi_fecha, h.modi_hora, h.usuario
                FROM relvis r
                JOIN periodos p ON r.periodo = p.periodo
                JOIN relvis r_1 ON r_1.periodo = p.periodoanterior and r_1.informante = r.informante and 
                                   r_1.formulario = r.formulario and r.visita = r_1.visita
                JOIN formularios f on r.formulario = f.formulario
                LEFT JOIN (SELECT concated_pk, campo, change_value, to_char(momento,'YYYY-MM-DD') modi_fecha, to_char(momento,'HH24:MI') modi_hora, usuario
                            FROM his.his_campos_cvp 
                            WHERE esquema= 'cvp' and tabla='relvis' and (campo = 'panel' or campo = 'tarea') and operacion = 'U') h
                            ON concated_pk = r.periodo||'|'||r.informante||'|'||r.visita||'|'||r.formulario                      
              WHERE r.panel IS DISTINCT FROM r_1.panel or r.tarea IS DISTINCT FROM r_1.tarea)`
            },
    },context);
}