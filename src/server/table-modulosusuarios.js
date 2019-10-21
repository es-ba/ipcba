"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'modulosusuarios',
        editable:puedeEditar,
        fields:[
            {name:'formulario'                , typeName:'text'    , nullable:false},
            {name:'nombre'                    , typeName:'text'    , nullable:false, isName:true   },
            {name:'username'                  , typeName:'text'    , nullable:false},
            {name:'zona'                      , typeName:'text'    , nullable:false},
        ],
        primaryKey:['formulario','zona','nombre','username'],
        foreignKeys:[
            {references:'modulos', fields:[
                {source:'formulario'  , target:'formulario'     },
                {source:'zona'        , target:'zona'     },
                {source:'nombre'      , target:'nombre'     },
            ]},
            {references:'personal', fields:[
                {source:'username'  , target:'username'     },
            ]},
        ]

    });
}