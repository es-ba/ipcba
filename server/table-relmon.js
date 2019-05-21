"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'relmon',
        //title:'Relmon',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                  , typeName:'text'    , nullable:false},
            {name:'moneda'                   , typeName:'text'    , nullable:false},
            {name:'valor_pesos'              , typeName:'decimal'      },
        ],
        primaryKey:['periodo','moneda'],
        foreignKeys:[
            {references:'monedas', fields:[
                {source:'moneda'         , target:'moneda'     },
            ]},
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
        ],
        sortColumns:[{column:'periodo', order:-1}]
    },context);
}