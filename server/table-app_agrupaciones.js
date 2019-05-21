"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'app_agrupaciones',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'agrupacion'             , typeName:'text'    , nullable:false},
            {name:'nombreagrupacion'       , typeName:'text'    , nullable:false},
        ],
        primaryKey:['agrupacion'],
        detailTables:[
            {table:'app_grupos', abr:'GRU', label:'grupos', fields:['agrupacion']},
        ],        
        sql:{
            from:`(
                select agrupacion, nombreagrupacion
                  from precios_app.agrupaciones
                  )`
        }
        
    }, context);
}