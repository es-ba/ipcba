"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'foresp',
        dbOrigin:'view',
        fields:[
            {name:'formulario'         , typeName:'integer'    },
            {name:'producto'           , typeName:'text'       },
            {name:'especificacion'     , typeName:'integer'    },
            {name:'orden'              , typeName:'integer'    },
        ],
       primaryKey:['formulario','producto','especificacion'],        
    });
}