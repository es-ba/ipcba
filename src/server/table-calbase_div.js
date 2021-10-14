"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'calbase_div',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:puedeEditar,
            update:puedeEditar,
        },        
        fields:[
            {name:'calculo'                      , typeName:'integer' , nullable:false},
            {name:'producto'                     , typeName:'text'    , nullable:false},
            {name:'division'                     , typeName:'text'    , nullable:false},
            {name:'ultimo_mes_anterior_bajas'    , typeName:'text'                    },
        ],
        primaryKey:['producto','calculo','division'],
        foreignKeys:[
            {references:'calculos_def', fields:[
                {source:'calculo'  , target:'calculo'     },
            ]},
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'     },
            ]},
        ],
        filterColumns:[
            {column:'calculo', operator:'!=', value:0},
        ],                
        constraints:[
            {constraintType:'check', consName:"texto invalido en division de tabla calbase_div", expr:"comun.cadena_valida(division, 'amplio')"}
        ],
    },context);
}