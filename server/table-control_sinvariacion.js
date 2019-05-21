"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'control_sinvariacion',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      ,typeName:'text'   },
            {name:'informante'                   ,typeName:'integer'},
            {name:'nombreinformante'             ,typeName:'text'   },
            {name:'tipoinformante'               ,typeName:'text'   },
            {name:'producto'                     ,typeName:'text'   },
            {name:'nombreproducto'               ,typeName:'text'   },
            {name:'visita'                       ,typeName:'integer'},
            {name:'observacion'                  ,typeName:'integer'},
            {name:'panel'                        ,typeName:'integer'},
            {name:'tarea'                        ,typeName:'integer'},
            {name:'recepcionista'                ,typeName:'text'   },
            {name:'precionormalizado'            ,typeName:'decimal'},
        ],
        primaryKey:['periodo','producto','informante','observacion','visita'],
    });
}