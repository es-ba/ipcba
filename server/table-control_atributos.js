"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'control_atributos',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      , typeName:'text'    },
            {name:'producto'                     , typeName:'text'    },
            {name:'nombreproducto'               , typeName:'text'    },
            {name:'informante'                   , typeName:'integer', title:'inf'},
            {name:'observacion'                  , typeName:'integer', title:'obs'},
            {name:'visita'                       , typeName:'integer', title:'vis'},
            {name:'formulario'                   , typeName:'integer', title:'for'},
            {name:'panel'                        , typeName:'integer' },
            {name:'tarea'                        , typeName:'integer' },     
            {name:'encuestador'                  , typeName:'text', title:'enc'},     
            {name:'recepcionista'                , typeName:'text', title:'rec'},     
            {name:'fueraderango'                 , typeName:'text'    },     
        ],
        filterColumns:[
            {column:'periodo', operator:'>=', value:context.be.internalData.filterUltimoPeriodo}
        ],        
        primaryKey:['periodo','informante','visita','formulario','producto','observacion'],
        sql:{
            isTable: false,
        },
    },context);
}