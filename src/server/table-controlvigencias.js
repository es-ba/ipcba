"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'controlvigencias',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      ,typeName:'text'   },  
            {name:'informante'                   ,typeName:'integer', title:'inf'},
            {name:'producto'                     ,typeName:'text'   },
            {name:'nombreproducto'               ,typeName:'text'   },
            {name:'observacion'                  ,typeName:'integer', title:'obs'},
            {name:'valor'                        ,typeName:'text'   },
            {name:'ultimodiadelmes'              ,typeName:'integer'},
            {name:'cantdias'                     ,typeName:'integer'},
            {name:'visitas'                      ,typeName:'integer'},
            {name:'vigencias'                    ,typeName:'integer'},
            {name:'comentarios'                  ,typeName:'text'   },
            {name:'tipoprecio'                   ,typeName:'text'   },
        ],
        primaryKey:['periodo','informante','producto','observacion'],
        sql:{
            isTable: false,
        },
    });
}