"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'app_grupos_producto',
        tableName:'grupos_producto',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'grupo'             , typeName:'text'    , nullable:false},
            {name:'nombregrupo'       , typeName:'text'    , nullable:false},
        ],
        primaryKey:['grupo'],
        detailTables:[
            {table:'app_productos', abr:'PRO', label:'productos', fields:['grupo']},
        ],        
    }, context);
}