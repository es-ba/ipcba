"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo'|| context.user.usu_rol ==='supervisor';
    return context.be.tableDefAdapt({
        name:'relsup',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:false,
        },
        fields:[
            {name:'periodo'                , typeName:'text'    , nullable:false},
            {name:'panel'                  , typeName:'integer' , nullable:false},
            {name:'supervisor'             , typeName:'text'    , nullable:false},
            {name:'disponible'             , typeName:'text'                    },
            {name:'motivonodisponible'     , typeName:'text'                    },
        ],
        primaryKey:['periodo','panel','supervisor'],
        foreignKeys:[
            {references:'personal', fields:[
                {source:'supervisor'    , target:'persona'     },
            ]},
            {references:'relpan', fields:[
                {source:'periodo'       , target:'periodo'     },
                {source:'panel'         , target:'panel'       },
            ]},
            {references:'periodos', fields:[
                {source:'periodo'       , target:'periodo'     },
            ]},
        ]
    }, context);
}