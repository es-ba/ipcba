"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'hdrexportarefectivossinprecio',
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      , typeName:'text'      }, 
            {name:'panel'                        , typeName:'integer'   },
            {name:'tarea'                        , typeName:'integer'   },
            {name:'fechasalida'                  , typeName:'date', title:'salida'},
            {name:'informante'                   , typeName:'integer', title:'inf'},
            {name:'encuestador'                  , typeName:'text', title:'enc'},
            {name:'nombreencuestador'            , typeName:'text'      },
            {name:'recepcionista'                , typeName:'text', title:'rec'},
            {name:'nombrerecepcionista'          , typeName:'text'      },
            {name:'razon'                        , typeName:'integer'   },
            {name:'visita'                       , typeName:'integer', title:'vis'},
            {name:'nombreinformante'             , typeName:'text'      },
            {name:'direccion'                    , typeName:'text'      },
            {name:'formulario'                   , typeName:'integer', title:'for'},
            {name:'nombreformulario'             , typeName:'text'      },
            {name:'contacto'                     , typeName:'text'      },
            {name:'conjuntomuestral'             , typeName:'integer'   },
            {name:'ordenhdr'                     , typeName:'integer'   },
            {name:'distrito'                     , typeName:'integer'   },
            {name:'fraccion'                     , typeName:'integer'   },
            {name:'rubro'                        , typeName:'integer'   },
            {name:'nombrerubro'                  , typeName:'text'      },
            {name:'maxperiodoinformado'          , typeName:'text'      },
            {name:'tipoprecios'                  , typeName:'text'      },
        ],
        primaryKey:['periodo','informante','visita','formulario'],
        sql:{
            isTable: false,
        },
    },context);
}