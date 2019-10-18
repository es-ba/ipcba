"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'gru_grupos',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'agrupacion'                   ,typeName:'text'   },
            {name:'grupo_padre'                  ,typeName:'text'   },
            {name:'grupo'                        ,typeName:'text'   },
            {name:'esproducto'                   ,typeName:'text'   },
        ],
        filterColumns:[
            {column:'agrupacion', operator:'=', value:'Z'}
        ],                
        primaryKey:['agrupacion','grupo_padre','grupo'],
        sql:{
            isTable: false,
        },
    });
}
