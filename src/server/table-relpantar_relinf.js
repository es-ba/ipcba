"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'relpantar_relinf',
        title:'tareas',
        dbOrigin:'view',
        allow:{
            insert:false,
            delete:false,
            update:false,
        },        
        fields:[
            {name:'periodo'               , typeName:'text'       },
            {name:'panel'                 , typeName:'integer'    },
            {name:'tarea'                 , typeName:'integer'    },
            {name:'encuestador'           , typeName:'text'       },
        ],
        primaryKey:['periodo','panel','tarea'],
        detailTables:[
            {table:'relinf_observaciones', abr:'INF', label:'informantes', fields:['periodo','panel','tarea']},
        ],
        foreignKeys:[
            {references:'personal', fields:[
                {source:'encuestador'  , target:'persona'},
            ]},
        ],
        sql:{
            from:`(select r.periodo, r.panel, p.tarea, t.encuestador from 
                     relpan r left join pantar p on r.panel = p.panel
                     left join tareas t on p.tarea = t.tarea
                     where t.activa = 'S'
                )`
        }       
        
    },context);
}