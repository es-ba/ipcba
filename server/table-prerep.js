"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'prerep',
        //title:'Prerep',
        editable:puedeEditar,
        fields:[
            {name:'periodo'           , typeName:'text'    , nullable:false},
            {name:'producto'          , typeName:'text'    , nullable:false},
            {name:'informante'        , typeName:'integer' , nullable:false},
        ],
        primaryKey:['periodo','producto','informante'],
        foreignKeys:[
            {references:'productos', fields:[
                {source:'producto'  , target:'producto'   },
            ]},
        ]

    },context);
}