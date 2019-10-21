"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'bitacora',
        editable:puedeEditar,
        fields:[
            //{name:'cuando'      , typeName:'datetime'      },
            {name:'que'           , typeName:'text'   },
        ]
    });
}