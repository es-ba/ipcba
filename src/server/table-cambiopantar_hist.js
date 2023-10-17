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
            {name:'panel'                ,typeName:'integer'},
            {name:'tarea'                ,typeName:'integer'},
            {name:'panel_nuevo'          ,typeName:'integer'},
            {name:'tarea_nueva'          ,typeName:'integer'},
            {name:'cantform'             ,typeName:'integer'},
            {name:'formularios'          ,typeName:'text'   },
            {name:'modi_fec'             ,typeName:'text'   },
            {name:'modi_usu'             ,typeName:'text'   },
        ],
        primaryKey:['periodo','informante','panel','tarea'],
        sortColumns:[{column:'periodo'},{column:'panel_nuevo'},{column:'tarea_nueva'}],
        foreignKeys:[
            {references:'informantes', fields:['informante'] },
        ],
        sql:{from:
            `(SELECT r.periodo, r.informante, r_1.panel, r_1.tarea, r.panel as panel_nuevo, r.tarea as tarea_nueva,
                count(*) cantform, string_agg (distinct r.formulario::text||' '||nombreformulario, chr(10)) formularios,
                string_agg (distinct to_char(h.momento,'YYYY-MM-DD HH24:MI'), ' ') as modi_fec
                , string_agg(distinct h.usuario, ' ') as modi_usu
                FROM relvis r
                JOIN periodos p ON r.periodo = p.periodo
                JOIN relvis r_1 ON r_1.periodo = p.periodoanterior and r_1.informante = r.informante and 
                                   r_1.formulario = r.formulario and r.visita = r_1.visita
                JOIN formularios f on r.formulario = f.formulario
                LEFT JOIN (SELECT * FROM his.his_campos_cvp 
                           WHERE esquema= 'cvp' and tabla='relvis' and (campo = 'panel' or campo = 'tarea') and operacion = 'U') h
                           ON concated_pk like r.periodo||'|'||r.informante||'%' AND 
                              ((r_1.panel = old_number AND r.panel = new_number) OR  
                               (r_1.tarea = old_number AND r.tarea = new_number))                      
              WHERE r.panel IS DISTINCT FROM r_1.panel or r.tarea IS DISTINCT FROM r_1.tarea
              GROUP BY r.periodo, r.informante, r_1.panel, r_1.tarea, r.panel, r.tarea)`
            },
    },context);
}