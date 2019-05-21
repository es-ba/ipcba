"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'control_ingresados_calculo',
        editable:false,
        dbOrigin:'view',
        fields:[
        {name:'periodo'                      ,typeName:'text'     },
        {name:'producto'                     ,typeName:'text'     },
        {name:'nombreproducto'               ,typeName:'text'     },
        {name:'informante'                   ,typeName:'integer'  },
        {name:'nombreinformante'             ,typeName:'text'     },
        {name:'observacion'                  ,typeName:'integer'  },
        {name:'tipoinformante'               ,typeName:'text'     },
        {name:'divisionesdelproducto'        ,typeName:'text'     },
        {name:'fechamodificacioninformante'  ,typeName:'timestamp'},
        ],
        primaryKey:['periodo','producto','informante','observacion'],
    });
}