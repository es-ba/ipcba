"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'control_comentariosrelvis',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      ,typeName:'text'   }, 
            {name:'informante'                   ,typeName:'integer'},
            {name:'visita'                       ,typeName:'integer'},
            {name:'panel'                        ,typeName:'integer'},
            {name:'tarea'                        ,typeName:'integer'},
            {name:'encuestador'                  ,typeName:'text'   },
            {name:'nombreencuestador'            ,typeName:'text'   },
            {name:'recepcionista'                ,typeName:'text'   },
            {name:'nombrerecepcionista'          ,typeName:'text'   },
            {name:'rubro'                        ,typeName:'integer'},
            {name:'nombrerubro'                  ,typeName:'text'   },
            {name:'formulario'                   ,typeName:'integer'},
            {name:'nombreformulario'             ,typeName:'text'   },
            {name:'comentarios'                  ,typeName:'text'   },
        ],
        primaryKey:['periodo','informante','visita','formulario'],
    });
}