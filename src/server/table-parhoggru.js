"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'parhoggru',
        //title:'Parhoggru',
        editable:puedeEditar,
        fields:[
            {name:'parametro'         , typeName:'text'    , nullable:false},
            {name:'agrupacion'        , typeName:'text'    , nullable:false},
            {name:'grupo'             , typeName:'text'    , nullable:false},
        ],
        primaryKey:['parametro','agrupacion','grupo'],
        foreignKeys:[
            {references:'grupos', fields:[
                {source:'agrupacion'   , target:'agrupacion'},
                {source:'grupo'        , target:'grupo'     },
            ]},
            {references:'parhog', fields:[
                {source:'parametro'  , target:'parametro'   },
            ]},
        ]

    },context);
}