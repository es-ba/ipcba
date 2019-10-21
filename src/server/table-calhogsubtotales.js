"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calhogsubtotales',
        editable:puedeEditar,
        fields:[
            {name:'periodo'              , typeName:'text'    , nullable:false},
            {name:'calculo'              , typeName:'integer' , nullable:false},
            {name:'hogar'                , typeName:'text'    , nullable:false},
            {name:'agrupacion'           , typeName:'text'    , nullable:false},
            {name:'grupo'                , typeName:'text'    , nullable:false},
            {name:'valorhogsub'          , typeName:'decimal'                  },
            
        ],
        primaryKey:['periodo','calculo','hogar','agrupacion','grupo'],
        foreignKeys:[
            {references:'hogares', fields:[
                {source:'hogar'  , target:'hogar'     },
            ]},
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
            {references:'calculos', fields:[
                {source:'periodo'  , target:'periodo'     },
                {source:'calculo'  , target:'calculo'     },
            ]},            
            {references:'grupos', fields:[
                {source:'agrupacion'  , target:'agrupacion'     },
                {source:'grupo'       , target:'grupo'          },
            ]},            
        ]
    },context);
}