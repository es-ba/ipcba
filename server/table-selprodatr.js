"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='admin';
    return context.be.tableDefAdapt({
        name:'selprodatr',
        title:'selprodatr',
        editable:puedeEditar,
        fields:[
            {name:'producto'                    , typeName:'text'   , nullable:false},
            {name:'sel_nro'                     , typeName:'integer', nullable:false},
            {name:'atributo'                    , typeName:'integer', nullable:false},
            {name:'valor'                       , typeName:'text'      },
            {name:'valorsinsimplificar'         , typeName:'text'      },
        ],
        primaryKey:['producto','sel_nro','atributo'],
        foreignKeys:[
            {references:'prodatr', fields:[
                {source:'producto'      , target:'producto'   },
                {source:'atributo'      , target:'atributo'   },
            ]},
            {references:'selprod', fields:[
                {source:'producto'      , target:'producto'   },
                {source:'sel_nro'       , target:'sel_nro'    },
            ]},
        ]
    });
}