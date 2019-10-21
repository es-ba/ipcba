"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'caldiv',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false},
            {name:'calculo'                      , typeName:'integer' , nullable:false},
            {name:'producto'                     , typeName:'text'    , nullable:false},
            {name:'division'                     , typeName:'text'    , nullable:false},
            {name:'prompriimpact'                , typeName:'decimal'                 },
            {name:'prompriimpant'                , typeName:'decimal'                 },
            {name:'cantpriimp'                   , typeName:'integer'                 },
            {name:'promprel'                     , typeName:'decimal'                 },
            {name:'promdiv'                      , typeName:'decimal'                 },
            {name:'impdiv'                       , typeName:'text'                    },
            {name:'cantincluidos'                , typeName:'integer'                 },
            {name:'cantrealesincluidos'          , typeName:'integer'                 },
            {name:'cantrealesexcluidos'          , typeName:'integer'                 },
            {name:'promvar'                      , typeName:'decimal'                 },
            {name:'cantaltas'                    , typeName:'integer'                 },
            {name:'promaltas'                    , typeName:'decimal'                 },
            {name:'cantbajas'                    , typeName:'integer'                 },
            {name:'prombajas'                    , typeName:'decimal'                 },
            {name:'cantimputados'                , typeName:'integer'                 },
            {name:'ponderadordiv'                , typeName:'decimal'                 },
            {name:'umbralpriimp'                 , typeName:'integer'                 },
            {name:'umbraldescarte'               , typeName:'integer'                 },
            {name:'umbralbajaauto'               , typeName:'integer'                 },
            {name:'cantidadconprecio'            , typeName:'integer'                 },
            {name:'profundidad'                  , typeName:'integer'                 },
            {name:'divisionpadre'                , typeName:'text'                    },
            {name:'tipo_promedio'                , typeName:'text'                    },
            {name:'raiz'                         , typeName:'boolean'                 },
            {name:'cantexcluidos'                , typeName:'integer'                 },
            {name:'promexcluidos'                , typeName:'decimal'                 },
            {name:'promimputados'                , typeName:'decimal'                 },
            {name:'promrealesincluidos'          , typeName:'decimal'                 },
            {name:'promrealesexcluidos'          , typeName:'decimal'                 },
            {name:'promedioredondeado'           , typeName:'decimal'                 },
            {name:'cantrealesdescartados'        , typeName:'integer'                 },
            {name:'cantpreciostotales'           , typeName:'integer'                 },
            {name:'cantpreciosingresados'        , typeName:'integer'                 },
            {name:'cantconprecioparacalestac'    , typeName:'integer'                 },
            {name:'promsinimpext'                , typeName:'decimal'                 },
            {name:'promrealessincambio'          , typeName:'decimal'                 },
            {name:'promrealessincambioant'       , typeName:'decimal'                 },
            {name:'promsinaltasbajas'            , typeName:'decimal'                 },
            {name:'promsinaltasbajasant'         , typeName:'decimal'                 },
        ],
        primaryKey:['periodo','calculo','producto','division'],
        foreignKeys:[
             //{references:'calculos_def', fields:[
             //    {source:'calculo'  , target:'calculo'     },
             //]},
            {references:'periodos', fields:[
                {source:'periodo'         , target:'periodo'     },
            ]},
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'     },
            ]},
            {references:'calculos', fields:[
                {source:'periodo'  , target:'periodo'     },
                {source:'calculo'  , target:'calculo'     },
            ]},            
        ]
    },context);
}