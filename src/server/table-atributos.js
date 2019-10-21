"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='migracion' || context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'atributos',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },        
        fields:[
            {name:'atributo'                    , typeName:'integer', nullable:false},
            {name:'nombreatributo'              , typeName:'text'   , isName:true   },
            {name:'tipodato'                    , typeName:'text'   , nullable:false},
            {name:'abratributo'                 , typeName:'text'      },
            {name:'escantidad'                  , typeName:'text'   , defaultValue:'N'},
            {name:'unidaddemedida'              , typeName:'text'      },
            {name:'es_vigencia'                 , typeName:'boolean'   },
            {name:'valorinicial'                , typeName:'text'      },
            {name:'visible'                     , typeName:'text'   , defaultValue:'S', nullable:false},
        ],
        primaryKey:['atributo'],
        foreignKeys:[
            {references:'unidades', fields:[
                {source:'unidaddemedida'         , target:'unidad'     },
            ]},
        ],
        constraints:[
            {constraintType:'check',  consName:"El tipo de atributo debe ser C (caracter) o N (número)", expr:"tipodato IN ('C', 'N')"},
            {constraintType:'check',  consName:"atributos_es_vigencia_check", expr:"es_vigencia"},
            {constraintType:'check',  consName:"texto invalido en abratributo de tabla atributos", expr:"comun.cadena_valida(abratributo, 'castellano')"},
            {constraintType:'check',  consName:"texto invalido en nombreatributo de tabla atributos", expr:"comun.cadena_valida(nombreatributo, 'castellano')"},
            {constraintType:'check',  consName:"texto invalido en unidaddemedida de tabla atributos", expr:"comun.cadena_valida(unidaddemedida, 'extendido')"},
            {constraintType:'check',  consName:"texto invalido en valorinicial de tabla atributos", expr:"comun.cadena_valida(valorinicial, 'amplio')"}
        ]
    }, context);
}