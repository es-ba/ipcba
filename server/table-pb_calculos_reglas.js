"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'pb_calculos_reglas',
        //title:'Pb_calculos_reglas',
        editable:puedeEditar,
        fields:[
            {name:'calculo'           , typeName:'integer' , nullable:false},
            {name:'tipo_regla'        , typeName:'text'    , nullable:false},
            {name:'num_regla'         , typeName:'integer' , nullable:false},
            {name:'desde'             , typeName:'text'},
            {name:'hasta'             , typeName:'text'},
            {name:'valor'             , typeName:'text'},
        ],
        primaryKey:['calculo','tipo_regla','num_regla'],
        foreignKeys:[
            {references:'periodos', fields:[
                {source:'desde'   , target:'periodo'},
            ]},
            {references:'periodos', fields:[
                {source:'hasta'  , target:'periodo' },
            ]},
        ]

    });
}