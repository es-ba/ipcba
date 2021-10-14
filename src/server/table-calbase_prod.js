"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calbase_prod',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },        
        fields:[
            {name:'calculo'                      , typeName:'integer' , nullable:false},
            {name:'producto'                     , typeName:'text'    , nullable:false},
            {name:'mes_inicio'                   , typeName:'text'                    },
        ],
        primaryKey:['producto','calculo'],
        filterColumns:[
            {column:'calculo', operator:'!=', value:0},
        ],                
        foreignKeys:[
            {references:'calculos_def', fields:[
                {source:'calculo'  , target:'calculo'     },
            ]},
            {references:'periodos', fields:[
                {source:'mes_inicio'         , target:'periodo'    },
            ]},
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'     },
            ]},
        ]
    },context);
}