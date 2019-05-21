"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'app_calculo_grupos',
        tableName:'calculo_grupos',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'periodo'          , typeName:'text'    , nullable:false},
            {name:'agrupacion'       , typeName:'text'    , nullable:false},
            {name:'grupo'            , typeName:'text'    , nullable:false},
            {name:'indiceredondeado' , typeName:'decimal' , nullable:false},
        ],
        primaryKey:['periodo','agrupacion','grupo'],
        foreignKeys:[
            {references:'app_grupos', fields:[
                {source:'agrupacion'    , target:'agrupacion'},
                {source:'grupo'         , target:'grupo'     },
            ]},
            {references:'app_periodos', fields:[
                {source:'periodo'       , target:'periodo'   },
            ]},
        ],
        /*        
        sql:{
            from:`(
                select agrupacion, nombreagrupacion
                  from precios_app.calculo_grupos
                  )`
        }*/
        
    }, context);
}