"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'hdrexportar',
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      , typeName: 'text'   },
            {name:'panel'                        , typeName: 'integer'},
            {name:'tarea'                        , typeName: 'integer'},
            {name:'fechasalida'                  , typeName: 'date'   },
            {name:'informante'                   , typeName: 'integer'},
            {name:'ti'                           , typeName: 'text'   },
            {name:'encuestador'                  , typeName: 'text'   },
            {name:'nombreencuestador'            , typeName: 'text'   },
            {name:'recepcionista'                , typeName: 'text'   },
            {name:'nombrerecepcionista'          , typeName: 'text'   },
            {name:'ingresador'                   , typeName: 'text'   },
            {name:'nombreingresador'             , typeName: 'text'   },
            {name:'razon'                        , typeName: 'text'   },
            {name:'visita'                       , typeName: 'integer'},
            {name:'nombreinformante'             , typeName: 'text'   },
            {name:'direccion'                    , typeName: 'text'   },
            {name:'formularios'                  , typeName: 'text'   },
            {name:'contacto'                     , typeName: 'text'   },
            {name:'conjuntomuestral'             , typeName: 'integer'},
            {name:'ordenhdr'                     , typeName: 'integer'},
            {name:'distrito'                     , typeName: 'integer'},
            {name:'fraccion_ant'                 , typeName: 'integer'},
            {name:'rubro'                        , typeName: 'integer'},
            {name:'nombrerubro'                  , typeName: 'text'   },
            {name:'maxperiodoinformado'          , typeName: 'text'   },
            {name:'minperiodoinformado'          , typeName: 'text'   },
        ],
        primaryKey:['periodo','informante','visita','formularios'],
        sql:{
            isTable: false,
        },
    },context);
}

