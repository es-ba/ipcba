"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador'||context.user.usu_rol ==='migracion';
    return context.be.tableDefAdapt({
        name:'valvalatr',
        title:'Valvalatr',
        editable:puedeEditar,
        allow:{
            insert:puedeEditar,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'producto'               , typeName:'text'    , nullable:false                                 , allow:{update:puedeEditar}},
            {name:'atributo'               , typeName:'integer' , nullable:false                                 , allow:{update:puedeEditar}},
            {name:'valor'                  , typeName:'text'    , nullable:false                                 , allow:{update:puedeEditar}},
            {name:'validar'                , typeName:'boolean' , nullable:false, default:true, defaultValue:true, allow:{update:puedeEditar}},
            {name:'ponderadoratr'          , typeName:'decimal'                                                  , allow:{update:puedeEditar}},
        ],
        primaryKey:['producto','atributo','valor'],
        foreignKeys:[
            {references:'prodatr', fields:[
                {source:'producto'  , target:'producto'     },
                {source:'atributo'  , target:'atributo'     },
            ]},
        ],
        constraints:[
            {constraintType:'unique', fields:['producto','atributo','valor','validar']}
        ]

    },context);
}