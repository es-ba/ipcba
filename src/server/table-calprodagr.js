"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calprodagr',
        editable:puedeEditar,
        fields:[
            {name:'periodo'                      , typeName:'text'    , nullable:false},
            {name:'calculo'                      , typeName:'integer' , nullable:false},
            {name:'producto'                     , typeName:'text'    , nullable:false},
            {name:'agrupacion'                   , typeName:'text'    , nullable:false},
            {name:'cantporunidcons'              , typeName:'decimal'                  },
            {name:'valorprod'                    , typeName:'decimal'                  },
            {name:'unidadmedidaporunidcons'      , typeName:'text'                    },
            //{name:'cantidad'                     , typeName:'decimal'                  },
            {name:'unidaddemedida'               , typeName:'text'                    },
            {name:'pesovolumenporunidad'         , typeName:'decimal'                  },
        ],
        primaryKey:['periodo','calculo','producto','agrupacion'],
        foreignKeys:[
            {references:'agrupaciones', fields:[
                {source:'agrupacion'  , target:'agrupacion'     },
            ]},
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