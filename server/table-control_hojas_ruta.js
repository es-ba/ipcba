"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'control_hojas_ruta',
        dbOrigin:'view',
        //editable:false,
        fields:[
            {name:'periodo'                      , typeName:'text'      },
            {name:'panel'                        , typeName:'integer'   },
            {name:'tarea'                        , typeName:'integer'   },
            {name:'visita'                       , typeName:'integer'   },
            {name:'fechasalida'                  , typeName:'date'      },
            {name:'informante'                   , typeName:'integer'   },
            {name:'nombreinformante'             , typeName:'text'      },
            {name:'encuestador'                  , typeName:'text'      },
            {name:'nombreencuestador'            , typeName:'text'      },
            {name:'recepcionista'                , typeName:'text'      },
            {name:'nombrerecepcionista'          , typeName:'text'      },
            {name:'ingresador'                   , typeName:'text'      },
            {name:'nombreingresador'             , typeName:'text'      },
            {name:'formulario'                   , typeName:'integer'   },
            {name:'nombreformulario'             , typeName:'text'      },
            {name:'operativo'                    , typeName:'text'      },
            {name:'razon'                        , typeName:'integer'   },
            {name:'razonanterior'                , typeName:'integer'   },
            {name:'direccion'                    , typeName:'text'      },
            {name:'conjuntomuestral'             , typeName:'integer'   },
            {name:'ordenhdr'                     , typeName:'integer'   },
        ],
        primaryKey:['periodo','informante','visita','formulario'],
    },context);
}

