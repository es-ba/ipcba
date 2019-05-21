"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'bienvenida',
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
        /*
        sql:{
            where:"codigo = 'nivel_usuario'" //+context.be.db.quoteText(context.user.usuario)
        }
        */        
    });
}