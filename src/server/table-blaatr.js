"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'blaatr',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                     , typeName:'text'    , nullable:false},
            {name:'producto'                    , typeName:'text'    , nullable:false},
            {name:'observacion'                 , typeName:'integer' , nullable:false},
            {name:'informante'                  , typeName:'integer' , nullable:false},
            {name:'atributo'                    , typeName:'integer' , nullable:false},
            {name:'valor'                       , typeName:'text'      },
            {name:'visita'                      , typeName:'integer' , nullable:false , default:1},
            {name:'validar_con_valvalatr'       , typeName:'boolean'   },
        ],
        primaryKey:['periodo','producto','observacion','informante', 'visita','atributo'],
        foreignKeys:[
            {references:'atributos', fields:[
                {source:'atributo'         , target:'atributo'     },
            ]},
            {references:'informantes', fields:[
                {source:'informante'         , target:'informante'     },
            ]},
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'     },
            ]},
            {references:'relpre', fields:[
                {source:'periodo'         , target:'periodo'     },
                {source:'producto'        , target:'producto'    },
                {source:'observacion'     , target:'observacion' },
                {source:'informante'      , target:'informante'  },
                {source:'visita'          , target:'visita'      },
            ]},
            {references:'valvalatr', fields:[
                {source:'periodo'                    , target:'periodo'     },
                {source:'producto'                   , target:'producto'    },
                {source:'valor'                      , target:'valor'       },
                {source:'validar_con_valvalatr'      , target:'validar'  },
            ]},
        ]
    });
}