"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'control_productos_para_cierre',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'              , typeName:'text'   },
            {name:'calculo'              , typeName:'integer'},
            {name:'producto'             , typeName:'text'   },
            {name:'nombreproducto'       , typeName:'text'   },
            {name:'variacion'            , typeName:'decimal' },
            {name:'incidencia'           , typeName:'decimal' },
            {name:'cantincluidos'        , typeName:'integer'},
            {name:'cantrealesincluidos'  , typeName:'integer'},
            {name:'cantimputados'        , typeName:'integer'},
            {name:'s_variacion'           , typeName:'decimal' },
            {name:'s_cantincluidos'       , typeName:'integer'},
            {name:'s_cantrealesincluidos' , typeName:'integer'},
            {name:'s_cantimputados'       , typeName:'integer'},
            {name:'t_variacion'           , typeName:'decimal' },
            {name:'t_cantincluidos'       , typeName:'integer'},
            {name:'t_cantrealesincluidos' , typeName:'integer'},
            {name:'t_cantimputados'       , typeName:'integer'},
        ],
        primaryKey:['periodo','calculo','producto'],
    },context);
}