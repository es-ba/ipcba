"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'informantesrubro',
        dbOrigin:'view',
        fields:[
            {name:'periodo'        , typeName:'text'   },
            {name:'rubro'          , typeName:'integer'},
            {name:'nombrerubro'    , typeName:'text'   },
            {name:'cantactivos'    , typeName:'integer'},
            {name:'cantaltas'      , typeName:'integer'},
            {name:'cantbajas'      , typeName:'integer'},
        ],                                             
        primaryKey:['periodo','rubro'],
    },context);
}

