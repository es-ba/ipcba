"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calobs',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false},
            {name:'calculo'                      , typeName:'integer' , nullable:false},
            {name:'producto'                     , typeName:'text'    , nullable:false},
            {name:'informante'                   , typeName:'integer' , nullable:false},
            {name:'observacion'                  , typeName:'integer' , nullable:false},
            {name:'division'                     , typeName:'text'                    },
            {name:'promobs'                      , typeName:'decimal'                  },
            {name:'impobs'                       , typeName:'text'                    },
            {name:'antiguedadconprecio'          , typeName:'integer'                 },
            {name:'antiguedadsinprecio'          , typeName:'integer'                 },
            {name:'antiguedadexcluido'           , typeName:'integer'                 },
            {name:'antiguedadincluido'           , typeName:'integer'                 },
            {name:'sindatosestacional'           , typeName:'integer'                 },
            {name:'muestra'                      , typeName:'integer'                 },
            
        ],
        primaryKey:['periodo','calculo','producto','informante','observacion'],
        foreignKeys:[
            {references:'calculos_def', fields:[
                {source:'calculo'  , target:'calculo'     },
            ]},
            {references:'informantes', fields:[
                {source:'informante'  , target:'informante'     },
            ]},
            {references:'muestras', fields:[
                {source:'muestra'  , target:'muestra'     },
            ]},
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'     },
            ], onUpdate:'cascade'},
            {references:'calculos', fields:[
                {source:'periodo'  , target:'periodo'     },
                {source:'calculo'  , target:'calculo'     },
            ]},            
        ]
    },context);
}