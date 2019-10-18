"use strict";

module.exports = function(context){
    return context.be.tableDefAdapt({
        name:'control_grupos_para_cierre',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                       ,typeName:'text'   },
            {name:'calculo'                       ,typeName:'integer'},
            {name:'agrupacion'                    ,typeName:'text'   },
            {name:'grupo'                         ,typeName:'text'   },
            {name:'nombre'                        ,typeName:'text'   },
            {name:'nivel'                         ,typeName:'integer'},
            {name:'variacion'                     ,typeName:'decimal'},
            {name:'incidencia'                    ,typeName:'decimal'},
            {name:'variacioninteranualredondeada' ,typeName:'decimal'},
            {name:'incidenciainteranual'          ,typeName:'decimal'},
            {name:'ponderador'                    ,typeName:'decimal'},
            {name:'ordenpor'                      ,typeName:'text'   },
            {name:'cantincluidos'                 ,typeName:'integer'},
            {name:'cantrealesincluidos'           ,typeName:'integer'},
            {name:'cantimputados'                 ,typeName:'integer'},
        ],
        primaryKey:['periodo','calculo','agrupacion','grupo'],
        sql:{
            isTable: false,
        },
    },context);
}