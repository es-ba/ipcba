"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'freccambio_resto',
        dbOrigin:'view',
        fields:[
            {name:'periodonombre'                , typeName: 'text'   },
            {name:'periodo'                      , typeName: 'text'   },
            {name:'grupo'                        , typeName: 'text'   },
            {name:'nombregrupo'                  , typeName: 'text'   },
            {name:'estado'                       , typeName: 'text'   },
            {name:'promgeoobs'                   , typeName: 'decimal'},
            {name:'promgeoobsant'                , typeName: 'decimal'},
            {name:'variacion'                    , typeName: 'decimal'},
            {name:'cantobsporestado'             , typeName: 'integer'},
            {name:'cantobsporgrupo'              , typeName: 'integer'},
            {name:'porcobs'                      , typeName: 'decimal'},
        ],
        primaryKey:['periodo','grupo','estado'],
        sortColumns:[{column:'periodo', order:-1}, {column:'grupo'}, {column:'estado'}],
        filterColumns:[
            {column:'periodo', operator:'>=', value:context.be.internalData.filterUltimoPeriodo.replace(/\d\d\d\d/,function(annio){ return annio-1;})},
        ],            
    },context);
}
