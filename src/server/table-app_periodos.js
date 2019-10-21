"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'app_periodos',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'periodo'     , typeName:'text'       , nullable:false},
            {name:'annio'       , typeName:'integer'    , nullable:false},
            {name:'mes'         , typeName:'integer'    , nullable:false},
        ],
        primaryKey:['periodo'],
        detailTables:[
            {table:'app_calculo_grupos', abr:'CG', label:'calculo_grupos', fields:['periodo']},
            {table:'app_calculo_productos', abr:'CP', label:'calculo_productos', fields:['periodo']},
        ],                
        sql:{
            from:`(
                select periodo, annio, mes
                  from precios_app.periodos
                  )`
        }
        
    }, context);
}