"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calgru',
        editable:puedeEditar,
        fields:[
            {name:'periodo'              , typeName:'text'    , nullable:false},
            {name:'calculo'              , typeName:'integer' , nullable:false},
            {name:'agrupacion'           , typeName:'text'    , nullable:false},
            {name:'grupo'                , typeName:'text'    , nullable:false},
            {name:'variacion'            , typeName:'decimal'                  },
            {name:'impgru'               , typeName:'text'                    },
            {name:'valorprel'            , typeName:'decimal'                  },
            {name:'valorgru'             , typeName:'decimal'                  },
            {name:'grupopadre'           , typeName:'text'                    },
            {name:'nivel'                , typeName:'integer'                 },
            {name:'esproducto'           , typeName:'text'                    },
            {name:'ponderador'           , typeName:'decimal'                  },
            {name:'indice'               , typeName:'decimal'                  },
            {name:'indiceprel'           , typeName:'decimal'                  },
            {name:'incidencia'           , typeName:'decimal'                  },
            {name:'indiceredondeado'     , typeName:'decimal'                  },
            {name:'incidenciaredondeada' , typeName:'decimal'                  },
            {name:'ponderadorimplicito'  , typeName:'decimal'                  },            
            
        ],
        primaryKey:['periodo','calculo','agrupacion','grupo'],
        foreignKeys:[
            //{references:'calculos_def', fields:[
            //    {source:'calculo'  , target:'calculo'     },
            //]},
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
            {references:'calculos', fields:[
                {source:'periodo'  , target:'periodo'     },
                {source:'calculo'  , target:'calculo'     },
            ]},            
        ]
    },context);
}