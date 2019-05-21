"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'transf_info',
        title:'Transf_info',
        editable:puedeEditar,
        fields:[
            {name:'operativo'              , typeName:'text'    , nullable:false},
            {name:'agrupacion'             , typeName:'text'    , nullable:false},
            {name:'grupo'                  , typeName:'text'    , nullable:false},
        ],
        primaryKey:['operativo','agrupacion','grupo'],
        foreignKeys:[
            {references:'grupos', fields:[
                {source:'agrupacion'  , target:'agrupacion'     },
                {source:'grupo'       , target:'grupo'          },
            ]},
        ]
    });
}