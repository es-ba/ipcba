"use strict";

module.exports = function(context){
    var puedeEditar = context.user.usu_rol ==='programador' || context.user.usu_rol ==='analista' || context.user.usu_rol ==='coordinador' || context.user.usu_rol ==='jefe_campo'|| context.user.usu_rol ==='supervisor';
    return context.be.tableDefAdapt({
        name:'relsup_a_elegir',
        tableName:'relsup',
        editable:puedeEditar,
        allow:{
            insert:false,
            delete:false,
            update:puedeEditar,
        },
        fields:[
            {name:'periodo'                , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'panel'                  , typeName:'integer' , nullable:false, allow:{update:false}},
            {name:'supervisor'             , typeName:'text'    , nullable:false, allow:{update:false}},
            {name:'disponible'             , typeName:'text'    , postInput:'upperSpanish', allow:{update:puedeEditar}},
            {name:'motivonodisponible'     , typeName:'text'                    , allow:{update:puedeEditar}},
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
        ],
        sql:{
            from:`(
                select periodo, panel, supervisor, disponible, motivonodisponible
                   from relsup
                )`,
            isTable: false,
            }
    }, context);
}