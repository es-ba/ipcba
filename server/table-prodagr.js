"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'prodagr',
        //title:'Prodagr',
        editable:puedeEditar,
        fields:[
            {name:'producto'        , typeName:'text'    , nullable:false},
            {name:'agrupacion'      , typeName:'text'    , nullable:false},
            {name:'cantporunidcons' , typeName:'decimal'                  },
        ],
        primaryKey:['producto','agrupacion'],
        foreignKeys:[
            {references:'agrupaciones', fields:[
                {source:'agrupacion'  , target:'agrupacion'   },
            ]},
            {references:'productos', fields:[
                {source:'producto'    , target:'producto'   },
            ]},
        ]

    },context);
}