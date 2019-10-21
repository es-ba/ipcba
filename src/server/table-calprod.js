"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calprod',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false},
            {name:'calculo'                      , typeName:'integer' , nullable:false},
            {name:'producto'                     , typeName:'text'    , nullable:false},
            {name:'promprod'                     , typeName:'decimal'                  },
            {name:'impprod'                      , typeName:'text'                    },
            {name:'valorprod'                    , typeName:'decimal'                  },
            {name:'cantincluidos'                , typeName:'integer'                 },
            {name:'promprel'                     , typeName:'decimal'                  },
            {name:'valorprel'                    , typeName:'decimal'                  },
            {name:'cantaltas'                    , typeName:'integer'                 },
            {name:'promaltas'                    , typeName:'decimal'                  },
            {name:'cantbajas'                    , typeName:'integer'                 },
            {name:'prombajas'                    , typeName:'decimal'                  },
            {name:'cantperaltaauto'              , typeName:'integer'                 },
            {name:'cantperbajaauto'              , typeName:'integer'                 },
            {name:'esexternohabitual'            , typeName:'text'                    },
            {name:'imputacon'                    , typeName:'text'                    },
            {name:'cantporunidcons'              , typeName:'decimal'                  },
            {name:'unidadmedidaporunidcons'      , typeName:'text'                    },
            {name:'pesovolumenporunidad'         , typeName:'decimal'                  },
            //{name:'cantidad'                     , typeName:'decimal'                  },
            {name:'unidaddemedida'               , typeName:'text'                    },
            {name:'indice'                       , typeName:'decimal'                  },
            {name:'indiceprel'                   , typeName:'decimal'                  },
        ],
        primaryKey:['periodo','calculo','producto'],
        foreignKeys:[
            {references:'calculos_def', fields:[
                {source:'calculo'  , target:'calculo'     },
            ]},
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