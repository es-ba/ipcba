"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='jefe_recepcion' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relpantarinf',
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                  , typeName:'text'    , nullable:false, allow:{update:false}, inTable:true},
            {name:'informante'               , typeName:'integer' , nullable:false, allow:{update:false}, inTable:true},
            {name:'visita'                   , typeName:'integer'                 , allow:{update:false}, inTable:true},
            {name:'panel'                    , typeName:'integer'                 , allow:{update:false}, inTable:true},
            {name:'tarea'                    , typeName:'integer'                 , allow:{update:false}, inTable:true},
            {name:'observaciones'            , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'observaciones_campo'      , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'fechasalidadesde'         , typeName:'date'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'fechasalidahasta'         , typeName:'date'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'codobservaciones'         , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'recuperos'                , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'fecha_backup'             , typeName:'timestamp'               , allow:{update:false}},
            {name:'encuestador_backup'       , typeName:'text'                    , allow:{update:false}},
            {name:'backup'                   , typeName:'jsonb'                   , allow:{select:false}},
            {name:'token_relevamiento_backup', typeName:'text'                    , allow:{update:false}},
        ],
        primaryKey:['periodo','informante','visita','panel','tarea'],
        foreignKeys:[
            {references:'periodos'   , fields:['periodo']},
            {references:'informantes', fields:['informante']},
            {references:'personal', fields:[{source:'encuestador_backup', target:'persona'}]},
        ],
    },context);
}