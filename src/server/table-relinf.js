"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='jefe_campo' || context.user.usu_rol ==='recepcionista' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relinf',
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                , typeName:'text'    , nullable:false, allow:{update:false}, inTable:true},
            {name:'informante'             , typeName:'integer' , nullable:false, allow:{update:false}, inTable:true},
            {name:'visita'                 , typeName:'integer'                 , allow:{update:false}, inTable:true},
            {name:'observaciones'          , typeName:'text'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'fechasalidadesde'       , typeName:'date'                    , allow:{update:puedeEditar}, inTable:true},
            {name:'fechasalidahasta'       , typeName:'date'                    , allow:{update:puedeEditar}, inTable:true},
        ],
        primaryKey:['periodo','informante','visita'],
        foreignKeys:[
            {references:'periodos'   , fields:['periodo']},
            {references:'informantes', fields:['informante']},
        ],
    },context);
}