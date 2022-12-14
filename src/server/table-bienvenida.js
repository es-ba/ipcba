"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'bienvenida',
        policy:'web',
        dbOrigin:'view',
        editable:false,
        fields:[
            {name:'orden'              , typeName:'integer' },
            {name:'codigo'             , typeName:'text'    },
            {name:'dato'               , typeName:'text'    },
            {name:'explicacion'        , typeName:'text'    },
            {name:'nivel'              , typeName:'text'    },
        ],
        primaryKey:['orden'],
        sql:{
            isTable: false,
        },
    },context);
}