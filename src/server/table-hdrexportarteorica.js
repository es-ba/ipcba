"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'hdrexportarteorica',
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      , typeName:'text'    },
            {name:'panel'                        , typeName:'integer' },
            {name:'tarea'                        , typeName:'integer' },
            {name:'informante'                   , typeName:'integer' },
            {name:'ti'                           , typeName:'text'    },
            {name:'encuestador'                  , typeName:'text'    },
            {name:'encuestadores'                , typeName:'text'    },
            {name:'recepcionistas'               , typeName:'text'    },
            {name:'ingresadores'                 , typeName:'text'    },
            {name:'razon'                        , typeName:'text'    },
            {name:'visita'                       , typeName:'integer' },
            {name:'nombreinformante'             , typeName:'text'    },
            {name:'direccion'                    , typeName:'text'    },
            {name:'formularios'                  , typeName:'text'    },
            {name:'contacto'                     , typeName:'text'    },
            {name:'telcontacto'                  , typeName:'text'    },
            {name:'web'                          , typeName:'text'    },
            {name:'email'                        , typeName:'text'    },
            {name:'distrito'                     , typeName:'integer' },
            {name:'fraccion_ant'                 , typeName:'integer' },
            {name:'comuna'                       , typeName:'integer' },
            {name:'fraccion'                     , typeName:'integer' },
            {name:'radio'                        , typeName:'integer' },
            {name:'manzana'                      , typeName:'integer' },
            {name:'depto'                        , typeName:'integer' },
            {name:'barrio'                       , typeName:'integer' },
            {name:'rubro'                        , typeName:'integer' },
            {name:'nombrerubro'                  , typeName:'text'    },
            {name:'maxperiodoinformado'          , typeName:'text'    },
            {name:'minperiodoinformado'          , typeName:'text'    },
            {name:'panelreferencia'              , typeName:'text'    },
            {name:'tareareferencia'              , typeName:'text'    },
            {name:'periodoalta'                  , typeName: 'text'   },
            {name:'modalidad'                    , typeName: 'text'   },            
            {name:'otropaneltarea'               , typeName: 'text'   },            
            {name:'cadena'                       , typeName: 'text'   },            
        ],
        primaryKey:['periodo','informante','visita','formularios'],
        sql:{
            isTable: false,
        },
    },context);
}