"use strict";

module.exports = function(context){
    //var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'control_rangos',
        editable:false,
        dbOrigin:'view',
        fields:[
            {name:'periodo'                      , typeName:'text'   },
            {name:'producto'                     , typeName:'text'   },
            {name:'nombreproducto'               , typeName:'text'   },
            {name:'informante'                   , typeName:'integer', title:'inf'},
            {name:'tipoinformante'               , typeName:'text', title:'TI'},
            {name:'observacion'                  , typeName:'integer', title:'obs' },
            {name:'visita'                       , typeName:'integer', title:'vis' },
            {name:'panel'                        , typeName:'integer'},
            {name:'tarea'                        , typeName:'integer'},
            {name:'encuestador'                  , typeName:'text', title:'enc'},
            {name:'formulario'                   , typeName:'integer', title:'for'},
            {name:'precionormalizado'            , typeName:'decimal'},
            {name:'tipoprecio'                   , typeName:'text', title:'TP'},
            {name:'cambio'                       , typeName:'text'   },
            {name:'repregunta'                   , typeName:'text'   },
            {name:'impobs'                       , typeName:'text'   },
            {name:'precioant'                    , typeName:'decimal'},
            {name:'tipoprecioant'                , typeName:'text', title:'TPa'},
            {name:'antiguedadsinprecioant'       , typeName:'integer', title:'Aspa'},
            {name:'variac'                       , typeName:'decimal'},
            {name:'comentariosrelpre'            , typeName:'text'   },
            {name:'observaciones'                , typeName:'text'   },
            {name:'promvar'                      , typeName:'decimal'},
            {name:'desvvar'                      , typeName:'decimal'},
            {name:'promrotativo'                 , typeName:'decimal'},
            {name:'desvprot'                     , typeName:'decimal'},
            {name:'razon_impobs_ant'             , typeName:'text'   },            
        ],
        primaryKey:['periodo','producto','observacion','informante','visita'],
    },context);
}