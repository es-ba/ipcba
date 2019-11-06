"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'blapre',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                     , typeName:'text'    , nullable:false},
            {name:'producto'                    , typeName:'text'    , nullable:false},
            {name:'observacion'                 , typeName:'integer' , nullable:false},
            {name:'informante'                  , typeName:'integer' , nullable:false},
            {name:'formulario'                  , typeName:'integer' , nullable:false},
            {name:'precio'                      , typeName:'decimal'  , exact:true, decimals: true},
            {name:'tipoprecio'                  , typeName:'text'      },
            {name:'visita'                      , typeName:'integer' , nullable:false , default:1},
            {name:'comentariosrelpre'           , typeName:'text'      },
            {name:'cambio'                      , typeName:'text'      },
            {name:'precionormalizado'           , typeName:'decimal'  , exact:true, decimals: true},
            {name:'especificacion'              , typeName:'integer' , nullable:false},
            {name:'ultima_visita'               , typeName:'boolean'   },
        ],
        primaryKey:['periodo','producto','observacion','informante', 'visita'],
        foreignKeys:[
            {references:'informantes', fields:[
                {source:'informante'         , target:'informante'     },
            ]},
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'}
            ], onUpdate: 'cascade'},
            {references:'relvis', fields:[
                {source:'periodo'         , target:'periodo'     },
                {source:'informante'      , target:'informante'  },
                {source:'visita'          , target:'visita'      },
                {source:'formulario'      , target:'formulario'  },
            ]},
            {references:'tipopre', fields:[
                {source:'tipoprecio'         , target:'tipoprecio'     },
            ]},
        ],
        constraints:[
            {constraintType:'unique', fields:['periodo', 'producto', 'observacion', 'informante', 'ultima_visita']}
        ]
    }, context);
}