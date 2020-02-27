"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'informantesaltasbajas',
        dbOrigin:'view',
        //editable:false,
        fields:[
            {name:'periodoanterior'              , typeName:'text'   },
            {name:'informante'                   , typeName:'integer'},
            {name:'visita'                       , typeName:'integer'},
            {name:'rubro'                        , typeName:'integer'},
            {name:'nombrerubro'                  , typeName:'text'   },
            {name:'formulario'                   , typeName:'integer'},
            {name:'nombreformulario'             , typeName:'text'   },
            {name:'panelanterior'                , typeName:'integer'},
            {name:'tareaanterior'                , typeName:'integer'},
            {name:'razonanterior'                , typeName:'integer'},
            {name:'nombrerazonanterior'          , typeName:'text'   },
            {name:'periodo'                      , typeName:'text'   },
            {name:'panel'                        , typeName:'integer'},
            {name:'tarea'                        , typeName:'integer'},
            {name:'razon'                        , typeName:'integer'},
            {name:'nombrerazon'                  , typeName:'text'   },
            {name:'tipo'                         , typeName:'text'   },
            {name:'distrito'                     , typeName:'integer'},
            {name:'fraccion_ant'                 , typeName:'integer'},
            {name:'cantformactivos'              , typeName:'integer'},
        ],
        primaryKey:['periodo','informante','visita','formulario'],
        sql:{
            isTable: false,
        },
    },context);
}

