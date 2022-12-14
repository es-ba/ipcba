"use strict";
var bestGlobals = require('best-globals');

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'control_ajustes',
        editable:false,
        dbOrigin:'view',
        fields:[{name:'periodo'            , typeName:'text'      },
                {name:'panel'              , typeName:'integer'   },
                {name:'tarea'              , typeName:'integer'   },
                {name:'informante'         , typeName:'integer'   },
                {name:'tipoinformante'     , typeName:'text'      },
                {name:'visita'             , typeName:'integer'   },
                {name:'formulario'         , typeName:'integer'   },
                {name:'grupo_padre_1'      , typeName:'text'      },
                {name:'nombregrupo_1'      , typeName:'text'      },
                {name:'grupo_padre_2'      , typeName:'text'      },
                {name:'nombregrupo_2'      , typeName:'text'      },
                {name:'grupo_padre_3'      , typeName:'text'      },
                {name:'nombregrupo_3'      , typeName:'text'      },
                {name:'producto'           , typeName:'text'      },
                //{name:'nombreproducto'     , typeName:'text'      },
                {name:'observacion'        , typeName:'integer'   },
                {name:'precionormalizado'  , typeName:'decimal'   },
                {name:'tipoprecio'         , typeName:'text'      },
                {name:'cambio'             , typeName:'text'      },
                {name:'variacion_1'        , typeName:'decimal'   },
                {name:'varia_1'            , typeName:'decimal'   },
                {name:'precionormalizado_1', typeName:'decimal'   },
                {name:'tipoprecio_1'       , typeName:'text'      },
                {name:'cambio_1'           , typeName:'text'      },
                {name:'variacion_2'        , typeName:'decimal'   },
                {name:'varia_2'            , typeName:'decimal'   },
                {name:'precionormalizado_2', typeName:'decimal'   },
                {name:'tipoprecio_2'       , typeName:'text'      },
                {name:'cambio_2'           , typeName:'text'      },
                {name:'varia_ambos'        , typeName:'text'      },
        ],
        primaryKey:['periodo','informante','visita','producto','observacion'],
        foreignKeys:[
            {references:'productos', fields:['producto']},
        ],
        sql:{
            isTable: false,
        },
    },context);
}