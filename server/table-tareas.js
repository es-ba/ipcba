"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'tareas',
        title:'Tareas',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'tarea'                  , typeName:'integer' , nullable:false, allow:{update:puedeEditar}},
            {name:'encuestador'            , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'activa'                 , typeName:'text', default:'S', defaultValue:'S', allow:{update:puedeEditar}},
            {name:'periodobaja'            , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'operativo'              , typeName:'text'                    , allow:{update:puedeEditar}},
            {name:'recepcionista'          , typeName:'text'                    , allow:{update:puedeEditar}},
        ],
        primaryKey:['tarea'],
        foreignKeys:[
            {references:'personal', fields:[
                {source:'encuestador'  , target:'persona'     },
            ]},
        ]
    },context);
}