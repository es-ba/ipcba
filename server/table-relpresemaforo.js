"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'relpresemaforo',
        title:'Relpresemaforo',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false},
            {name:'producto'                     , typeName:'text'    , nullable:false},
            {name:'observacion'                  , typeName:'integer' , nullable:false},
            {name:'informante'                   , typeName:'integer' , nullable:false},
            {name:'visita'                       , typeName:'integer' , nullable:false , default:1},
        ],
        primaryKey:['periodo','producto','observacion','informante','visita'],
        foreignKeys:[
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'     },
            ]},
            {references:'relpre', fields:[
                {source:'periodo'      , target:'periodo'       },
                {source:'producto'     , target:'producto'      },
                {source:'observacion'  , target:'observacion'   },
                {source:'informante'   , target:'informante'    },
                {source:'visita'       , target:'visita'        },
            ]},            
        ]
    });
}