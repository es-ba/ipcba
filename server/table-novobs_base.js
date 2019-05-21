"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'novobs_base',
        //title:'Novobs_base',
        editable:puedeEditar,
        fields:[
            {name:'producto'                     , typeName:'text'    , nullable:false},
            {name:'informante'                   , typeName:'integer' , nullable:false},
            {name:'observacion'                  , typeName:'integer' , nullable:false},
            {name:'hasta_periodo'                , typeName:'text'    , nullable:false},
        ],
        primaryKey:['producto','informante','observacion'],
        foreignKeys:[
            {references:'periodos', fields:[
                {source:'hasta_periodo'         , target:'periodo'     },
            ]},
            {references:'productos', fields:[
                {source:'producto'         , target:'producto'     },
            ]},
        ]
    });
}