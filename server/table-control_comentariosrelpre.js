"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'control_comentariosrelpre',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      ,typeName:'text'   }, 
            {name:'informante'                   ,typeName:'integer'},
            {name:'visita'                       ,typeName:'integer'},
            {name:'panel'                        ,typeName:'integer'},
            {name:'tarea'                        ,typeName:'integer'},
            {name:'recepcionista'                ,typeName:'text'   },
            {name:'nombrerecepcionista'          ,typeName:'text'   },
            {name:'producto'                     ,typeName:'text'   },
            {name:'nombreproducto'               ,typeName:'text'   },
            {name:'observacion'                  ,typeName:'integer'},
            {name:'tipoprecio'                   ,typeName:'text'   },
            {name:'comentariosrelpre'            ,typeName:'text'   },
        ],
        primaryKey:['periodo','informante','producto','visita','observacion'],
    });
}