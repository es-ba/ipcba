"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'|| context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'relmon',
        //title:'Relmon',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },	
        fields:[
            {name:'periodo'                  , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'moneda'                   , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'valor_pesos'              , typeName:'decimal' , allow:{update:puedeEditar}},
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