"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'informantesrazon',
        dbOrigin:'view',
        fields:[
            {name:'periodo'        , typeName:'text'   },
            {name:'razon'          , typeName:'text'   },
            {name:'nombrerazon'    , typeName:'text'   },
            {name:'cantformularios', typeName:'integer'},
            {name:'cantinformantes', typeName:'integer'},
        ],                                             
        primaryKey:['periodo','razon'],
    },context);
}

