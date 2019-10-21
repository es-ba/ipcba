"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'reemplazosexportar',
        //editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      , typeName:'text'    },
            {name:'panel'                        , typeName:'integer' },
            {name:'tarea'                        , typeName:'integer' },
            {name:'fechasalida'                  , typeName:'date'    },
            {name:'conjuntomuestral'             , typeName:'integer' },
            {name:'encuestador'                  , typeName:'text'    },
            {name:'nombreencuestador'            , typeName:'text'    },
            {name:'visita'                       , typeName:'integer' },
            {name:'formularios'                  , typeName:'text'    },
            {name:'tipoinformante'               , typeName:'text'    },
            {name:'informante'                   , typeName:'integer' },
            {name:'nombreinformante'             , typeName:'text'    },
            {name:'direccion'                    , typeName:'text'    },
            {name:'ordenhdr'                     , typeName:'integer' },
            {name:'distrito'                     , typeName:'integer' },
            {name:'fraccion'                     , typeName:'integer' },
            {name:'rubro'                        , typeName:'integer' },
            {name:'nombrerubro'                  , typeName:'text'    },
        ],
        primaryKey:['periodo','informante','visita','formularios'],
    },context);
}