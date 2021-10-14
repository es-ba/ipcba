"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calbase_obs',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },        
        fields:[
            {name:'calculo'                      , typeName:'integer' , nullable:false},
            {name:'producto'                     , typeName:'text'    , nullable:false},
            {name:'informante'                   , typeName:'integer' , nullable:false},
            {name:'observacion'                  , typeName:'integer' , nullable:false},
            {name:'periodo_aparicion'            , typeName:'text'                    },
            {name:'incluido'                     , typeName:'boolean'                 },
            {name:'periodo_anterior_baja'        , typeName:'text'                    },
        ],
        primaryKey:['calculo','producto','informante','observacion'],
        filterColumns:[
            {column:'calculo', operator:'!=', value:0},
        ],                
        foreignKeys:[
            {references:'calculos_def', fields:[
                {source:'calculo'  , target:'calculo'           },
            ]},
            {references:'informantes', fields:[
                {source:'informante'  , target:'informante'     },
            ]},
            {references:'periodos', fields:[
                {source:'periodo_aparicion'  , target:'periodo' },
            ]},
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'  },
            ]},
        ],
    },context);
}