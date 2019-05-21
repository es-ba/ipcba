"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'app_calculo_productos',
        tableName:'calculo_productos',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'periodo'        , typeName:'text'    , nullable:false},
            {name:'producto'       , typeName:'text'    , nullable:false},
            {name:'preciopromedio' , typeName:'decimal' , nullable:false},
        ],
        primaryKey:['periodo','producto'],
        foreignKeys:[
            {references:'app_productos', fields:[
                {source:'producto'     , target:'producto'},
            ]},
            {references:'app_periodos' , fields:[
                {source:'periodo'      , target:'periodo'   },
            ]},
        ],        
    }, context);
}