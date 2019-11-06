"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'modulos',
        editable:puedeEditar,
        fields:[
            {name:'formulario'                , typeName:'text'    , nullable:false},
            {name:'nombre'                    , typeName:'text'    , isName:true   },
            {name:'zona'                      , typeName:'text'      },
            {name:'tipo'                      , typeName:'integer'   },
        ],
        primaryKey:['formulario','zona','nombre'],
    });
}