"use strict";
var bestGlobals = require('best-globals');

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calgru_vw',
        editable:puedeEditar,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                           , typeName:'text'   }, 
            {name:'calculo'                           , typeName:'integer'},
            {name:'agrupacion'                        , typeName:'text'   },
            {name:'grupo'                             , typeName:'text'   , sortMethod: 'codigo_ipc'},
            {name:'nombre'                            , typeName:'text'   },
            {name:'variacion'                         , typeName:'decimal'},
            {name:'impgru'                            , typeName:'text'   },
            {name:'grupopadre'                        , typeName:'text'   },
            {name:'nivel'                             , typeName:'integer'},
            {name:'esproducto'                        , typeName:'text'   },
            {name:'ponderador'                        , typeName:'decimal'},
            {name:'indice'                            , typeName:'decimal'},
            {name:'indiceprel'                        , typeName:'decimal'},
            {name:'incidencia'                        , typeName:'decimal'},
            {name:'indiceredondeado'                  , typeName:'decimal'},
            {name:'incidenciaredondeada'              , typeName:'decimal'},
            {name:'incidenciainteranual'              , typeName:'decimal'},
            {name:'incidenciainteranualredondeada'    , typeName:'decimal'},
            {name:'incidenciaacumuladaanual'          , typeName:'decimal'},
            {name:'incidenciaacumuladaanualredondeada', typeName:'decimal'},
            {name:'variacioninteranual'               , typeName:'decimal'},
            {name:'variacioninteranualredondeada'     , typeName:'decimal'},
            {name:'variaciontrimestral'               , typeName:'decimal'},
            {name:'variacionacumuladaanual'           , typeName:'decimal'},
            {name:'variacionacumuladaanualredondeada' , typeName:'decimal'},
            {name:'ponderadorimplicito'               , typeName:'decimal'},
            {name:'ordenpor'                          , typeName:'text'   , sortMethod: 'charbychar'},
            {name:'publicado'                         , typeName:'boolean'},
            {name:'responsable'                       , typeName:'text'   },
        ],
        filterColumns:[
            {column:'periodo', operator:'>=', value:context.be.internalData.filterUltimoPeriodo},
            {column:'calculo', operator:'=' , value:context.be.internalData.filterUltimoCalculo},
            {column:'agrupacion', operator:'=' , value:context.be.internalData.filterAgrupacion},
        ],
        sortColumns:[{column:'ordenpor'}],        
        primaryKey:['periodo','calculo','agrupacion','grupo'],
        sql:{
            isTable: false,
        },
    },context);
}