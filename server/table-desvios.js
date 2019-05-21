"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'desvios',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'               ,typeName:'text'   }, 
            {name:'producto'              ,typeName:'text'   },
            {name:'nombreproducto'        ,typeName:'text'   },
            {name:'desvio'                ,typeName:'decimal'},
        ],
        primaryKey:['periodo','producto'],
    });
}