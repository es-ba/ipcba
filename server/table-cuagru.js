"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='analista';
    return context.be.tableDefAdapt({
        name:'cuagru',
        editable:puedeEditar,
        fields:[
            {name:'cuadro'                  , typeName:'text'    , nullable:false},
            {name:'agrupacion'              , typeName:'text'    , nullable:false},
            {name:'grupo'                   , typeName:'text'    , nullable:false},
            {name:'orden'                   , typeName:'integer'                  },
        ],
        primaryKey:['cuadro','agrupacion','grupo'],
        foreignKeys:[
            {references:'cuadros', fields:[
                {source:'cuadro'  , target:'cuadro'     },
            ]},
            {references:'grupos', fields:[
                {source:'agrupacion'   , target:'agrupacion'},
                {source:'grupo'        , target:'grupo'     },
            ]},            
        ]
    },context);
}