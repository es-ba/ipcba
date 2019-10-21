"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'informantesformulario',
        dbOrigin:'view',
        fields:[
            {name:'periodo'         , typeName:'text'   },
            {name:'formulario'      , typeName:'integer'},
            {name:'nombreformulario', typeName:'text'   },
            {name:'cantactivos'     , typeName:'integer'},
            {name:'cantaltas'       , typeName:'integer'},
            {name:'cantbajas'       , typeName:'integer'},
        ],                                             
        primaryKey:['periodo','formulario'],
    },context);
}

