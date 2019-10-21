"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'cal_mensajes',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                     , typeName:'text'    , nullable:false                },
            {name:'calculo'                     , typeName:'integer' , nullable:false                },
            {name:'corrida'                     , typeName:'timestamp', nullable:false, default: now()      },
            {name:'paso'                        , typeName:'text'    , nullable:false                },
            {name:'renglon'                     , typeName:'integer' , nullable:false                },
            {name:'tipo'                        , typeName:'text'    , nullable:false, default:'log' },
            {name:'mensaje'                     , typeName:'text'         },
            {name:'producto'                    , typeName:'text'         },
            {name:'division'                    , typeName:'text'         },
            {name:'informante'                  , typeName:'integer'      },
            {name:'observacion'                 , typeName:'integer'      },
            {name:'formulario'                  , typeName:'integer'      },
            {name:'grupo'                       , typeName:'text'         },
            {name:'agrupacion'                  , typeName:'text'         },
            {name:'fechahora'                 , typeName:'timestamp'  },
        ],
        primaryKey:['periodo','calculo','corrida', 'paso','renglon'],
        foreignKeys:[
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
        ]
    });
}