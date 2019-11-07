"use strict";

module.exports = function(context){
    var puedeEditar = context.user.rol ==='admin';
    return context.be.tableDefAdapt({
        name:'hojaderutasupervisor',
        dbOrigin:'view',
        editable:false,
        fields:[
            {name:'supervisor'       , typeName:'text'    },
            {name:'nombresupervisor' , typeName:'text'    },
            {name:'periodo'          , typeName:'text'    },
            {name:'panel'            , typeName:'integer' },
            {name:'tarea'            , typeName:'integer' },
            {name:'fechasalida'      , typeName:'date'    },
            {name:'informante'       , typeName:'integer' },
            {name:'encuestador'      , typeName:'text'    },
            {name:'nombreencuestador', typeName:'text'    },
            {name:'razon'            , typeName:'text'    },
            {name:'visita'           , typeName:'integer' },
            {name:'nombreinformante' , typeName:'text'    },
            {name:'direccion'        , typeName:'text'    },
            {name:'formularios'      , typeName:'text'    },
            {name:'espacio'          , typeName:'text'    },
            {name:'contacto'         , typeName:'text'    },
            {name:'conjuntomuestral' , typeName:'integer' },
            {name:'ordenhdr'         , typeName:'integer' },
        ],
        primaryKey:['periodo','informante','visita','formularios'],
        sortColumns:[{column:'supervisor'}, {column:'periodo'}, {column:'panel'}, {column:'tarea'}, {column:'direccion'}, {column:'visita'}],
        sql:{
            isTable: false,
        },
    });
}