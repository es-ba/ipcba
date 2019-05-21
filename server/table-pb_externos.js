"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'pb_externos',
        //title:'Pb_externos',
        editable:puedeEditar,
        fields:[
            {name:'producto'          , typeName:'text'    , nullable:false},
            {name:'periodo'           , typeName:'text'    , nullable:false},
            {name:'indice'            , typeName:'decimal'  },
        ],
        primaryKey:['producto','periodo'],
        foreignKeys:[
            {references:'periodos', fields:[
                {source:'periodo'   , target:'periodo'},
            ]},
            {references:'productos', fields:[
                {source:'producto'  , target:'producto'   },
            ]},
        ]

    });
}