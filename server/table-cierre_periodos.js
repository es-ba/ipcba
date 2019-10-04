"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador';
    return context.be.tableDefAdapt({
        name:'cierre_periodos',
        tableName: 'periodos',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                     , typeName:'text'    , nullable:false },
            {name:'ano'                         , typeName:'integer' , nullable:false },
            {name:'mes'                         , typeName:'integer' , nullable:false },
            {name:'visita'                      , typeName:'integer' , nullable:false },
            {name:'ingresando'                  , typeName:'text'                                          },
            {name:'fechageneracionperiodo'      , typeName:'timestamp'               , allow:{update:false}},
            {name:'cerraringresocampohastapanel', typeName:'integer' , nullable:false, allow:{update:false}},
        ],
        sortColumns:[{column:'periodo', order:-1}],
        primaryKey:['periodo'],
        sql:{
            from:`(
                select periodo, ano, mes, visita, ingresando, fechageneracionperiodo, cerraringresocampohastapanel
                   from periodos
                )`
        }
    },context);
}